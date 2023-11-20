(import-macros {: use-package!} :macros)

; view rust crate info with virtual text

(use-package! :saecki/crates.nvim
              {:call-setup crates :event ["BufRead Cargo.toml"]})

(use-package! :mrcjkb/rustaceanvim {:opt true :ft [:rust]})

(use-package! :vxpm/ferris.nvim {:nyoom-module lang.rust :opt true :ft [:rust]})
