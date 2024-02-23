(import-macros {: let! : set!} :macros {: err!} :core.lib.io)

(local {: executable?} (autoload :core.lib))

;; load constants

(autoload :core.shared)

;; add userconfig to runtimepath
(set! rtp+ (.. (vim.loop.os_homedir) :/.config/nyoom))

;; Boot-strapping rocks
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
(set! rtp+ (vim.fs.joinpath rocks-config.rocks_path :lib :luarocks :rocks-5.1
                            :rocks.nvim))

;; NOTE:: (Hermit) Deprecating this, we don't need mason anymore
; (set vim.env.PATH (.. vim.env.PATH ":" (vim.fn.stdpath :data) :/mason/bin))
; (set vim.env.PATH (.. vim.env.PATH ":" (vim.fn.stdpath :config) :/bin))
(let! python3_host_prog (if (executable? :python) (vim.fn.exepath :python)
                            (executable? :python3) (vim.fn.exepath :python3)
                            nil))

;; check for cli

(local cli (os.getenv :NYOOM_CLI))

;; If its a cli instance, load package management
;; If its a regular instance, load defaults, userconfig and plugins

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
      (require :config)
      (require :packer_compiled)))

;; (require :pacttesting)
;; disable packer commands

; (fn disable-packer [command]
;   (fn first-to-upper [str]
;     (str:gsub "^%l" string.upper))
;
; (local packer-command (.. :Packer (first-to-upper command)))
;   (vim.api.nvim_create_user_command packer-command
;                                     (fn []
;                                       (err! "Please use the `nyoom` cli"))
;                                     {}))
;
; (let [packer-commands [:install :update :compile :sync :status :lockfile]]
;   (each [_ v (ipairs packer-commands)]
;     (disable-packer v)))))
