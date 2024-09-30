(import-macros {: lzn!} :macros)

(lzn! :ufold {:nyoom-module editor.fold
              :deps [:psa]
              :keys [{1 :zR
                      2 #((. (autoload :ufo) :openAllFolds))
                      :desc "[O]pen [A]ll [F]olds"}
                     {1 :zM
                      2 #((. (autoload :ufo) :closeAllFolds))
                      :desc "[C]lose [A]ll [F]olds"}
                     {1 "z]"
                      2 #((. (autoload :ufo) :goNextClosedFold))
                      :desc "[N] [CF]old"}
                     {1 "z["
                      2 #((. (autoload :ufo) :goPreviousClosedFold))
                      :desc "[P] [CF]old"}
                     :za]})
