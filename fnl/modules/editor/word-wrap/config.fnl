(import-macros {: set! : local-set! : augroup! : clear! : autocmd! : map!}
               :macros)

(set! linebreak)
(set! breakindent)

(augroup! word-wrap (clear!) (autocmd! BufWinEnter *.md `(local-set! wrap))
          (autocmd! BufWinEnter *.txt `(local-set! wrap))
          (autocmd! BufWinEnter *.norg `(local-set! wrap))
          (autocmd! BufWinEnter *.org `(local-set! wrap))
          (autocmd! BufWinEnter *.tex `(local-set! wrap)))

((->> :setup
      (. (require :wrapping-paper))))

(map! [n] :gw `((->> :wrap_line
                     (. (require :wrapping-paper))))
      {:desc "Fake Wrap Line"})
