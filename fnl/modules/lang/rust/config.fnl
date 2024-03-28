(import-macros {: let! : nyoom-module-p! : packadd!} :macros)
(local {: lsp_init} (require :util.lsp))
(local dap (autoload :dap))
;; NOTE:: It fucking does bozo
(local exec (fn [command args cwd]
              "
             exec:: IO.Cmd -> String::FilePath -> RustaceanExecutor
                 Returns a Oneshot Shell which runs the rust file
             "
              (let [{: Terminal} (require :toggleterm.terminal)
                    shell (require :rustaceanvim.shell)]
                (: (Terminal:new {:cmd (shell.make_command_from_args command
                                                                     args)
                                  :dir cwd
                                  :close_on_exit false
                                  :auto_scroll true})
                   :toggle))))

; (fn get_rust_gdb []
;   "get_rust_gdb:: _ -> <Path::binary>
;           Returns the path to rust-gdb based off the toolchain location:
;           Nix:: We set an environment variable pointing to the toolchain Directory
;           _ :: IDK really, we just hard query lmao, patzers"
;   (local toolchain (match (os.getenv :RUST_BIN)
;                      (where c1 (not= c1 nil)) (c1 :gsub "\n" "")
;                      _ (string.gsub (vim.fn.system "rustc --print sysroot")
;                                     "\n" "")))
;   (local rustgdb (.. toolchain :/rust-gdb))
;   rustgdb)

; (fn get_program []
;   "TODO:: REFACTOR THIS SHIT
;     Get_Program::_ ->[]"
;   (let [pickers (autoload :telesope.pickers)
;         conf (. (autoload :telescope.config) :values)
;         actions (autoload :telescope.actions)
;         action-state (autoload :telescope.actions.state)
;         finders (autoload :telescope.finders)]
;     (coroutine.create (fn [coro]
;                         (let [opts {}]
;                           (: (pickers.new opts
;                                           {:attach_mappings (fn [buffer-number]
;                                                               (actions.select_default:replace (fn []
;                                                                                                 (actions.close buffer-number)
;                                                                                                 (coroutine.resume coro
;                                                                                                                   (. (action-state.get_selected_entry)
;                                                                                                                      1))))
;                                                               true)
;                                            :finder (finders.new_oneshot_job [:fd
;                                                                              :--exclude
;                                                                              :.git
;                                                                              :--no-ignore
;                                                                              :--type
;                                                                              :x]
;                                                                             {})
;                                            :prompt_title "Path for Debugger?"
;                                            :sorter (conf.generic_sorter opts)})
;                              :find))))))

; (packadd! nvim-dap-rr-nvim)
; (var dap-config [((. (autoload :nvim-dap-rr) :get_rust_config))
;                  {:name "(GDB) Launch file"
;                   :type :rustgdb
;                   :request :launch
;                   :program (get_program)
;                   :miDebuggerPath (get_rust_gdb)
;                   :cwd (vim.fn.getcwd)
;                   :stopAtEntry true}])
;
;(set dap.configurations.rust dap-config)

(let! rustaceanvim
      {:server {:on_attach (fn [client bufnr] "Default Rust LSP Attach"
                             (lsp_init client bufnr))
                :settings (fn []
                            "Server Settings"
                            {:rust-analyzer {:check {:command :clippy}
                                             :workspace {:symbol {:search {:kind :all_symbols}}}
                                             :cargo {:allFeatures true}
                                             :checkOnSave true
                                             :proMacro {:enabled true}}})}
       :tools {:executor {:execute_command exec}}})
