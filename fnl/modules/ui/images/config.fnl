(import-macros {: command! : nyoom-module-p!} :macros)

(setup :image {:backend :kitty
               :integrations {:markdown {:enabled true}
                              :neorg {:enabled true
                                      :download_remote_images true
                                      :clear_in_insert_mode false
                                      :only_render_image_at_cursor false
                                      :filetypes [:norg]}}})


