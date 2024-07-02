(import-macros {: lzn!} :macros)

(lzn! :quarto {:nyoom-module tools.quarto
               :ft [:md]
               :cmd [:QuartoPreview]
               :wants [:lspconfig :otter :cmp :nvim-treesitter]})

(lzn! :otter
      {:ft [:norg :md]
       :on_require [:otter]
       :after #((->> :setup (. (autoload :otter))) {:handle_leading_whitespace true
                                                    :lsp {:hover {:border :none}}
                                                    :buffers {:write_to_disk true}})})
