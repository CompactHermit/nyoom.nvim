(import-macros {: let!} :macros)
(local {: init-hints : lsp_init} (require :util.lsp))
(setup :ferris {:create_commands true})

(let! rustaceanvim
      {:server {:on_attach (fn [client bufnr]
                             (print :DEBUG)
                             (lsp_init client)
                             (init-hints client))}})

