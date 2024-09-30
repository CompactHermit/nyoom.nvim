(import-macros {: lzn!} :macros)

;(lzn! :typst-tools {:nyoom-module lang.typst :ft :typst})

(lzn! :typst-preview {:nyoom-module lang.typst
                      :ft :typst
                      :cmd [:TypstPreview
                            :TypstPreviewStop
                            :TypstPreviewToggle]})
