(import-macros {: packadd!
                : pack
                : rock
                : use-package!
                : rock!
                : nyoom-init-modules!
                : nyoom-compile-modules!
                : unpack!
                : autocmd!} :macros)

;; TODO:: (Hermit) Move away from packer, and simply call the setup tbl
(packadd! packer.nvim)
;(local {: build} (autoload :hotpot.api.make))
(local {: init} (autoload :packer))
(local {: echo!} (autoload :core.lib.io))

;; Load packer

(echo! "Loading Packer")
(local headless (= 0 (length (vim.api.nvim_list_uis))))
(init {:lockfile {:enable true
                  :path (.. (vim.fn.stdpath :config) :/lockfile.lua)}
       :compile_path (.. (vim.fn.stdpath :config) :/lua/packer_compiled.lua)
       :auto_reload_compiled false
       :display {:non_interactive headless}})

;(echo! "Compiling Nyoom Doctor")
; (build (vim.fn.stdpath :config) {:verbosity 0}
;        (.. (vim.fn.stdpath :config) :/fnl/core/doctor.fnl)
;        (fn []
;          (.. (vim.fn.stdpath :config) :/lua/health.lua)))

;; (use-package! :EdenEast/packer.nvim {:opt true :branch :feat/lockfile})
; (use-package! :wbthomason/packer.nvim {:opt true})

;; libraries

(use-package! :nvim-lua/plenary.nvim {:module :plenary})
(use-package! :MunifTanjim/nui.nvim {:module :nui})
(use-package! :nyoom-engineering/oxocarbon.nvim)
;;(use-package! :EdenEast/nightfox.nvim)

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

(use-package! :nvimdev/lspsaga.nvim
              {:opt true
               :cmd [:Lspsaga]
               :config (fn []
                         (local {: setup} (require :lspsaga))
                         (setup {:lightbulb {:enable false}}))})

; TODO:: (CH) <10/06> Debug this.
(use-package! :dstein64/vim-startuptime {:opt true :cmd [:StartupTime]})

(use-package! :stevearc/resession.nvim
              {:opt true :event [:BufReadPost] :call-setup resession})

;;Docs and browse
(use-package! :loganswartz/updoc.nvim
              {:call-setup updoc :opt true :events :BufReadPost})

(use-package! :KabbAmine/zeavim.vim {:opt true :cmd :Zeavim})

;; Send plugins to packer

(echo! "Installing Packages")
(unpack!)

;; Compile modules

(echo! "Compiling Nyoom Modules")
(nyoom-compile-modules!)
