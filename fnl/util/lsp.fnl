(fn lsp_init [client bufnr]
  "The Lsp Init Functions. This exposes 2 callbacks::
    - Notify:: If the LSP works/attaches
    - Inlay Hint Handler:: If the LSP's metatable contains inlay hints,
    "
  ;(vim.notify "BloatWare(TM) has been started" :info {:title client.name})
  (when client.server_capabilities.inlayHintProvider
    (vim.lsp.inlay_hint.enable)))

;; Helper attach functions::
(local diags vim.diagnostic)

(fn diag_line [opts]
  (diags.open_float (vim.tbl_deep_extend :keep (or opts {}) {:scope :line})))

; (fn hover [handler]
;   ;; TODO:: refactor this
;   (when (= (type handler) :table)
;     (local config handler)
;     (set-forcibly! handler
;                    (fn [err result ctx]
;                      (vim.lsp.handlers.hover err result ctx config))))
;   (local params (vim.lsp.util.make_position_params))
;   (vim.lsp.buf_request 0 :textDocument/hover params handler))
;

(fn __SpacedMarkdown [_file]
  (if (= _file.kind :markdown)
      (tset _file :value (string.gsub _file.value "%[([^%]]+)%]%(([^%)]+)%)"
                                      "[%1]")))
  _file)

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

(let [previous-handler (. vim.lsp.handlers :textDocument/hover)]
  (tset vim.lsp.handlers :textDocument/hover
        (fn [a result b c]
          (if (not (and result result.contents))
              (previous-handler a result b c)
              (let [new-contents (__SpacedMarkdown result.contents)]
                (tset result :contents new-contents)
                (previous-handler a result b c))))))

{: capabilities : lsp_init : diag_line}
