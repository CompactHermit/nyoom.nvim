(import-macros {: packadd!
                : pack
                : rock
                : use-package!
                : rock!
                : nyoom-init-modules!
                : nyoom-compile-modules!
                : lzn-unpack!
                : autocmd!} :macros)

;; TODO:: (Hermit) Move away from packer, and simply call the setup tbl
;(packadd! packer.nvim)

;(local {: init} (autoload :packer))
(local {: echo!} (autoload :core.lib.io))

;; Load packer

;(echo! "Loading Packer")
;(local headless (= 0 (length (vim.api.nvim_list_uis))))
; (init {:compile_path (.. (vim.fn.stdpath :config) :/lua/packer_compiled.lua)
;        :auto_reload_compiled false
;        :display {:non_interactive headless}})

;; libraries

;(echo! "Initializing Module System")
(include :fnl.modules)
(nyoom-init-modules!)

;((->> :register_handler (. (autoload :lz.n))) (. (require :util.lazn) :handler))
(lzn-unpack!)

;; Compile modules

;(echo! "Compiling Nyoom Modules")
(nyoom-compile-modules!)
