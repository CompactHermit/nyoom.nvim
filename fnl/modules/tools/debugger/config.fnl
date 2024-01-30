(import-macros {: packadd! : nyoom-module-p!} :macros)
(local dap (autoload :dap))

;;NOTE:: All Dap Binaries will be loaded in the devshell
(set dap.adapters.lldb
     {:type :server
      :port "${port}"
      :executable {:command :codelldb :args [:--port "${port}"]}})

(set dap.adapters.cppdbg {:id :cppdbg :type :executable :command :cppdbg})

(local lldb-configs
       [{:name "lldb: Launch (console)"
         :type :codelldb
         :request :launch
         :program (fn []
                    (vim.fn.input "Path to executable: "
                                  (.. (vim.fn.getcwd) "/") :file))
         :cwd "${workspaceFolder}"
         :stopOnEntry true}
        {:name "lldb: Launch (integratedTerminal)"
         :type :codelldb
         :request :launch
         :program (fn []
                    (vim.fn.input "Path to executable: "
                                  (.. (vim.fn.getcwd) "/") :file))}])

(local coreclr-configs
       [{:name :netcoredbg
         :type :coreclr
         :request :launch
         :program (fn []
                    (vim.fn.input "Path to executable: "
                                  (.. (vim.fn.getcwd) :/bin/Debug/ :file)))}])

(nyoom-module-p! csharp
                 (do
                   (set dap.configurations.cs coreclr-configs)
                   (set dap.adapters.coreclr
                        {:type :executable
                         :command :netcoredbg
                         :args [:--interpreter=vscode]})))

(nyoom-module-p! lua
                 (do
                   (packadd! one-small-step-for-vimkind)
                   (set dap.configurations.lua
                        [{:type :nlua
                          :request :attach
                          :name "Attach to running Neovim instance"}])
                   (set dap.adapters.nlua
                        (fn [callback config]
                          (callback {:type :server
                                     :host (or config.host :127.0.0.1)
                                     :port (or config.port 8086)})))))

(nyoom-module-p! haskell
                 (do
                   (set dap.adapters.haskell
                        {:args [:--hackage-version=0.0.33.0]
                         :command :haskell-debug-adapter
                         :type :executable})
                   (set dap.configurations.haskell
                        [{:ghciCmd "stack ghci --test --no-load --no-build --main-is TARGET --ghci-options -fprint-evld-with-show"
                          :ghciEnv (vim.empty_dict)
                          :ghciInitialPrompt "λ: "
                          :ghciPrompt "λ: "
                          :logFile (.. (vim.fn.stdpath :data) :/haskell-dap.log)
                          :logLevel :WARNING
                          :name :Debug
                          :request :launch
                          :startup "${file}"
                          :stopOnEntry true
                          :type :haskell
                          :workspace "${workspaceFolder}"}])))

; (nyoom-module-p! python
;                  (do
;                    (packadd! nvim-dap-python)
;                    (local python-debug-path "~/.virtualenvs/debugpy/bin/python")
;                    (nyoom-module-p! mason
;                                     (local python-debug-path
;                                            "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"))
;                    (setup :dap-python python-debug-path)))
(packadd! nvim-dap-rr)
((->> :setup (. (require :nvim-dap-rr))) {:mappings {:continue :<F7>
                                                     :step_over :<F8>
                                                     :step_out :<F9>
                                                     :step_into :<F10>
                                                     :reverse_continue :<F19>
                                                     :reverse_step_over :<F20>
                                                     :reverse_step_out :<F21>
                                                     :reverse_step_into :<F22>
                                                     :step_over_i :<F32>
                                                     :step_out_i :<F33>
                                                     :step_into_i :<F34>
                                                     :reverse_step_over_i :<F44>
                                                     :reverse_step_out_i :<F45>
                                                     :reverse_step_into_i :<F46>}})

;;NOTE:: (Hermit) Setup rr-debugger opts after config
(nyoom-module-p! cc
                 (do
                   (set dap.configurations.c lldb-configs)
                   (set dap.configurations.cpp
                        [(. (autoload :nvim-dap-rr) :get_config)])
                   (set dap.configurations.c dap.configurations.cpp)))

(fn get_rust_gdb []
  "get_rust_gdb:: _ -> <Path::binary>
          Returns the path to rust-gdb based off the toolchain location:
          Nix:: We set an environment variable pointing to the toolchain Directory
          _ :: IDK really, we just hard query lmao, patzers"
  (local toolchain (match (os.getenv :RUST_BIN)
                     (where c1 (not= c1 nil)) (string.gsub (os.getenv :RUST_BIN)
                                                           "\n" "")
                     _ (string.gsub (vim.fn.system "rustc --print sysroot")
                                    "\n" "")))
  (local rustgdb (.. toolchain :/rust-gdb))
  rustgdb)

(fn get_program []
  "TODO:: REFACTOR THIS SHIT
    Get_Program::_ ->[]"
  (let [pickers (autoload :telesope.pickers)
        conf (. (autoload :telescope.config) :values)
        actions (autoload :telescope.actions)
        action-state (autoload :telescope.actions.state)
        finders (autoload :telescope.finders)]
    (coroutine.create (fn [coro]
                        (let [opts {}]
                          (: (pickers.new opts
                                          {:attach_mappings (fn [buffer-number]
                                                              (actions.select_default:replace (fn []
                                                                                                (actions.close buffer-number)
                                                                                                (coroutine.resume coro
                                                                                                                  (. (action-state.get_selected_entry)
                                                                                                                     1))))
                                                              true)
                                           :finder (finders.new_oneshot_job [:fd
                                                                             :--exclude
                                                                             :.git
                                                                             :--no-ignore
                                                                             :--type
                                                                             :x]
                                                                            {})
                                           :prompt_title "Path to executable"
                                           :sorter (conf.generic_sorter opts)})
                             :find))))))

(nyoom-module-p! rust
                 (doto dap.configurations.rust
                   (set {})
                   (table.insert [(. (require :nvim-dap-rr) :get_rust_config)]))
                 ; (table.insert [{:name "(GDB) Launch file"
                 ;                 :type :cppdbg
                 ;                 :request :launch
                 ;                 :program (get_program)
                 ;                 :miDebuggerPath (get_rust_gdb)
                 ;                 :cwd (vim.fn.getcwd)
                 ;                 :stopAtEntry true}]))
                 (let! rustaceanvim {:dap {:disable true}}))

;; VIRT TEXT
((->> :setup (. (require :nvim-dap-virtual-text))))

(packadd! nvim-dap-ui)
(setup :dapui {:icons {:expanded "" :collapsed " " :current_frame ""}
               :controls {:icons {:pause ""
                                  :play ""
                                  :step_into ""
                                  :step_over ""
                                  :step_out ""
                                  :step_back ""
                                  :run_last ""
                                  :terminate ""
                                  :disconnect ""}}
               :floating {:border :single}})
