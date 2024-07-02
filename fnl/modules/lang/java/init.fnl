(import-macros {: lzn!} :macros)

; off-spec language server support for java
; (use-package! :mfussenegger/nvim-jdtls {:nyoom-module lang.java
;                                         :ft :java}) 
(lzn! :nvim-java/nvim-java {:opt true :nyoom-module lang.java})
