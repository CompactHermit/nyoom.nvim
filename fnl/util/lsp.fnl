(fn lsp_init [client]
  (vim.notify "BloatWare(TM) has been started, ya fucker!!"
              :info
              {:title client.name}))

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
                                     :detail :additionalTextEdits]}})

{: capabilities
 : lsp_init}
 
