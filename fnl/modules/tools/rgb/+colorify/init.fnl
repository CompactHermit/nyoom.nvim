(import-macros {: lzn!} :macros)

(lzn! :colorify {:load #(values nil)
                 :nyoom-module tools.rgb.+colorify
                 :cmd [:Colorify]
                 :lazy true
                 :priority 50})
