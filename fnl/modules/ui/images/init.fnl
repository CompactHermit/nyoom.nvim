(import-macros {: use-package! } :macros)

(use-package! :3rd/image.nvim
              {:nyoom-module ui.images
               :opt true
               :event :BufWritePost})
