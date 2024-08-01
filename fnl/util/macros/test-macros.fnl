;; fennel-ls: macro-file

;; TODO::(Hermit) Use `_VARARG`
(lambda t [?descModname ?itName ?temps ?asserts ...]
  {:fnl/docstring "_M :: test!
        ---@param ?descModname string|(fun():string)
        ---@param ?asserts Array<T>: {[fun():boolean]}
        ---@params ?temps Array<T>: {[fun():string:nil]}

        A single `describe` unit. The function will take _VARARG's as either a `It{}|string` as the head arg.
            If it's a table, unpack each as it's own `it` unit, else simple return the underlying.
        Each `It{}` table consists of the following::
            ```fennel
            {:it name
             :?asserts (fn [])
             :?before (fn [])
             }```
    This makes
    "
   :fnl/arglist [?descModname ?itName ?temps]}
  (assert-compile (sym? ?descModname) "expected <symbol> for _describe_"
                  ?descModname)
  (assert-compile (type (varg? ...) :function)
                  "expected <functions> for _assert_ calls")
  (let [modString (: "describe (\"%s\", function()
                          it(\"%s\", function()
                                    %s
                                 end)
                          end)" :format ?descModname
                     ?itName ?asserts)]
    `(lua ,modString)))

{: t}
