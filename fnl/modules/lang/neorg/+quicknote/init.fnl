(import-macros {: use-package!} :macros)

(use-package! :RutaTang/quicknote.nvim
              {:nyoom-module lang.neorg.+quicknote
               :event :BufReadPost
               :init (fn []
                       (local quicknote_path (.. (vim.fn.stdpath :state) "/quicknote"))
                       (when (not (vim.loop.fs_stat quicknote-path))
                         (vim.fn.system [:mkdir quicknote_path])))
               :dependencies [:nvim-lua/plenary.nvim]})
