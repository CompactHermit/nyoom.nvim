(require-macros :macros)
(import-macros {: >==} :util.macros)

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

; The let option sets global, or `vim.g` options.
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
;; TODO:
(map! [n] :<esc> :<esc><cmd>noh<cr> {:desc "No highlight escape"})
(map! [n] :<C-n> :<cmd>Neotree<cr>)
(map! [n] :<A-i> "<cmd>ToggleTerm direction=float<cr>")

;;Yanky Killring stuff
(map! [n] :J "<Plug>(YankyCycleForward)")
(map! [n] :K "<Plug>(YankyCycleBackward)")
(map! [n] :p "<Plug>(YankyPutAfter)")
(map! [n] :P "<Plug>(YankyPutBefore)")
(map! [n] :gp "<Plug>(YankyGPutAfter)")
(map! [n] :<space>ct "<cmd>lua require('lsp_lines').toggle()<cr>")
;; The let option sets global, or `vim.g` options.
;; Heres an example with localleader, setting it to <space>m

; (let! maplocalleader " m")

(autocmd! :RecordingEnter "*" #(vim.notify (.. "Recording Macro: ("
                                               (vim.fn.reg_recording)
                                               ")")))

(autocmd! :RecordingLeave "*"  #(vim.notify "Finished recording Macro"))


;; Custom Autocmds::
(fn set-shiftwidth [filetype shiftwidth]
  (autocmd!
    :FileType
    filetype
    #(vim.cmd (string.format " setlocal expandtab tabstop=%d shiftwidth=%d softtabstop=%d "
                             shiftwidth
                             shiftwidth
                             shiftwidth))))


(augroup! neogit-config (autocmd! FileType Neogit* `(local-set! nolist))
          (autocmd! [FileType BufEnter] NeogitCommitView
                    `(local-set! evenitignore+ :CursorMoved))
          (autocmd! BufLeave NeogitCommitView
                    `(local-set! evenitignore- :CursorMoved)))
(>== [:haskell
      :norg
      :xml
      :xslt
      :xsd
      :fennel
      ;; :javascript
      ;; :javascriptreact
      ;; :javascript.jsx
      ;; :typescript
      ;; :typescriptreact
      ;; :typescript.tsx
      :json
      :css
      :html
      :terraform
      :scheme
      :nix]
     #(set-shiftwidth $1 2))


;; Custom Highlight Groups
; hi TreesitterContextBottom gui=underline guisp=Grey


