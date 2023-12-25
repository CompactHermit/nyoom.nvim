(import-macros {: use-package!} :macros)

; view rust crate info with virtual text

(use-package! :saecki/crates.nvim
              {:call-setup crates :event ["BufRead Cargo.toml"]})

(use-package! :mrcjkb/rustaceanvim
              {:opt true :nyoom-module lang.rust :ft [:rust]})

;(use-package! :vxpm/ferris.nvim {:opt true :ft [:rust]})
