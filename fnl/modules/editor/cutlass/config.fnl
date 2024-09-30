(import-macros {: packadd! : nyoom-module-p! : map!} :macros)

;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds
(let [__yankOpts {:ring {:history_length 100
                         :sync_with_numbered_registers true}
                  :highlight {:on_put true :on_yank true :timer 400}
                  :preserve_cursor_position {:enabled false}
                  :system_clipboard {:sync_with_ring true}}
      fidget (autoload :fidget)
      progress `,((. (autoload :fidget.progress) :handle :create) {:lsp_client {:name "[C]utlass"}})]
  ;(vim.api.nvim_set_hl 0 :YankyYanked theme.fancy_float.title)
  (progress:report {:message "Setting Up Module Name"
                    :level vim.log.levels.ERROR
                    :progress 0})
  ((->> :setup (. (require :yanky))) __yankOpts)
  (vim.api.nvim_set_hl 0 :YankyPut {:fg "#f2f4f8" :bg "#be95ff"})
  (vim.api.nvim_set_hl 0 :YankyYanked {:fg "#f2f4f8" :bg "#82cfff"})
  (nyoom-module-p! telescope
                   ((->> :load_extension (. (autoload :telescope))) :yank_history))
  (progress:report {:message "Setup Complete" :title :Completed! :progress 99})
  (progress:finish))

(map! [n] "]p" "<Plug>(YankyCycleForward)" {:desc "[Ynk]cyc [F]orward"})
(map! [n] "[p" "<Plug>(YankyCycleBackward)" {:desc "[Ynk]cyc [B]ackward"})
(map! [n] :<leader>p "<cmd>Telescope yank_history<CR>"
      {:desc "[Ynk] [H]istory"})
