(require-macros :macros)

;; You can use the `colorscheme` macro to load a custom theme, or load it manually
;; via require. This is the default:

(set! background :dark)
(colorscheme oxocarbon)

;; The set! macro sets vim.opt options. By default it sets the option to true 
;; Appending `no` in front sets it to false. This determines the style of line 
;; numbers in effect. If set to nonumber, line numbers are disabled. For 
;; relative line numbers, set 'relativenumber`

(set! relativenumber)
(set! conceallevel 2)

;; The let option sets global, or `vim.g` options. 
;; Heres an example with localleader, setting it to <space>m
(let! maplocalleader " m")
(let! tex_conceal :abdgm)
(let! vimtex_view_mode :zathura)
(let! vimtex_view_general_viewer :zathura)
(let! vimtex_compiler_method :latexrun)
(let! vimtex_compiler_progname :nvr)
(let! tex_comment_nospell :1)
(let! vimtex_quickfix_mode :0)

;; map! is used for mappings
;; Heres an example, preseing esc should also remove search highlights
(map! [n] :<esc> :<esc><cmd>noh<cr> {:desc "No highlight escape"})
(map! [n] :<C-n> :<cmd>NeoTreeFocusToggle<cr>)
(map! [n] :<A-i> "<cmd>ToggleTerm direction=float<cr>")

;;Yanky Killring stuff
(map! [n] :<C-j> "<Plug>(YankyCycleForward)")
(map! [n] :<C-k> "<Plug>(YankyCycleBackward)")
(map! [n] :p "<Plug>(YankyPutAfter)")
(map! [n] :P "<Plug>(YankyPutBefore)")
(map! [n] :gp "<Plug>(YankyGPutAfter)")
(map! [n] :<leader>ct "<cmd>lua require('lsp_lines').toggle()<cr>")
;; The let option sets global, or `vim.g` options. 
;; Heres an example with localleader, setting it to <space>m

(let! maplocalleader " m")

;; sometimes you want to modify a plugin thats loaded from within a module. For 
;; this you can use the `after` function


