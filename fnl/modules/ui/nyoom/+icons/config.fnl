(import-macros {: packadd!} :macros)

; (local new-icons {:norg {:icon "" :color "#4878be" :name :neorg}
;                   :ncl {:icons "" :color "#4878be" :name :nickel}
;                   :py {:icon ""
;                        :color "#ffbc03"
;                        :cterm_color :214
;                        :name :Py}})

;((->> :setup (. (autoload :nvim-web-devicons))) {:override new-icons})

;; fnlfmt: skip
((->> :setup
      (. (autoload :mini.icons))) {:style :glyph
                                   :extension {:lua {:hl :MiniIconsBlue}
                                               :justfile {:glyph "󰖷" :hl :MiniIconsGrey}
                                               :lock {:glyph "" :hl :MiniIconsYellow}
                                               :norg {:glyph ""
                                                      :hl :MiniIconsBlue}}})

((->> :mock_nvim_web_devicons (. (autoload :mini.icons))))
