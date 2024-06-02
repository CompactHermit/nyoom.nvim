(import-macros {: lzn!} :macros)

(lzn! :folke_flash
      {:nyoom-module config.default.+flash
       :keys [:f :F :t :T :<M-s>]})

(lzn! :text-case 
      {:cmd [:TextCaseOpenTelescope :TextCase]
       :call-setup textcase})
