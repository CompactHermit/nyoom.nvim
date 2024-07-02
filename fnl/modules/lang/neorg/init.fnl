(import-macros {: lzn!} :macros)

(lzn! :neorg {:nyoom-module lang.neorg
              :ft :norg
              :cmd [:Neorg]
              :on_require [:neorg :neorg.core]
              :wants [:truezen :telescope :otter :image-nvim :nvim-cmp]
              :deps [:lua-utils
                     :pathlib
                     :neorg-lines
                     :neorg-exec
                     :neorg-templates
                     :neorg-telescope
                     :neorg-interim-ls]})

; :neorg-se
; :neorg-timelog
; :neorg-hop-extras
; :neorg-roam

(lzn! :image-nvim
      {:ft [:md :norg]
       :on_require [:image]
       :enable #(not= vim.env.ZELLIJ 0)
       ;; Disable when zellij is on
       :after #((->> :setup (. (require :image))) {:backend :kitty
                                                   :integrations {:markdown {:enabled true
                                                                             :download_remote_images true
                                                                             :filetypes [:markdown
                                                                                         :quarto
                                                                                         :vimwiki]}
                                                                  :neorg {:enabled true
                                                                          :download_remote_images true
                                                                          :clear_in_insert_mode false
                                                                          :only_render_image_at_cursor false
                                                                          :filetypes [:norg]}}})})
