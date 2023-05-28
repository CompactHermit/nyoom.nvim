(import-macros {: use-package! : pack} :macros)

;; Quarto :: The bootleg mardown previewer::

;;TODO:: source otter into nvim-cmp
; (use-package! :jmbuhr/otter.nvim {:call-setup otter})

(use-package! :quarto-dev/quarto-nvim
               {:nyoom-module tools.quarto
                :requires [(pack :jmbuhr/otter.nvim {:call-setup otter.config})]
                :cmd [:QuartoPreview]})

