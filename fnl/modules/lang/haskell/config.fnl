(import-macros {: map! : nyoom-module-p! : let!} :macros)
;; TODO:: Rewrite with -> Macro
(local ht (autoload :haskell-tools))
(local lsp (require :util.lsp))

(nyoom-module-p! haskell
                 (do
                   (map! [n] :<leader>fhl `(ht.project.telescope_package_grep))
                   (map! [n] :<leader>fho `(ht.project.telescope_package_grep)
                         {:desc "<H.tele>:: Pack_Grep"})
                   (map! [n] :<leader>fhm `(ht.project.telescope_package_files)
                         {:desc "<H.tele>:: Pack_file"})
                   (map! [n] :<leader>fhn `(ht.project.open_package_yaml)
                         {:desc "<H.open>:: P.Yaml"})
                   (map! [n] :<leader>fhc `(ht.project.open_package_cabal)
                         {:desc "<H.open>:: P.cabal "})
                   (map! [n] :<leader>fhq `(ht.repl.toggle)
                         {:desc "<H.repl>:: Toggle"})
                   (map! [n] :<leader>fha `(ht.repl.reload)
                         {:desc "<H.repl>:: Reload"})
                   (map! [n] :<leader>fhz `(ht.repl.quit)
                         {:desc "<H.repl>:: Quit"})
                   (map! [n] :<leader>fhw `(ht.repl.paste)
                         {:desc "<H.repl>:: Paste"})
                   (map! [n] :<leader>fhs `(ht.repl.paste_type)
                         {:desc "<H.repl>:: Type_paste"})
                   (map! [n] :<leader>fhx `(ht.repl.cword_type)
                         {:desc "<H.repl>:: Cursor_paste"})
                   (map! [n] :<leader>fhd
                         `(ht.repl.toggle (vim.api.nvim_buf_get_name (vim.api.nvim_get_current_buf))))))

(let! haskell_tools
      {:tools {:codeLens {:autoRefresh false}
               :hoogle {:mode :telescope-local}
               :hover {:enable true}
               :definition {:hoogle_signature_fallback true}}
        :hls {:capabilities lsp.capabilites
              :default_settings {:haskell
                                    {:formattingProvider "stylish-haskell"}}}})
       
