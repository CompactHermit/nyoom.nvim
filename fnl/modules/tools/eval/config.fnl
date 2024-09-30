(import-macros {: let! : nyoom-module-p! : packadd!} :macros)
(let! maplocalleader :m)

(let! conjure#client#clojure#nrepl#eval#auto_require false)
(let! conjure#client#clojure#nrepl#connection#auto_repl#enabled true)
;:let g:conjure#mapping#prefix = ",c"

(if (nyoom-module-p! lsp)
    (let! conjure#mapping#doc_word :gK)
    (let! conjure#mapping#doc_word :K))

(nyoom-module-p! tree-sitter (let! conjure#extract#tree_sitter#enabled true))
