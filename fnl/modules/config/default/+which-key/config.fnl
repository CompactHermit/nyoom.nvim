;(local {: register} (autoload :which-key))
(local {: add : setup : show} (autoload :which-key))

; - `popup_mappings`
;   - `window`
;   - `hidden`
;   - `triggers_blacklist`
(setup {:icons {:breadcrumb "»" :separator "->" :group "+"}
        :preset :classic
        :layout {:spacing 3}
        :height {:min 0 :max 6}
        :align :center})

(add [{1 :<leader><tab> :group :+workspace}
      {1 :<leader>c :group :+code}
      {1 :<leader>cl :group "+Code::Lsp"}
      {1 :<leader>ct :group "Toggle LspLines"}
      {1 :<leader>b :group :+buffer}
      {1 :<M-s> :group :+flash}
      {1 :<leader>i :group :+insert}
      {1 :<leader>n :group "[Ne]org"}
      {1 :<leader>nc :group :+roam}
      {1 :m :group "[Co]njure [E]val"}
      {1 :<leader>nt :group "+[Ne]org [T]asks"}
      {1 ";t" :group "[Hy]dra [Tel]escope"}
      {1 :g :group "[Ju]mp To"}
      {1 :z :group "[F]old"}
      {1 :<leader>nm :group "+[Ne]org [M]ode"}
      {1 :<leader>nq :group :+quicknote}
      {1 :<leader>nu :group "+[Ne]org [E]xec"}
      {1 :<leader>q :group :+quit/session}
      {1 :<leader>r :group :+remote}
      {1 :<leader>s :group :+Swap}
      {1 :<leader>S :group :+Flash}
      {1 :<leader>l :group :+toggle}
      {1 :<leader>t :group :+toggle}
      {1 :<leader>w :group :+window}
      {1 :<leader>m :group :+Conjure}
      {1 :<leader>d :group :+debug}
      {1 :<leader>u :group :+test}
      {1 :<leader>v :group :+visual}
      {1 :<leader>z :group :+Tmux}])

; (register {:<leader><tab> {:name :+workspace}})
; (register {:<leader>c {:name :+code}})
; (register {:<leader>cl {:name "+Code::Lsp"}})
; (register {:<leader>ct {:name "Toggle LspLines"}})
; (register {:<leader>b {:name :+buffer}})
; (register {:<M-s> {:name :+flash}})
; (register {:<leader>i {:name :+insert}})
; (register {:<leader>n {:name "[Ne]org"}})
; (register {:<leader>nc {:name :+roam}})
; (register {:<leader>nt {:name "+[Ne]org [T]asks"}})
; (register {:<leader>nm {:name "+[Ne]org [M]ode"}})
; (register {:<leader>nq {:name :+quicknote}})
; (register {:<leader>nu {:name "+[Ne]org [E]xec"}})
; (register {:<leader>q {:name :+quit/session}})
; (register {:<leader>r {:name :+remote}})
; ;(register {:<leader>s {:name :+Swap}})
; (register {:<leader>S {:name :+Flash}})
; (register {:<leader>t {:name :+toggle}})
; (register {:<leader>w {:name :+window}})
; (register {:<leader>m {:name :+Conjure}})
; (register {:<leader>d {:name :+debug}})
; (register {:<leader>u {:name :+test}})
; (register {:<leader>v {:name :+visual}})
; (register {:<leader>z {:name :+Tmux}})
