(import-macros {: lzn!} :macros)

; view rust crate info with virtual text

;(nyoom-module! lang.rust)

(lzn! :rustaceanvim {:ft :rust :wants :toggleterm})
(lzn! :crates {:event "BufRead Cargo.toml" :nyoom-module lang.rust})
