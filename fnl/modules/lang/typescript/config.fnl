(setup :typescript-tools
       {:settings {:expose_as_code_action [:organize_imports :remove_unused]
                   :publish_diagnostic_on :insert_leave
                   :separate_diagnostic_server true
                   :tsserver_file_preferences {:includeInlayEnumMemberValueHints true
                                               :includeInlayFunctionLikeReturnTypeHints false
                                               :includeInlayFunctionParameterTypeHints true
                                               :includeInlayParameterNameHints :literal
                                               :includeInlayParameterNameHintsWhenArgumentMatchesName false
                                               :includeInlayPropertyDeclarationTypeHints true
                                               :includeInlayVariableTypeHints true
                                               :includeInlayVariableTypeHintsWhenTypeMatchesName false}
                   :tsserver_max_memory 8096}
        :on_attach (fn [client bufnr]
                     (set client.server_capabilities.documentFormattingProvider
                          false)
                     (set client.server_capabilities.documentRangeFormattingProvider
                          false)
                     (tset client.handlers :textDocument/definition
                           (fn [err result ...]
                             (var patched-result {})
                             (local target-path-line-map {})
                             (if (and (or (vim.islist result)
                                          (= (type result) :table))
                                      (> (length result) 1))
                                 (let [internal-entries {}
                                       external-entries {}]
                                   (each [_ v (ipairs result)]
                                     (local target-path v.targetUri)
                                     (local target-line
                                            v.targetRange.start.line)
                                     (when (not (. target-path-line-map
                                                   target-path))
                                       (tset target-path-line-map target-path
                                             {}))
                                     (local mapped-target-lines
                                            (. target-path-line-map target-path))
                                     (when (not (. mapped-target-lines
                                                   target-line))
                                       (tset mapped-target-lines target-line
                                             true)
                                       (if (= (vim.fn.stridx target-path
                                                             :node_modules)
                                              (- 1))
                                           (table.insert internal-entries v)
                                           (table.insert external-entries v))))
                                   (set patched-result
                                        (or (and (vim.tbl_isempty internal-entries)
                                                 external-entries)
                                            internal-entries)))
                                 (set patched-result result))
                             ((. vim.lsp.handlers :textDocument/definition) err
                                                                            patched-result
                                                                            ...))))})
