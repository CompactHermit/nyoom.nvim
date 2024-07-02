(import-macros {: let! : set!} :macros {: err!} :core.lib.io)

(local {: executable?} (autoload :core.lib))

(autoload :core.shared)

; (let! python3_host_prog (if (executable? :python) (vim.fn.exepath :python)
;                             (executable? :python3) (vim.fn.exepath :python3)
;                             nil))

;; check for cli

(local cli (os.getenv :NYOOM_CLI))

(if cli
    (require :packages)
    (do
      ;; set opinionated defaults. TODO this should be in a module?
      (import-macros {: command! : let! : set!} :macros)
      ;; speedups
      (set! updatetime 250)
      (set! timeoutlen 400)
      ;; visual options
      (set! conceallevel 2)
      (set! infercase)
      (set! shortmess+ :sWcI)
      (set! signcolumn "yes:1")
      (set! formatoptions [:q :j])
      (set! nowrap)
      ;; just good defaults
      (set! splitright)
      (set! splitbelow)
      ;; tab options
      (set! tabstop 4)
      (set! shiftwidth 4)
      (set! softtabstop 4)
      (set! expandtab)
      ;; clipboard and mouse
      (set! clipboard :unnamedplus)
      (let! lz_n {:load vim.cmd.packadd})
      (set! mouse :a)
      ;; backups are annoying
      (set! undofile)
      (set! nowritebackup)
      (set! noswapfile)
      ;; external config files
      (set! exrc)
      (set! shell :nu)
      ;; search and replace
      (set! ignorecase)
      (set! smartcase)
      (set! gdefault)
      ;; better grep
      (set! grepprg "rg --vimgrep")
      (set! grepformat "%f:%l:%c:%m")
      (set! path ["." "**"])
      ;; previously nightly options
      (set! diffopt+ "linematch:60")
      (set! splitkeep :screen)
      ;; nightly only options
      ;; gui options
      (set! list)
      (set! fillchars {:eob " "
                       :vert " "
                       :horiz " "
                       :diff "╱"
                       :foldclose ""
                       :foldopen ""
                       :fold " "
                       :msgsep "─"})
      (set! listchars {:tab " ──"
                       :trail "·"
                       :nbsp "␣"
                       :precedes "«"
                       :extends "»"})
      (set! scrolloff 4)
      (let! neovide_padding_top 45)
      (let! neovide_padding_left 38)
      (let! neovide_padding_right 38)
      (let! neovide_padding_bottom 20)
      ;; load userconfig
      (require :packages)
      (require :config)))
