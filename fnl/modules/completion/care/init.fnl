(import-macros {: lzn!} :macros)

(lzn! :care {:nyoom-module completion.care
             :event [:InsertEnter]
             :wants [:mini-icons]
             :deps [:friendly-luasnip
                    :luasnip
                    :luasnip_snippets
                    :haskell-snippets
                    :care-cmp
                    :cmp-path
                    :cmp-buffer
                    ;:cmp-cmdline
                    :cmp-luasnip
                    :nvim-scissors
                    :cmp-nvim-lsp]})

(lzn! :nvim-scissors
      {:keys [{1 :<space>cse
               2 #((. (require :scissors) :editSnippet))
               :desc "Edit Snippets"}
              {1 :<space>csc
               2 #((. (require :scissors) :addNewSnippet))
               :desc "Edit Snippets"}]
       ;;TODO:: Use `datadir`, we don't to edit packdir
       :after #((. (require :scissors) :setup) {:snippetDir "~/.config/nvim/snippets"})
       :cmd [:ScissorsEditSnippet :ScissorsAddNewSnippet]})
