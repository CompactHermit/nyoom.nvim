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

(local {: init} (autoload :packer))
(local {: echo!} (autoload :core.lib.io))

;; Load packer

(echo! "Loading Packer")
(local headless (= 0 (length (vim.api.nvim_list_uis))))
(init {;:lockfile {:enable true
       ;:path (.. (vim.fn.stdpath :config) :/lockfile.lua)
       :compile_path (.. (vim.fn.stdpath :config) :/lua/packer_compiled.lua)
       :auto_reload_compiled false
       :display {:non_interactive headless}})

;; libraries

;(use-package! :nvim-lua/plenary.nvim {:module :plenary})
(use-package! :nyoom-engineering/oxocarbon.nvim)

(echo! "Initializing Module System")
(include :fnl.modules)
(nyoom-init-modules!)


(use-package! :dstein64/vim-startuptime {:opt true :cmd [:StartupTime]})

;(use-package! :KabbAmine/zeavim.vim {:opt true :cmd :Zeavim})

;; Send plugins to packer

(echo! "Installing Packages")
(unpack!)

;; Compile modules

(echo! "Compiling Nyoom Modules")
(nyoom-compile-modules!)
