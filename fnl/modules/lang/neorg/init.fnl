(import-macros {: lzn!} :macros)

(lzn! :neorg {:nyoom-module lang.neorg
              :ft :norg
              :cmd [:Neorg]
              :wants [:truezen :telescope]
              :deps [:lua-utils
                     :image-nvim
                     :pathlib
                     :telescope
                     :neorg-lines
                     :neorg-exec
                     :neorg-telescope
                     :neorg-roam
                     :neorg-timelog
                     :neorg-hop-extras
                     :neorg-interim-ls]})
