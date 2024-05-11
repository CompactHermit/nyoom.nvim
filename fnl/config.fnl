(require-macros :macros)
(import-macros {: >==} :util.macros)

;; NOTE:: We need to append on the luarocks cPath/lPath, or else we have to manually packadd the plugins
; (local rocks-config
;        {:luarocks_binary :luarocks
;         :rocks_path (.. (vim.fn.stdpath :data) :/rocks)})
;
; (vim.opt.runtimepath:append (vim.fs.joinpath rocks-config.rocks_path :lib
;                                              :luarocks :rocks-5.1 :rocks.nvim
;                                              "*"))

(colorscheme oxocarbon)
(set! background :dark)
;;   ┌──────────────────────┐
;;   │    CUSTOM Opts       │
;;   └──────────────────────┘

;;(vim.opt.guifont "Cascadia Code PL:w10, Symbols Nerd Font, Noto Color Emoji")

(set! guifont "Cascadia Code PL:w10, Symbols Nerd Font, Noto Color Emoji")

(set! gcr ["i-c-ci-ve:blinkoff500-blinkon500-block-TermCursor"
           "n-v:block-Curosr/lCursor"
           "o:hor50-Curosr/lCursor"
           "r-cr:hor20-Curosr/lCursor"])

(set! relativenumber)

(let! fennel_use_luajit true)
(let! maplocalleader " m")
(let! tex_conceal :abdgm)
(let! vimtex_view_mode :zathura)
(let! vimtex_view_general_viewer :zathura)
(let! vimtex_compiler_method :latexrun)
(let! vimtex_compiler_progname :nvr)
(let! tex_comment_nospell :1)
(let! vimtex_quickfix_mode :0)

;;   ┌───────────────────────────┐
;;   │        KEYBINDS           │
;;   └───────────────────────────┘

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

(autocmd! :RecordingEnter "*"
          #(vim.notify (.. "Recording Macro: (" (vim.fn.reg_recording) ")")))

(autocmd! :RecordingLeave "*" #(vim.notify "Finished recording Macro"))

;;   ┌──────────────────────┐
;;   │    CUSTOM AUTOCMDS   │
;;   └──────────────────────┘

(autocmd! :FileType :*.norg #(vim.opt.conceallevel 2))

(fn set-shiftwidth [filetype shiftwidth]
  (autocmd! :FileType filetype
            #(vim.cmd (string.format " setlocal expandtab tabstop=%d shiftwidth=%d softtabstop=%d "
                                     shiftwidth shiftwidth shiftwidth)
                      {:nested true})))

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
      :javascript
      :javascriptreact
      :javascript.jsx
      :typescript
      :typescriptreact
      :typescript.tsx
      :json
      :css
      :html
      :terraform
      :scheme
      :nix] #(set-shiftwidth $1 2))

;; Vim.g Options::
(let! typst_conceal_math 2)
(let! direnv_silent_load 1)
(let! sweetie {:overrides {}
               :integrations {:lazy true
                              :neorg true
                              :neogit true
                              :neomake true
                              :telescope true}
               :cursor_color true
               :terminal_colors true})
