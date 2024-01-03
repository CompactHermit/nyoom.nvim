(require-macros :macros)
(import-macros {: >==} :util.macros)

(local rocks-config
       {:luarocks_binary :luarocks
        :rocks_path (.. (vim.fn.stdpath :data) :/rocks)})

(set vim.g.rocks_nvim rocks-config)
(local luarocks-path [(vim.fs.joinpath rocks-config.rocks_path :share :lua :5.1
                                       :?.lua)
                      (vim.fs.joinpath rocks-config.rocks_path :share :lua :5.1
                                       "?" :init.lua)])

(set package.path (.. package.path ";" (table.concat luarocks-path ";")))
(local luarocks-cpath [(vim.fs.joinpath rocks-config.rocks_path :lib :lua :5.1
                                        :?.so)
                       (vim.fs.joinpath rocks-config.rocks_path :lib64 :lua
                                        :5.1 :?.so)])

(set package.cpath (.. package.cpath ";" (table.concat luarocks-cpath ";")))
(vim.opt.runtimepath:append (vim.fs.joinpath rocks-config.rocks_path :lib
                                             :luarocks :rocks-5.1 :rocks.nvim))

(colorscheme oxocarbon)
(set! background :dark)
;;   ┌──────────────────────┐
;;   │    CUSTOM AUTOCMDS   │
;;   └──────────────────────┘

(set! gcr ["i-c-ci-ve:blinkoff500-blinkon500-block-TermCursor"
           "n-v:block-Curosr/lCursor"
           "o:hor50-Curosr/lCursor"
           "r-cr:hor20-Curosr/lCursor"])

(set! relativenumber)
(set! conceallevel 2)

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

(let! typst_conceal_math 2)
