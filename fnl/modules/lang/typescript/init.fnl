(import-macros {: lzn!} :macros)

; (use-package! :pmizio/typescript-tools.nvim
;               {:nyoom-module lang.typescript
;                :opt true
;                :ft [:ts :tsc :typescript :typescriptreact]})

(lzn! :typescriptTools
      {:nyoom-module :lang.typescript
       :wants [:lspconfig]
       :ft [:ts :tsc :typescript :typescriptreact]})
