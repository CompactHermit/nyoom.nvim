(import-macros {: lzn!} :macros)

(lzn! :nonels {:nyoom-module checkers.diagnostics
               :wants [:lspconfig]
               :event [:BufReadPost]})

(lzn! :lsp-better-diag
      {:event :LspAttach
       :after #((. (require :better-diagnostic-virtual-text) :setup) {:ui {:wrap_line_after true
                                                                           :arrow "󰞔"
                                                                           :down_arrow ""
                                                                           :up_arrow ""}
                                                                      :priority 2010
                                                                      :inline true})})
