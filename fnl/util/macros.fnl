;; Opinionated Macros, for the hermit::

(fn assert-tbl [tbl]
  "A simple sanity check"
  (assert-compile 
    (or
      (table? tbl)
      (sym? tbl))
    "tbl should be a table")
  tbl)

;; Method Threading::
(fn -m> [val ...]
  "Thread a value through a list of method calls ':' "
  (assert-compile 
    val
    "There should be a value to add to threads")
  (accumulate [res val
                   _ [f & args] (ipairs [...])]
    `(: ,res ,f ,(unpack args))))

;; Table call Threading::
(fn -d> [tbl val ...]
  "Threads a table and calls a chain of requires, e.g:: 
    (-d> val1 val2 val3) => ((. (. (require :val1)val2) val3 ...))
  "
  (assert-tbl tbl))

;; Haskell-ish goodies, with even more slow O-times.
(fn >=> [tbl predicate? ?res]
  "Filter through a table and optionally append to a predefined result table
  This is equiveleant to (>=>) in haskell:: 
  Monad m => (a -> mb) -> (b -> m c) -> (a -> m c)
  "
  (assert-tbl tbl)
  (when ?res
    (assert-tbl ?res))
  (if (table? tbl)
      (do
        (var res (or ?res {}))
        (collect [k# v# (pairs tbl)
                  &into res]
          (if (predicate? v# k#)
            (values k# v#)))
        (res))
      (sym? tbl)
      `(collect [k# v# (pairs ,tbl)
                 &into (or ,?res {})]
         (if (,predicate? v# k#)
          (values k# v#)))))

{: -m>
 : -d>
 : >=>}
