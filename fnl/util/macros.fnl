; fennel-ls: macro-file
;; fnlfmt:skip

(fn assert-tbl [tbl]
  "A simple sanity check"
  (assert-compile (or (table? tbl) (sym? tbl)) "tbl should be a table")
  tbl)

;; Method Threading::
(fn -m> [val ...]
  "Thread a value through a list of method calls ':' "
  (assert-compile val "There should be a value to add to threads")
  (accumulate [res val _ [f & args] (ipairs [...])]
    `(: ,res ,f ,(unpack args))))

;; Thread a maybe value -> call
(fn -m?> [val ...]
  "Thread (maybe) a value through a list of method calls"
  (assert-compile val "There should be an input value to the pipeline")
  (var res# (gensym))
  (var res `(do
              (var ,res# ,val)))
  (each [_ [f & args] (ipairs [...])]
    (table.insert res
                  `(when (and (not= nil ,res#) (not= nil (. ,res# ,f)))
                     (set ,res# (: ,res# ,f ,(unpack args))))))
  res)

;; TODO:: (Hermit) Use Vim.Iter
(fn -d> [mod ...]
  "Threads a module and calls a chain of requires, e.g:: 
    (-d> mod val1 val2) => ((. (. (require :mod) val1) val2 ...))
  "
  (assert-compile mod "There should be a module to require")
  (let [{method method? & args} [...]]
    `(do
       ((. (require ,mod) ,method?) ,args))))

;; Haskell-ish goodies, with even more slow O-times.
(fn >=> [tbl predicate? ?res]
  "Filter through a table and optionally append to a predefined result table
   NOTE: `predicate?` can take the key as a second argument
        This is equiveleant to (>=>) in haskell:: 
        Monad m => (a -> mb) -> (b -> m c) -> (a -> m c)

  "
  (assert-tbl tbl)
  (when ?res
    (assert-tbl ?res))
  (if (table? tbl)
      (do
        (var res (or ?res {}))
        (collect [k# v# (pairs tbl) &into res]
          (if (predicate? v# k#)
              (values k# v#)))
        (res))
      (sym? tbl)
      `(collect [k# v# (pairs ,tbl) &into (or ,?res {})]
         (if (,predicate? v# k#)
             (values k# v#)))))

;; Assert-seq
(fn assert-seq [seq]
  (assert-compile (or (table? seq) (sym? seq)) "seq should be a sequence" seq))

(fn apply [func args]
  (assert-seq args)
  `(,func ,(table.unpack args)))

(fn i>=> [seq predicate? ?res]
  "Filter through a sequence and optionally append to a predefined result sequence
    essentially, it's >=> in haskell, but for iterable tables
  "
  (assert-seq seq)
  (when ?res
    (assert-seq ?res))
  (if (sequence? seq)
      (do
        (var res (or ?res []))
        (icollect [i# v# (ipairs seq) &into res]
          (if (predicate? v#) v#))
        (res))
      (sym? seq)
      `(icollect [i# v# (ipairs ,seq) &into (or ,?res [])]
         (if (,predicate? v#) v#))))

(fn |> [val ...]
  "Pipeline a value/values through a series of functions"
  (assert-compile val "There should be an input value to the pipeline")
  (var res val)
  (each [_ v (ipairs [...])]
    (set res (list v res)))
  res)

(fn ||> [...]
  "Compose functions"
  (var res _VARARG)
  (each [_ v (ipairs [...])]
    (set res (list v res)))
  `(fn [,_VARARG] ,res))

(fn >== [tbl fun]
  "Consume a table by passing every element to a function
    essentially a concat on a table.
  e.g:: 
    (>== [:val1 :val2 :val3] (print $1)) => (print :val1),...,(print :val3)
       "
  (assert-tbl tbl)
  (if (table? tbl)
      (do
        (var res (list (sym :do)))
        (each [k# v# (pairs tbl)]
          (table.insert res `(,fun ,v#)))
        res)
      (sym? tbl)
      `(each [i# v# (pairs ,tbl)]
         (,fun v#))))

(fn i>== [seq fun]
  "Consume a sequence by passing every element to a function"
  (assert-seq seq)
  (if (sequence? seq)
      (do
        (var res (list (sym :do)))
        (each [i# v# (ipairs seq)]
          (table.insert res `(,fun ,v#)))
        res)
      (sym? seq)
      `(each [i# v# (ipairs ,seq)]
         (,fun v#))))

(fn map [tbl ...]
  "Map a table using a series of functions"
  (local fun (||> ...))
  (if (table? tbl)
      (do
        (var res {})
        (collect [k# v# (pairs tbl) &into res]
          (values k# `(fun ,v#)))
        res)
      ;; else
      `(collect [k# v# (pairs ,tbl) &into {}]
         (values k# (,fun v#)))))

(fn imap [seq ...]
  "Map a sequence using a series of functions"
  (local fun (||> ...))
  (if (sequence? seq)
      (do
        (var res [])
        (icollect [i# v# (ipairs seq) &into res]
          `(fun ,v#))
        res)
      ;; else
      `(icollect [i# v# (ipairs ,seq) &into []]
         (,fun v#))))

{: assert-tbl
 : assert-seq
 : apply
 :call apply
 : -d>
 : -m>
 : -m?>
 : >=>
 :filter >=>
 : i>=>
 :ifilter i>=>
 : |>
 :pipe |>
 : ||>
 :o ||>
 :compose ||>
 : >==
 :foreach >==
 : i>==
 :forieach i>==
 : map
 : imap}
