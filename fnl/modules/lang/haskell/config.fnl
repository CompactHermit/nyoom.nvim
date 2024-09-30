(import-macros {: map! : nyoom-module-p! : let! : custom-set-face! : packadd!}
               :macros)

(local ht (autoload :haskell-tools))
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

(custom-set-face! :LspCodeLens [] {:fg "#ff7bd6" :bg :NONE})

(local lsp (require :util.lsp))
((. (require :telescope) :load_extension) :hoogle)

;; fnlfmt: skip
(let! haskell_tools
      {:tools {:codeLens {:autoRefresh true}
               :hoogle {:mode :telescope-local}
               :hover {:enable true}
               :tags {:enable true}
               :repl {:handler :toggleterm :prefer :cabal :auto_focus true}
               :definition {:hoogle_signature_fallback true}}
       :hls {:capabilities lsp-capabilities
             :auto_attach #(let [bufnr (vim.api.nvim_get_current_buf)
                                 filename (vim.api.nvim_buf_get_name bufnr)]
                             (not (filename:match "%.hsc$")))
             :on_attach #(do
                           ((->> :load_extension (. (autoload :telescope))) :ht)
                           (vim.keymap.set :n :<space>ch "<Plug>HaskellHoverAction" {:noremap true :silent true :desc "[Hls] [Ho]ver"})
                           (ht.dap.discover_configurations $2)
                           (local _opts
                                  {:s :save
                                   :a :display
                                   :g :get
                                   :r :run
                                   :f :refresh})
                          (each [k v (pairs _opts)]
                            (vim.keymap.set :n (.. :<leader>cc (tostring k))
                                            #((. vim.lsp.codelens (tostring k)))
                                            {:desc (.. "[C]odelens" v)})))
             :settings {:haskell {:formattingProvider :fourmolu
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
                                           :splic {:globalOn true}}}}
             :default_settings {:haskell {:formattingProvider :fourmolu
                                          :sessionLoading  "multiComponent"
                                          :maxCompletions 10}}}})
