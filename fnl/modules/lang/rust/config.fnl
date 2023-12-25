(import-macros {: let! : nyoom-module-p!} :macros)
(local {: lsp_init} (require :util.lsp))

;; NOTE:: (Hermit Does this even work?
(local exec (fn [command args cwd]
             " 
             Returns a Oneshot Shell which runs the rust file
             "
             (let [{: Terminal} (require :toggleterm.terminal)
                   shell (require :rustaceanvim.shell)]
                (: (Terminal:new {:cmd (shell.make_command_from_args command args)
                                  :dir cwd
                                  :close_on_exit false
                                  :auto_scroll true}) :toggle))))

(let! rustaceanvim
      {:server {:on_attach (fn [client bufnr]
                             "Default Rust LSP Attach"
                             (lsp_init client bufnr))
                :settings (fn []
                            "Server Settings"
                            {:rust-analyzer {:check {:command :clippy}
                                             :workspace {:symbol {:search {:kind :all_symbols}}}}})}
       :dap {:auto_generate_source_map true}
       :tools {:executor {:execute_command exec}}})
