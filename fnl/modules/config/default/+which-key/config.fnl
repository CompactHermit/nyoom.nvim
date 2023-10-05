(local {: register} (autoload :which-key))

(setup :which-key {:icons {:breadcrumb "»" :separator "->" :group "+"}
                   :popup_mappings {:scroll_down :<c-d> :scroll_up :<c-u>}
                   :window {:border :solid}
                   :layout {:spacing 3}
                   :hidden [:<silent> :<cmd> :<Cmd> :<CR> :call :lua "^:" "^ "]
                   :triggers_blacklist {:i [:j :k] :v [:j :k]}
                   :height {:min 0 :max 6}
                   :align :center})

;; rename groups to mimick doom

(register {:<leader><tab> {:name :+workspace}})
(register {:<leader>a {:name :+Harpoooon}})
(register {:<leader>b {:name :+buffer}})
(register {:<leader>c {:name :+code}})
(register {:<leader>e {:name :+Flash}})
(register {:<leader>f {:name :+file}})
(register {:<leader>fe {:name :+movements}})
(register {:<leader>g {:name :+git}})
(register {:<leader>h {:name :+help}})
(register {:<leader>hn {:name :+nyoom}})
(register {:<leader>i {:name :+insert}})
(register {:<leader>n {:name :+notes}})
(register {:<leader>nc {:name :+roam}})
(register {:<leader>nt {:name :+Todos}})
(register {:<leader>nm {:name :+modes}})
(register {:<leader>nq {:name :+quicknote}})
(register {:<leader>nu {:name :+Exec}})
(register {:<leader>o {:name :+Octo}})
(register {:<leader>l {:name :+Overseer}})
(register {:<leader>p {:name :+project}})
(register {:<leader>q {:name :+quit/session}})
(register {:<leader>r {:name :+remote}})
(register {:<leader>s {:name :+Search}})
(register {:<leader>t {:name :+toggle}})
(register {:<leader>w {:name :+window}})
(register {:<leader>m {:name :+Conjure}})
(register {:<leader>d {:name :+debug}})
(register {:<leader>u {:name :+test}})
(register {:<leader>v {:name :+visual}})
(register {:<leader>z {:name :+Tmux}})
