(import-macros {: map! : nyoom-module-p! : let!} :macros)
;; TODO:: Rewrite with -> Macro
(local ht (autoload :haskell-tools))
(local lsp (require :util.lsp))

(nyoom-module-p! haskell
                 (do
                   ;;TODO:: (Hermit)
                   (map! [n] :<leader>fhl `(ht.project.telescope_package_grep))
                   (map! [n] :<leader>fho `(ht.project.telescope_package_grep)
                         {:desc "<H.tele>:: [Gr] Grep"})
                   (map! [n] :<leader>fhm `(ht.project.telescope_package_files)
                         {:desc "<H.tele>:: [Pkg] File"})
                   (map! [n] :<leader>fhc `(ht.project.open_package_cabal)
                         {:desc "[Pkg] Cabal"})
                   (map! [n] :<leader>fha `(ht.repl.toggle)
                         {:desc "<H.repl>:: [T]oggle"})
                   (map! [n] :<leader>fhr `(ht.repl.reload)
                         {:desc "<H.repl>:: [Re]load"})
                   (map! [n] :<leader>fhz `(ht.repl.quit)
                         {:desc "<H.repl>:: [Q]uit"})
                   (map! [n] :<leader>fhw `(ht.repl.paste)
                         {:desc "<H.repl>:: [P] Cursor"})
                   (map! [n] :<leader>fhs `(ht.repl.paste_type)
                         {:desc "<H.repl>:: [P] Type"})
                   (map! [n] :<leader>fhx `(ht.repl.cword_type)
                         {:desc "<H.repl>:: [P] Cursor"})
                   (map! [n] :<leader>fhd
                         `(ht.repl.toggle (vim.api.nvim_buf_get_name (vim.api.nvim_get_current_buf)))
                         {:desc "<H.Repl>:: [P] Buffer"})))

;;TODO:: (Hermit)
(let! haskell_tools
      {:tools {:codeLens {:autoRefresh false}
               :hoogle {:mode :telescope-local}
               :hover {:enable true}
               :tags {:enable true}
               :repl {:handler :toggleterm :prefer :cabal :auto_focus true}
               :definition {:hoogle_signature_fallback true}}
       :hls {:capabilities lsp.capabilites
             :default_settings {:haskell {:formattingProvider :fourmolu}}}})
