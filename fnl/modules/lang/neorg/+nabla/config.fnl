(import-macros {: map!} :macros)
(local {: enable_virt : popup} (autoload :nabla))

(map! [n] :<leader>nov `(enable_virt) {:desc "Nabla Preview"})
(map! [n] :<leader>nop `(popup {:border :solid}) {:desc "Nabla Popup"})
