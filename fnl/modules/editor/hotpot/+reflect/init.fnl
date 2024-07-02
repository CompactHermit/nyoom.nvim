(import-macros {: lzn!} :macros)

(lzn! :HotPot-Reflect-API
      {:nyoom-module editor.hotpot.+reflect
       :load (fn [])
       :keys [{1 :mhn :mode :v :desc "[N]ew [Re]flect [Se]ssion"}
              {1 :mhx :desc "[Sw]ap [Re]flect [M]ode"}]})
