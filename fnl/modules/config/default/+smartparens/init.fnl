(import-macros {: lzn!} :macros)

;; Simple parenthesis matching
(lzn! :nvim-autopairs {:nyoom-module config.default.+smartparens
                       :event :InsertEnter})

; lua-based matchparen alternative
(lzn! :matchparens {:event :DeferredUIEnter :call-setup matchparen})
