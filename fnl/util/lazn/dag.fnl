(let [undirected [{1 :lzn :deps [:name :val]}]
      DAG (setmetatable {} {})]
  (tset DAG :__index DAG)
  (tset DAG :new #(let [self (setmetatable {} DAG)]
                    (tset self :counter 1)
                    (tset self :nodes {})
                    self))
  (local z (DAG.new))
  (each [k v (pairs (DAG.new))]
    (print k v)))
