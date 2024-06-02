;;https://github.com/nvim-neorocks/lz.n/discussions/18
;; NOTE:: We can actually register any# of handlers to lz.n
(local states {})
(local M {:handler {:add (fn [_])
                    :del (fn [plugin] (tset states plugin.name plugin.name))
                    :spec_field :is_loaded}})

(fn M.get_all_plugins []
  (let [result (vim.deepcopy (. (require :lz.n.state) :plugins))]
    (each [_ name (pairs states)]
      (when (not= (. result name) nil) (tset (. result name) :is_loaded true)))
    result))

(fn M.get_a_plugin [name]
  (let [result (vim.deepcopy (. (. (require :lz.n.state) :plugins) name))]
    (when (and (not= result nil) (not= (. states name) nil))
      (set result.is_loaded true))
    result))

M
