(import-macros {: augroup! : autocmd! : local-set!} :macros)

(setup :neogit {:disable_signs true
                :disable_hint true
                :disable_context_highlighting false
                :integrations {:diffview true :telescope true}
                :sections {:recent {:folded true}}})

; TODO:: (CH) <10/06> Debug this.
; (augroup! neogit-config (autocmd! FileType Neogit* `(local-set! nolist))
;           (autocmd! [FileType BufEnter] NeogitCommitView
;                     `(local-set! evenitignore+ :CursorMoved))
;           (autocmd! BufLeave NeogitCommitView
;                     `(local-set! evenitignore- :CursorMoved)))
