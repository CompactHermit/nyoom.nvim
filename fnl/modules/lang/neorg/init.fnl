(import-macros {: use-package!} :macros)

(use-package! :nvim-neorg/neorg {:nyoom-module lang.neorg 
                                 :ft :norg 
                                 :cmd :Neorg})

; (use-package! :pysan3/neorg-templates-draft
;                {:ft :norg})
(use-package! :laher/neorg-codecap
              {:ft [:norg]
               :requires [(pack :ruifm/gitlinker.nvim {:call-setup gitlinker})]
               :config (fn []
                         (local {: setup} (require :codecap))
                         (setup {:mappings {"<leader>ncv" :vsplit
                                            "<leader>ncs" :split
                                            "<leader>nce" :edit
                                            "<leader>ncn" :noshow
                                            "<leader>ncc" :inbox
                                            "<leader>ncd" :diff}}))})
