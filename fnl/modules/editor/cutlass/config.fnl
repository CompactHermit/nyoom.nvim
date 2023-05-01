
(import-macros {: nyoom-module-p!} :macros)

(nyoom-module-p! cutlass
  (do
    (local yank_setup {:ring {:history_length 100
                              :sync_with_numbered_registers true}
                       :system_clipboard {:sync_with_ring true}})
    (setup :yanky {: yank_setup})))

(nyoom-module-p! telescope
 (do
  (local {: load_extension} (autoload :telescope))
  (load_extension :yank_history)))

