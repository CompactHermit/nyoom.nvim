(import-macros {: let! : nyoom-module-p! : packadd!} :macros)
(local {: lsp_init} (require :util.lsp))
(local dap (autoload :dap))
;; NOTE:: It fucking does bozo
(local exec (fn [command args cwd]
              "
             exec:: IO.Cmd -> String::FilePath -> RustaceanExecutor
                 Returns a Oneshot Shell which runs the rust file
             "
              (let [{: Terminal} (autoload :toggleterm.terminal)
                    shell (autoload :rustaceanvim.shell)]
                (: (Terminal:new {:cmd (shell.make_command_from_args command
                                                                     args)
                                  :dir cwd
                                  :close_on_exit false
                                  :auto_scroll true})
                   :toggle))))

;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds
(fn __cratesSetup []
  " DocStrings::
        "
  (packadd! crates)
  (let [fidget (autoload :fidget)
        progress `,((. (autoload :fidget.progress) :handle :create) {:lsp_client {:name :crates}})]
    (progress:report {:message "Setting Up crates"
                      :level vim.log.levels.ERROR
                      :progress 0})
    ((->> :setup (. (require :crates))) {})
    (progress:report {:message "Setup Complete"
                      :title :Completed!
                      :progress 99})))

(vim.api.nvim_create_autocmd :BufReadPost
                             {:pattern :Cargo.toml
                              :callback #(__cratesSetup)
                              :once true})

;; NOTE: (Hermit) Rustaceanvim Is inheritely lazy
(tset vim.g :rustaceanvim
      {:server {:on_attach (fn [client bufnr] "Default Rust LSP Attach"
                             (lsp_init client bufnr))
                :settings (fn [__Proot]
                            "Server Settings"
                            {:rust-analyzer {:check {:command :clippy}
                                             :workspace {:symbol {:search {:kind :all_symbols}}}
                                             :cargo {:allFeatures true}
                                             :checkOnSave true
                                             :proMacro {:enabled true}}})}
       :tools {:executor {:execute_command exec}}})
