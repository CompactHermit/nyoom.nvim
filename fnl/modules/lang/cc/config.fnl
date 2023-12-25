(local icons _G.shared.codicons)
(local diags _G.shared.icons)
(setup :clangd_extensions {:inline true
                           :extensions {:autoSetHints false
                                        :inlay_hints {:only_current_line  true
                                                      :highlight :LspInlayHint}
                                        :ast  {:role_icons {:type  icons.Type
                                                            :declaration  icons.Function
                                                            :expression  icons.Snippet
                                                            :specifier  icons.Specifier
                                                            :statement  icons.Statement
                                                            :template icons.TypeParameter}
                                               :kind_icons {:Compound  icons.Namespace
                                                            :Recovery  icons.DiagnosticSignError
                                                            :TranslationUnit  icons.Unit
                                                            :PackExpansion  icons.Ellipsis
                                                            :TemplateTypeParm  icons.TypeParameter
                                                            :TemplateTemplateParm  icons.TypeParameter
                                                            :TemplateParamObject  icons.TypeParameter}}}
                                       :memory_usage {:border :solid}
                                       :symbol_info  {:border :solid}})
  
 

