(import-macros {: use-package!} :macros)
(import-macros {: use-package!} :macros)

(use-package! :nvim-neorg/neorg {:nyoom-module lang.neorg 
                                 :ft :norg 
                                 :cmd :Neorg
                                 :requires [ :laher/neorg-codecap
                                             (pack :laher/neorg-exec)
                                             (pack :nvim-neorg/neorg-telescope)]})

; (use-package! :pysan3/neorg-templates-draft
;                {:ft :norg})
(use-package! :laher/neorg-codecap
              {:opt true
               :ft [:norg :fennel :rust :python :lua :haskell] ;; Just change this
               :requires [(pack :ruifm/gitlinker.nvim {:call-setup gitlinker})]
               ; :after :neorg
               :config (fn []
                         (local {: setup} (require :codecap))
                         (setup {:mappings {"<leader>ncv" :vsplit
                                            "<leader>ncs" :split
                                            "<leader>nce" :edit
                                            "<leader>ncn" :noshow
                                            "<leader>ncc" :inbox
                                            "<leader>ncd" :diff}}))})

;; Note:: This slows down performance, roughly ~600 ms, not worth it
; (use-package! :lukas-reineke/headlines.nvim {:opt true
;                                              :ft [:org :norg] 
;                                              :requires (pack :akinsho/org-bullets.nvim {:opt true})
;                                              :call-setup headlines})
