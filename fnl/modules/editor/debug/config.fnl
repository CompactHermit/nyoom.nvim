(local fidget (autoload :fidget))
(local progress
       `,((. (autoload :fidget.progress) :handle :create) {:lsp_client {:name :__dap}}))

(local dap (autoload :dap))

;dap-rr (autoload :nvim-dap-rr)
(local find-exe #(let [opts {}
                       pickers (autoload :telescope.pickers)
                       finders (autoload :telescope.finders)
                       conf (. (autoload :telescope.config) :values)
                       actions (autoload :telescope.actions)
                       action-state (autoload :telescope.actions.state)]
                   (coroutine.create (fn [coro]
                                       (: (pickers.new opts
                                                       {:attach_mappings (fn [buffer-number]
                                                                           (actions.select_default:replace #(do
                                                                                                              (actions.close buffer-number)
                                                                                                              (coroutine.resume coro
                                                                                                                                (. (action-state.get_selected_entry)
                                                                                                                                   1))))
                                                                           true)
                                                        :finder (finders.new_oneshot_job [:fd
                                                                                          ; :--exclude
                                                                                          ; :.git
                                                                                          :--no-ignore
                                                                                          :--type
                                                                                          :x]
                                                                                         {})
                                                        :prompt_title "Path to executable"
                                                        :sorter (conf.generic_sorter opts)})
                                          :find)))))

(local coreclr-configs
       {:name :netcoredbg
        :type :coreclr
        :request :launch
        :program (fn []
                   (vim.fn.input "Path to executable: "
                                 (.. (vim.fn.getcwd) :/bin/Debug/ :file)))})

(local lldb {:name "lldb: Launch (console)"
             :type :lldb
             :request :launch
             :program find-exe
             :cwd "${workspaceFolder}"
             :stopOnEntry false})

(local codelldb {:name "CodeLLDB Launcher"
                 :type :codelldb
                 :request :launch
                 :cwd "${workspaceFolder}"
                 :stopOnEntry false
                 :program find-exe})

(local gdb {:name "Launch GDB"
            :type :gdb
            :request :launch
            :cwd "${workspaceFolder}"
            :stopOnEntry false
            :program find-exe})

(local _configs [gdb codelldb lldb])
(set dap.adapters.lldb {:type :executable :command :lldb-vscode :name :lldb})

(set dap.configurations {:c _configs :cpp _configs :rust _configs})
;(table.insert dap.configurations.cpp (dap-rr.get_config)) ; (table.insert dap.configurations.c (dap-rr.get_config)) ; (table.insert dap.configurations.rust (dap-rr.get_rust_config))
(set dap.adapters
     {:codelldb {:executable {:args [:--port "${port}"] :command :codelldb}
                 :port "${port}"
                 :type :server}
      :cppdbg {:id :cppdbg :type :executable :command :cppdbg}
      :gdb {:args [:-i :dap] :command :gdb :type :executable}
      :lldb {:command :lldb-vscode :type :executable}})

(set dap.configurations.zig [lldb])
(set dap.configurations.cs [coreclr-configs])
(set dap.adapters.coreclr
     {:type :executable :command :netcoredbg :args [:--interpreter=vscode]})

(set dap.configurations.lua
     [{:type :nlua :request :attach :name "Attach to running Neovim instance"}])

(set dap.adapters.nlua
     (fn [callback config]
       (callback {:type :server
                  :host (or config.host :127.0.0.1)
                  :port (or config.port 8061)})))

; (set dap.adapters.haskell
;      {:type :executable :command (vim.fn.exepath :haskell-debug-adapter)})
;
;; TODO:: REDO THIS WITH CABAL
(set dap.configurations.haskell [{:ghciCmd "cabal ghci --test --no-load --no-build --main-is TARGET --ghci-options -fprint-evld-with-show"
                                  :ghciEnv (vim.empty_dict)
                                  :ghciInitialPrompt "λ: "
                                  :ghciPrompt "λ: "
                                  :logFile (.. (vim.fn.stdpath :data)
                                               :/haskell-dap.log)
                                  :logLevel :WARNING
                                  :name :Debug
                                  :request :launch
                                  :startup "${file}"
                                  :stopOnEntry true
                                  :type :haskell
                                  :workspace "${workspaceFolder}"}
                                 gdb])

;
;(table.insert dap.configurations.cpp dap.configurations.c)
(progress:report {:message "Setting Up dap"
                  :level vim.log.levels.ERROR
                  :progress 0})

((->> :setup (. (require :dapui))))

; {:icons {:expanded ""
;                       :collapsed " "
;                       :current_frame ""
;                       :controls {:icons {:pause ""
;                                          :play ""
;                                          :step_into ""
;                                          :step_over ""
;                                          :step_out ""
;                                          :step_back ""
;                                          :run_last ""
;                                          :terminate ""
;                                          :disconnect ""}}
;                       :floating {:border :single}}})

; (do
;   (match vim.env.VIRTUAL_ENV
;     (where k1 (not= k1 nil)) ((->> :setup
;                               (. (autoload :dap-python))) (vim.fn.exepath :debugpy))
;     _ nil)) 
((->> :setup (. (autoload :nvim-dap-virtual-text))))
;((->> :setup (. (autoload :nvim-dap-rr))) {})
(progress:report {:message "Setup Complete" :title :Completed! :progress 100})

(progress:finish)
