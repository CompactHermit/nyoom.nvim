(local {: register} (autoload :which-key))

((->> :setup (. (require :which-key))) {:icons {:breadcrumb "»"
                                                :separator "->"
                                                :group "+"}
                                        :popup_mappings {:scroll_down :<c-d>
                                                         :scroll_up :<c-u>}
                                        :window {:border :solid}
                                        :layout {:spacing 3}
                                        :hidden [:<silent>
                                                 :<cmd>
                                                 :<Cmd>
                                                 :<CR>
                                                 :call
                                                 :lua
                                                 "^:"
                                                 "^ "]
                                        :triggers_blacklist {:i [:j :k]
                                                             :v [:j :k]}
                                        :height {:min 0 :max 6}
                                        :align :center})

;; rename groups to mimick doom

(register {:<leader><tab> {:name :+workspace}})
(register {:<leader>c {:name :+code}})
(register {:<leader>cl {:name "+Code::Lsp"}})
(register {:<leader>ct {:name "Toggle LspLines"}})
(register {:<leader>b {:name :+buffer}})
(register {:<M-s> {:name :+flash}})
(register {:<leader>i {:name :+insert}})
(register {:<leader>n {:name "[Ne]org"}})
(register {:<leader>nc {:name :+roam}})
(register {:<leader>nt {:name "+[Ne]org [T]asks"}})
(register {:<leader>nm {:name "+[Ne]org [M]ode"}})
(register {:<leader>nq {:name :+quicknote}})
(register {:<leader>nu {:name "+[Ne]org [E]xec"}})
(register {:<leader>q {:name :+quit/session}})
(register {:<leader>r {:name :+remote}})
;(register {:<leader>s {:name :+Swap}})
(register {:<leader>S {:name :+Flash}})
(register {:<leader>t {:name :+toggle}})
(register {:<leader>w {:name :+window}})
(register {:<leader>m {:name :+Conjure}})
(register {:<leader>d {:name :+debug}})
(register {:<leader>u {:name :+test}})
(register {:<leader>v {:name :+visual}})
(register {:<leader>z {:name :+Tmux}})
