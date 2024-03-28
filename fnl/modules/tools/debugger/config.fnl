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

(nyoom-module-p! python (do
                          (packadd! nvim-dap-python)
                          (match vim.env.VIRTUAL_ENV
                            (where _Path) ((->> :setup
                                                (. (require :dap-python))) (vim.fn.exepath :debugpy))
                            _ nil)))

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
                   (table.insert dap.configurations.c dap.configurations.cpp)))

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
