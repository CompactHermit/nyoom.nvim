(import-macros {: lzn!} :macros)

;; TODO:; Load Friendly-luasnip seperately
(lzn! :nvim-cmp {:nyoom-module completion.cmp
                 :deps [:friendly-luasnip
                        :luasnip
                        :haskell-snippets
                        :cmp-path
                        :cmp-buffer
                        :cmp-cmdline
                        :cmp-luasnip
                        :cmp-nvim-lsp]
                 :event :InsertEnter})
