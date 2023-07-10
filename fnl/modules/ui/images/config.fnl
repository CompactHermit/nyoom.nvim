;; Current Backends:: Ueberzug/kitty/sixels
(setup :image {:backend :kitty
               :integrations {:markdown {:enabled true}
                              :neorg {:enabled true
                                      :download_remote_images true
                                      :clear_in_insert_mode false}}
               :kitty_method :normal
               :kitty_tmux_write_delay 10})
