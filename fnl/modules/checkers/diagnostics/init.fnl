(import-macros {: lzn!} :macros)

(lzn! :nonels {:nyoom-module checkers.diagnostics
               :wants [:lspconfig]
               :deps [:lsplines]
               :event [:BufReadPost]})

; (lzn! :lsp-better-diag
;       {:event :LspAttach
;        :after #((. (require :better-diagnostic-virtual-text) :setup) {:ui {:wrap_line_after false
;                                                                            :arrow "󰞔"
;                                                                            :above true
;                                                                            :down_arrow ""
;                                                                            :up_arrow ""}
;                                                                       :inline false})})
; (lzn! :lsplines {:keys {1 :<C-t> :desc "[To]ggle [D]iagnostics"}
;                  :call-setup lsp_lines})
