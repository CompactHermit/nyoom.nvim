(import-macros {: use-package!} :macros)

; view rust crate info with virtual text

(use-package! :saecki/crates.nvim
              {:opt true
               :call-setup crates
               :nyoom-module lang.rust
               :ft :rs
               :event ["BufRead Cargo.toml"]})

; (use-package! :mrcjkb/rustaceanvim
;               {:opt true :nyoom-module lang.rust :ft [:rust]})

;(use-package! :vxpm/ferris.nvim {:opt true :ft [:rust]})
