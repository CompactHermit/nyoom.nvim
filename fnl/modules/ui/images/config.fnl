(import-macros {: command! : nyoom-module-p!} :macros)

;; Current Backends:: Ueberzug/kitty/sixels
;; However, Ueberzug is too slow, and cant render movements fast enough
(setup :image {:backend :kitty
               :integrations {:markdown {:enabled true}
                              :neorg {:enabled true
                                      :download_remote_images true
                                      :clear_in_insert_mode false}}
               :kitty_method :normal
               :kitty_tmux_write_delay 10})


(nyoom-module-p! images
                 (do
                   (let [api (require :image)]
                     (fn mover [a]
                       (local x 5)
                       (local y 5)
                       (vim.ui.input {:default x :prompt "X-move::"}
                        (fn [xn]
                          (vim.ui.input {:default y :prompt "Y-Move::"}
                                        (fn [yn]
                                          (a:move xn yn))))))
                     (command! ImageMove `(mover) {:desc "Move Image with Image.nvim API"}))))

  ; (command! HarpoonMarks "lua require('harpoon.mark').add_file()" {:desc "Harpoon Add files"}))
