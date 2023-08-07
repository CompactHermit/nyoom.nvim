; (setup :typescript-tools
;        {:handlers {:textDocuments/definition (fn [err result method ...]
;                                                (print "Testing Definition")
;                                                ((. vim.lsp.handlers :textDocuments/definition) err method ...))
;                    :textDocuments/hover (vim.lsp.with (fn []
;                                                         (print :test)) {:silent true})}})
