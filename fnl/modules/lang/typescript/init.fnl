(import-macros {: use-package!} :macros)

(use-package! :pmizio/typescript-tools.nvim
              {:nyoom-module lang.typescript
               :opt true
               :ft [:ts :tsc :typescript :typescriptreact]
               :requires :neovim/nvim-lspconfig})
