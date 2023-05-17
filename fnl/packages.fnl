(import-macros {: packadd!
                : pack
                : rock
                : use-package!
                : rock!
                : nyoom-init-modules!
                : nyoom-compile-modules!
                : unpack!
                : autocmd!} :macros)

(packadd! packer.nvim)
(local {: build} (autoload :hotpot.api.make))
(local {: init} (autoload :packer))
(local {: echo!} (autoload :core.lib.io))

;; Load packer

(echo! "Loading Packer")
(local headless (= 0 (length (vim.api.nvim_list_uis))))
(init {;; :lockfile {:enable true
       ;;            :path (.. (vim.fn.stdpath :config) :/lockfile.lua)}
       :compile_path (.. (vim.fn.stdpath :config) :/lua/packer_compiled.lua)
       :auto_reload_compiled false
       :display {:non_interactive headless}})

;; compile healthchecks

(echo! "Compiling Nyoom Doctor")
(build (vim.fn.stdpath :config) {:verbosity 0}
       (.. (vim.fn.stdpath :config) :/fnl/core/doctor.fnl)
       (fn []
         (.. (vim.fn.stdpath :config) :/lua/health.lua)))

;; packer can manage itself

;; (use-package! :EdenEast/packer.nvim {:opt true :branch :feat/lockfile})
(use-package! :wbthomason/packer.nvim {:opt true})

;; libraries

(use-package! :nvim-lua/plenary.nvim {:module :plenary})
(use-package! :MunifTanjim/nui.nvim {:module :nui})
(use-package! :nyoom-engineering/oxocarbon.nvim)

;; include modules

(echo! "Initializing Module System")
(include :fnl.modules)
(nyoom-init-modules!)

;; To install a package with Nyoom you must declare them here and run 'nyoom sync'
;; on the command line, then restart nvim for the changes to take effect
;; The syntax is as follows: 

;; (use-package! :username/repo {:opt true
;;                               :defer reponame-to-defer
;;                               :call-setup pluginname-to-setup
;;                               :cmd [:cmds :to :lazyload]
;;                               :event [:events :to :lazyload]
;;                               :ft [:ft :to :load :on]
;;                               :requires [(pack :plugin/dependency)]
;;                               :run :commandtorun
;;                               :as :nametoloadas
;;                               :branch :repobranch
;;                               :setup (fn [])
;;                                        ;; same as setup with packer.nvim)})
;;                               :config (fn [])})
;;                                        ;; same as config with packer.nvim)})

;; ---------------------
;; Put your plugins here
;; ---------------------

(use-package! :nvim-neorg/neorg-telescope)
; (use-package! :NFrid/due.nvim
;               {:config (fn []
;                          (local {: setup} (require :due_nvim))
;                          (setup {:pattern_start "{"
;                                  :pattern_end "}"
;                                  :use_clock_time true
;                                  :use_clock_today true}))
;                :opt true
;                :cmd [:DueDraw :DueClean :DueSync]})

;; Broken and Slow
; (use-package! :iurimateus/luasnip-latex-snippets.nvim
;               {:requires [:L3MON4D3/LuaSnip :lervag/vimtex]
;                :call-setup luasnip-latex-snippets
;                :ft [:tex :markdown :norg]})

;; Bloated when not in use
; (use-package! :danymay/neogen {:call-setup neogen
;                                :opt true
;                                :cmd [:Neogen]})
;
;; Not needed at all
; (use-package! :nullchilly/fsread.nvim
;               {:opt true
;                :cmd [:FSRead]})

;; markdown stuff
(use-package! :toppair/peek.nvim
              {:run "deno task --quiet build:fast"
               :config (fn []
                         (local {: setup} (require :peek))
                         (setup {:throttle_at 200000}))
               :ft [:markdown]})

;; LSP-SAGA - The based lsp setup
(use-package! :glepnir/lspsaga.nvim
              {:config (fn []
                         (local {: setup} (require :lspsaga))
                         (setup {:request_timeout 2000
                                 :lightbulb {:enable false}}))
               :opt true
               :cmd [:Lspsaga]})

; Smart movements
(use-package! :mrjones2014/smart-splits.nvim
          {:call-setup smart-splits
           :opt true
           :events :BufReadPost})

;;SilverSurfer Nvim
(use-package! :kelly-lin/telescope-ag {:requires "nvim-telescope/telescope.nvim"
                                       :opt true
                                       :cmd :Ag})

(use-package! :stevearc/oil.nvim
               {:call-setup oil})


;;Docs and browse
(use-package! :loganswartz/updoc.nvim
              {:call-setup updoc
               :opt true
               :events :BufRead})

(use-package! :KabbAmine/zeavim.vim
              {:opt true
               :cmd :Zeavim})



;; Send plugins to packer

(echo! "Installing Packages")
(unpack!)

;; Compile modules 

(echo! "Compiling Nyoom Modules")
(nyoom-compile-modules!)
