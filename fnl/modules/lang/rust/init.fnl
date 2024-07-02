(import-macros {: lzn!} :macros)

; view rust crate info with virtual text

;(nyoom-module! lang.rust)

(lzn! :rustaceanvim {:ft :rust
                     :wants [:toggleterm :dap]
                     :nyoom-module lang.rust})

(lzn! :crates {:event "BufRead Cargo.toml" :call-setup crates})
