(import-macros {: use-package!} :macros)

(use-package! :scalameta/nvim-metals
              {:nyoom-module lang.scala
               :ft :scala
               :config (fn []
                         (local {: metals_config} (require :metals.bare_config))
                         (metal_config {:init_options {:statusBarProvider :off}
                                        :showImplicitArguments true}))})
