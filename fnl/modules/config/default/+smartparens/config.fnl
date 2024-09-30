(local lisp-ft [:fennel :clojure :lisp :racket :scheme])
(let [npair (require :nvim-autopairs)
      setup npair.setup
      care (require :care)]
  (setup {:disable_filetype lisp-ft
          :map_cr false
          :map_bs false
          :map_c_h false
          :map_c_w false})
  (vim.keymap.set :i :<cr>
                  #(if ((. care :api :is_open))
                       ((. care :api :confirm))
                       (vim.fn.feedkeys ((. npair :autopairs_cr)) :in))))
