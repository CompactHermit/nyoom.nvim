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

(lzn-unpack!)

;(echo! "Compiling Nyoom Modules")
(nyoom-compile-modules!)
