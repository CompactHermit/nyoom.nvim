(import-macros {: packadd!
                : pack
                : rock
                : use-package!
                : rock!
                : nyoom-init-modules!
                : nyoom-compile-modules!
                : lzn-unpack!
                : autocmd!} :macros)

(local {: echo!} (autoload :core.lib.io))

;; Load packer

;(echo! "Initializing Module System")
(include :fnl.modules)
(nyoom-init-modules!)

((->> :register_handler (. (autoload :lz.n))) (. (autoload :util.lazn.registers)
                                                 :handler))

((->> :register_handler (. (autoload :lz.n))) (. (autoload :util.lazn.on_req)))

(lzn-unpack!)

;; Compile modules

;(echo! "Compiling Nyoom Modules")
(nyoom-compile-modules!)
