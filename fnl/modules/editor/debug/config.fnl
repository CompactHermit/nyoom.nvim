(let [fidget (autoload :fidget)
      progress `,((. (autoload :fidget.progress) :handle :create) {:lsp_client {:name :__dap}})
      dap (autoload :dap) ;dap-rr (autoload :nvim-dap-rr)
      find-exe (fn []
                 (let [opts {}
                       pickers (autoload :telescope.pickers)
                       finders (autoload :telescope.finders)
                       conf (. (autoload :telescope.config) :values)
                       actions (autoload :telescope.actions)
                       action-state (autoload :telescope.actions.state)]
                   (coroutine.create (fn [coro]
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
                                          :find)))))
      coreclr-configs {:name :netcoredbg
                       :type :coreclr
                       :request :launch
                       :program (fn []
                                  (vim.fn.input "Path to executable: "
                                                (.. (vim.fn.getcwd)
                                                    :/bin/Debug/ :file)))}
      lldb {:name "lldb: Launch (console)"
            :type :lldb
            :request :launch
            :program find-exe
            :cwd "${workspaceFolder}"
            :stopOnEntry false}
      codelldb {:name "CodeLLDB Launcher"
                :type :codelldb
                :request :launch
                :cwd "${workspaceFolder}"
                :stopOnEntry false
                :program find-exe}
      gdb {:name "Launch GDB"
           :type :gdb
           :request :launch
           :cwd "${workspaceFolder}"
           :stopOnEntry false
           :program find-exe}
      _configs [gdb codelldb lldb]]
  (set dap.adapters.kotlin {:command :kotlin-debug-adapter
                            :options {:auto_continue_if_many_stopped false}
                            :type :executable})
  (set dap.adapters.lldb {:type :executable :command :lldb-vscode :name :lldb})
  (set dap.configurations.kotlin
       [{:enableJsonLogging false
         :jsonLogFile ""
         :mainClass (fn []
                      (local root (or (. (vim.fs.find :src
                                                      {:path (vim.uv.cwd)
                                                       :stop vim.env.HOME
                                                       :upward true})
                                         1)
                                      ""))
                      (local fname (vim.api.nvim_buf_get_name 0))
                      (: (: (: (: (fname:gsub root "") :gsub :main/kotlin/ "")
                               :gsub :.kt :Kt)
                            :gsub "/" ".") :sub 2
                         (- 1)))
         :name "This file"
         :projectRoot "${workspaceFolder}"
         :request :launch
         :type :kotlin}
        {:args {}
         :hostName :localhost
         :name "Attach to debugging session"
         :port 5005
         :projectRoot vim.fn.getcwd
         :request :attach
         :timeout 2000
         :type :kotlin}])
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
  (set dap.configurations.cs coreclr-configs)
  (set dap.adapters.coreclr
       {:type :executable :command :netcoredbg :args [:--interpreter=vscode]})
  (set dap.configurations.lua
       [{:type :nlua
         :request :attach
         :name "Attach to running Neovim instance"}])
  (set dap.adapters.nlua
       (fn [callback config]
         (callback {:type :server
                    :host (or config.host :127.0.0.1)
                    :port (or config.port 8061)})))
  (set dap.adapters.haskell {:args [:--hackage-version=0.0.33.0]
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
         :workspace "${workspaceFolder}"}])
  ;(table.insert dap.configurations.cpp dap.configurations.c)
  (progress:report {:message "Setting Up dap"
                    :level vim.log.levels.ERROR
                    :progress 0})
  ((->> :setup
        (. (autoload :dapui))) {:icons {:expanded ""
                                                       :collapsed " "
                                                       :current_frame ""
                                                       :controls {:icons {:pause ""
                                                                          :play ""
                                                                          :step_into ""
                                                                          :step_over ""
                                                                          :step_out ""
                                                                          :step_back ""
                                                                          :run_last ""
                                                                          :terminate ""
                                                                          :disconnect ""}}
                                                       :floating {:border :single}}})
  (do
    (match vim.env.VIRTUAL_ENV
      (where k1 (not= k1 nil)) ((->> :setup
                                     (. (autoload :dap-python))) (vim.fn.exepath :debugpy))
      _ nil))
  ((->> :setup (. (autoload :nvim-dap-virtual-text))))
  ;((->> :setup (. (autoload :nvim-dap-rr))) {})
  (progress:report {:message "Setup Complete" :title :Completed! :progress 100})
  (progress:finish))
