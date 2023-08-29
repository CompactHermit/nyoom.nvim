(import-macros {: nyoom-module-p! : command!} :macros
               {: -d>} :util.macros)

(setup :swenv {:get_venvs (fn [venvs_path]
                            ;;(-d> :swenv.api :get_venv venvs_path))
                            ((. (require :swenv.api) :get_venvs) venvs_path))
               :venvs_path (vim.fn.expand "/home/strange_cofunctor/.cache/pypoetry/virtualenvs/")
               :post_set_venv nil})

(nyoom-module-p! python
                 (do
                   (command! VenvFind "lua require('swenv.api').pick_venv()" {:desc "Pick A poetry Venv"})
                   (command! GetVenv "lua require('swenv.api').get_current_venv()" {:desc "Get Current Poetry Venv"})))
