(import-macros {: set! : let!} :macros)
(if (vim.fn.executable :c3c)
    (let [compiler :c3c]
      (let! compiler :c3c)
      (let! makeprg :c3c)))

;(let! [:w] :cpo_save :cpo)
;(set! -cpo :C)
