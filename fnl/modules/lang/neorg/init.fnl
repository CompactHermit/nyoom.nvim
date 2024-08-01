(import-macros {: lzn!} :macros)

(lzn! :neorg {:nyoom-module lang.neorg
              :ft :norg
              :cmd [:Neorg]
              :on_require [:neorg :neorg.core]
              :wants [:truezen :telescope :otter :image-nvim :nvim-cmp]
              :deps [:lua-utils
                     ;; TODO:: (Hermit) Add this to package.path, since this isn't too heavy as a dependency
                     :neorg-extras
                     :neorg-lines
                     :neorg-exec
                     :neorg-templates
                     :neorg-telescope
                     :neorg-interim-ls]})

; :neorg-se
; :neorg-timelog
; :neorg-hop-extras
; :neorg-roam
;(lzn! :neorg-extras {:cmd :NeorgExtras :call-setup neorg-extras})

(lzn! :diagram-nvim
      {:ft [:markdown :norg]
       :wants [:image-nvim]
       :enable #(vim.fn.executable :mmdc)
       :after #((->> :setup (. (require :diagram))) {:renderer_options {:mermaid {:background :transparent
                                                                                  :theme :neutral
                                                                                  :scale 1}}})})

(lzn! :image-nvim
      {:ft [:markdown :norg]
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
