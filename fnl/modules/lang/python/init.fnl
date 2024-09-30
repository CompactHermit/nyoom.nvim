;; REFACTOR::
; (use-package! :AckslD/swenv.nvim
;               {:nyoom-module lang.python
;                :ft [:python]
;                :cmd ["VenvFind" "GetVenv"]})
;
; (use-package! :kawre/leetcode.nvim
;               {:opt true
;                :cmd :Leet
;                :config (fn []
;                          ((->> :setup 
;                                (. (require :leetcode))) 
;                           {:lang [:c :cpp :rust :java :python]
;                            :logging true
;                            :image_support true}))})
;
; (use-package! :GCBallesteros/jupytext.nvim
;               {:opt true
;                :call-setup :jupytext})
;
