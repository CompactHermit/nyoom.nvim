(import-macros {: nyoom-module!} :macros)

; view rust crate info with virtual text

;(use-package! :saecki/crates.nvim
;              {:opt true
;               :event ["BufReadPost Cargo.toml"]})
(nyoom-module! lang.rust)

; (use-package! :mrcjkb/rustaceanvim
;               {:opt true :nyoom-module lang.rust :ft [:rust]})

;(use-package! :vxpm/ferris.nvim {:opt true :ft [:rust]})
