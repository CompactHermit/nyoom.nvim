(import-macros {: lzn!} :macros)

;; TODO:; Load Friendly-luasnip seperately
(lzn! :nvim-cmp {:nyoom-module completion.cmp
                 :deps [:friendly-luasnip
                        :luasnip
                        :luasnip_snippets
                        :haskell-snippets
                        :cmp-path
                        :cmp-buffer
                        :cmp-cmdline
                        :cmp-luasnip
                        :nvim-scissors
                        :cmp-conjure
                        :cmp-nvim-lsp]
                 :wants [:nvim-scissors :conjure]
                 :event :InsertEnter})

(lzn! :nvim-scissors
      {:keys [{1 :<space>cse
               2 #((. (require :scissors) :editSnippet))
               :desc "Edit Snippets"}
              {1 :<space>csc
               2 #((. (require :scissors) :addNewSnippet))
               :desc "Edit Snippets"}]
       :after #((. (require :scissors) :setup) {:snippetDir "~/.config/nvim/snippets"})
       :cmd [:ScissorsEditSnippet :ScissorsAddNewSnippet]})
