(import-macros {: lzn! : lazyp} :macros)

; easy to use configurations for language servers

;; TODO:: Add proper `register_module` for custom defer
(lzn! :lspconfig {:nyoom-module tools.lsp
                  ;:event [:DeferredUIEnter]
                  :ft [:lua
                       :nix
                       :c
                       :h
                       :norg
                       :zig
                       :latex
                       :typst
                       :csharp
                       :rust
                       :haskell
                       :markdown]
                  :cmd [:LspInfo :LspLog :LspStart :LspRestart :LspStop]
                  :deps [:cmp-nvim-lsp]})

(lzn! :live-rename {:call-setup live-rename :on_require [:lsp-rename]})
(lzn! :lspsaga
      {:event :LspAttach
       :wants [:lspconfig]
       :after #((->> :setup (. (require :lspsaga))) {:winbar_toggle {:enable false}
                                                     :lightbulb {:enable false}})})
