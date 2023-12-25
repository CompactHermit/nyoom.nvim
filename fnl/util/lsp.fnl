
(fn lsp_init [client bufnr]
  "The Lsp Init Functions. This exposes 2 callbacks::
    - Notify:: If the LSP works/attaches
    - Inlay Hint Handler:: If the LSP's metatable contains inlay hints,
    "
  ;(vim.notify "BloatWare(TM) has been started" :info {:title client.name})
  (when client.server_capabilities.inlayHintProvider (vim.lsp.inlay_hint.enable bufnr true)))

;; Helper attach functions::
(local diags vim.diagnostic)

(fn diag_line [opts]
  (diags.open_float (vim.tbl_deep_extend :keep (or opts {}) {:scope :line})))

(fn hover [handler]
  ;; TODO:: refactor this
  (when (= (type handler) :table)
    (local config handler)
    (set-forcibly! handler
                   (fn [err result ctx]
                     (vim.lsp.handlers.hover err result ctx config))))
  (local params (vim.lsp.util.make_position_params))
  (vim.lsp.buf_request 0 :textDocument/hover params handler))

(local capabilities (vim.lsp.protocol.make_client_capabilities))
(set capabilities.textDocument.completion.completionItem
     {:documentationFormat [:markdown :plaintext]
      :snippetSupport true
      :preselectSupport true
      :insertReplaceSupport true
      :labelDetailsSupport true
      :deprecatedSupport true
      :commitCharactersSupport true
      :tagSupport {:valueSet {1 1}}
      :resolveSupport {:properties [:documentation
                                    :detail
                                    :additionalTextEdits]}})

{: capabilities : lsp_init : diag_line : hover}
