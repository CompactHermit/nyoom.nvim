(import-macros {: map! : nyoom-module-p! : let! : custom-set-face! : packadd!}
               :macros)

;; TODO:: Rewrite with -> Macro

;; TODO (Hermit) Refactor this
(local lsp-capabilities (do
                          (local capabilities
                                 (vim.lsp.protocol.make_client_capabilities))
                          (set capabilities.textDocument.completion.completionItem
                               {:resolveSupport {:properties [:documentation
                                                              :detail
                                                              :additionalTextEdits]}
                                :documentationFormat [:markdown]
                                :deprecatedSupport true
                                :snippetSupport true
                                :commitCharactersSupport true
                                :labelDetailsSupport true
                                :insertReplaceSupport true
                                :preselectSupport true
                                :tagSupport {:valueSet [1]}})
                          (set capabilities.textDocument.foldingRange
                               {:dynamicRegistration false
                                :lineFoldingOnly true})
                          capabilities))

(fn __haskLoad! []
  "
    Loader For Haskell:: 
        - haskell.tools
        - haskell.snippets
  "
  (packadd! haskellTools)
  (packadd! haskell-snippets)
  (local lsp (require :util.lsp))
  (local ht (autoload :haskell-tools))
  (let! haskell_tools
        {:tools {:codeLens {:autoRefresh true}
                 :hoogle {:mode :telescope-local}
                 :hover {:enable true}
                 :tags {:enable true}
                 :repl {:handler :toggleterm :prefer :cabal :auto_focus true}
                 :definition {:hoogle_signature_fallback true}}
         :hls {:capabilities lsp-capabilities
               :on_attach (fn [_client _bufnr]
                            ((->> :load_extension (. (autoload :telescope))) :ht)
                            (map! [n] :<leader>fhl
                                  `(ht.project.telescope_package_grep))
                            (map! [n] :<leader>fho
                                  `(ht.project.telescope_package_grep)
                                  {:desc "<H.tele>:: [Gr] Grep"})
                            (map! [n] :<leader>fhm
                                  `(ht.project.telescope_package_files)
                                  {:desc "<H.tele>:: [Pkg] File"})
                            (map! [n] :<leader>fhc
                                  `(ht.project.open_package_cabal)
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
                                  {:desc "<H.Repl>:: [P] Buffer"})
                            (custom-set-face! :LspCodeLens []
                                              {:fg "#ff7bd6" :bg :NONE})
                            (local _opts
                                   {:s :save
                                    :a :display
                                    :g :get
                                    :r :run
                                    :f :refresh})
                            (each [k v (pairs _opts)]
                              (vim.keymap.set :n (.. :<leader>cc k)
                                              #((. vim.lsp.codelens k)))
                              {:desc v}))
               :settings {:haskell {:formattingProvider :fourmolu}
                          :plugin {:ghcide-code-actions-fill-holes {:globalOn true}
                                   :ghcide-completions {:globalOn true}
                                   :ghcide-hover-and-symbols {:globalOn true}
                                   :ghcide-type-lenses {:globalOn true}
                                   :ghcide-code-actions-type-signatures {:globalOn true}
                                   :ghcide-code-actions-bindings {:globalOn true}
                                   :ghcide-code-actions-imports-exports {:globalOn true}
                                   :eval {:globalOn true}
                                   :moduleName {:globalOn true}
                                   :pragmas {:globalOn true}
                                   :tactic {:codeLensOn true}
                                   :LiquidHaskellBoot {:codeLensOn true}
                                   :refineImports {:globalOn true}
                                   :importLens {:globalOn true}
                                   :class {:globalOn true}
                                   :tactics {:globalOn true}
                                   :hlint {:globalOn true}
                                   :haddockComments {:globalOn true}
                                   :retrie {:globalOn true}
                                   :rename {:globalOn true}
                                   :splic {:globalOn true}}}
               :default_settings {:haskell {:formattingProvider :fourmolu
                                            :maxCompletions 10}}}}))

;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds
(vim.api.nvim_create_autocmd [:BufEnter :BufRead]
                             {:pattern [:*.hs :*.cabal]
                              :callback #(__haskLoad!)
                              :once true})
