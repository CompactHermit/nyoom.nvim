(import-macros {: nyoom-module-p! : nyoom-module-ensure! : packadd!} :macros)
;;TODO:: Hermit - Add vale-linter

;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds
(let [fidget (autoload :fidget)
      null-ls (autoload :null-ls)
      null-ls-sources []
      builtins null-ls.builtins
      {: on-attach} (autoload :modules.tools.lsp.config)
      progress `,((. (autoload :fidget.progress) :handle :create) {:lsp_client {:name :null}})]
  (progress:report {:message "Setting Up Null_LS"
                    :level vim.log.levels.ERROR
                    :progress 0})
  (vim.diagnostic.config {:underline {:severity {:min vim.diagnostic.severity.INFO}}
                          :signs {:severity {:min vim.diagnostic.severity.HINT}
                                  :text {vim.diagnostic.severity.ERROR shared.icons.error
                                         vim.diagnostic.severity.WARN shared.icons.warn
                                         vim.diagnostic.severity.INFO shared.icons.info
                                         vim.diagnostic.severity.HINT shared.icons.hint}}
                          :virtual_text false
                          :float {:show_header false
                                  :source :always
                                  :border :rounded}
                          :update_in_insert true
                          :severity_sort true})
  (nyoom-module-p! format
                   (do
                     (table.insert null-ls-sources builtins.formatting.fnlfmt)
                     (nyoom-module-p! clojure
                                      (table.insert null-ls-sources
                                                    null-ls.builtins.formatting.zprint))
                     (nyoom-module-p! python
                                      (doto null-ls-sources
                                        (table.insert null-ls.builtins.formatting.black)
                                        (table.insert null-ls.builtins.formatting.isort)))
                     (nyoom-module-p! java
                                      (table.insert null-ls-sources
                                                    null-ls.builtins.formatting.google_java_format))
                     (nyoom-module-p! kotlin
                                      (table.insert null-ls-sources
                                                    null-ls.builtins.formatting.ktlint))
                     (nyoom-module-p! lua
                                      (table.insert null-ls-sources
                                                    null-ls.builtins.formatting.stylua))
                     (nyoom-module-p! markdown
                                      (table.insert null-ls-sources
                                                    null-ls.builtins.formatting.markdownlint))
                     (nyoom-module-p! nim
                                      (table.insert null-ls-sources
                                                    null-ls.builtins.formatting.nimpretty))
                     (nyoom-module-p! nickel
                                      (table.insert null-ls-sources
                                                    null-ls.builtins.formatting.topiary))
                     (nyoom-module-p! nix
                                      (doto null-ls-sources
                                        (table.insert null-ls.builtins.formatting.nixfmt)
                                        (table.insert (null-ls.builtins.formatting.treefmt.with {:condition (fn [utils]
                                                                                                              (utils.root_has_file :flake.nix))}))))
                     (nyoom-module-p! sh
                                      (table.insert null-ls-sources
                                                    null-ls.builtins.formatting.shfmt))))
  (nyoom-module-p! diagnostics
                   (do
                     (nyoom-module-p! kotlin
                                      (table.insert null-ls-sources
                                                    null-ls.builtins.diagnostics.ktlint))))
  (nyoom-module-p! vc-gutter
                   (table.insert null-ls-sources
                                 null-ls.builtins.code_actions.gitsigns))
  ((->> :setup (. (autoload :null-ls))) {:sources null-ls-sources
                                         :diagnostics_format "[#{c}] #{m} (#{s})"
                                         :debug true
                                         :on_attach on-attach})
  (nyoom-module-p! config
                   (do
                     (local {:open_float open-line-diag-float!
                             :goto_prev goto-diag-prev!
                             :goto_next goto-diag-next!}
                            vim.diagnostic)
                     (map! [n] :<leader>d open-line-diag-float!
                           {:desc "Open diagnostics at line"})
                     (map! [n] "[d" goto-diag-prev!
                           {:desc "Goto previous diagonstics"})
                     (map! [n] "]d" goto-diag-next!
                           {:desc "Goto next diagnostics"})))
  (progress:report {:message "Setup Complete" :title :Completed! :progress 100}))


((->> :setup (. (autoload :lsp_lines))))
