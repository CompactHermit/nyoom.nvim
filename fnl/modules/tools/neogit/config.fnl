(import-macros {: augroup! : autocmd! : local-set!} :macros)

(setup :neogit {:disable_signs false
                :disable_hint true
                :disable_context_highlighting false
                :disable_builtin_notifications true
                :telescope_sorter (fn []
                                    ((. (require :telescope) :extensions :fzf :native_fzf_sorter)))
                :signs {:section ["" ""]
                        :item ["" ""]
                        :hunk ["" ""]}
                :integrations {:diffview true :telescope true}
                :sections {:recent {:folded true}}
                :mappings {:status {:B :BranchPopup}}})

; TODO:: (CH) <10/06> Debug this.
(augroup! neogit-config (autocmd! FileType Neogit* `(local-set! nolist))
          (autocmd! [FileType BufEnter] NeogitCommitView
                    `(local-set! evenitignore+ :CursorMoved))
          (autocmd! BufLeave NeogitCommitView
                    `(local-set! evenitignore- :CursorMoved)))
