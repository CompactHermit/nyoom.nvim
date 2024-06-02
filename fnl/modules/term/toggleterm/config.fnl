(let [fidget (require :fidget)
      progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :tterm}})]
  (progress:report {:message "Setting Up tterm"
                    :level vim.log.levels.ERROR
                    :progress 0})
  (vim.keymap.set :t :<Esc><Esc> "<C-\\><C-n>" {:desc "exit terminal mode"})
  ((->> :setup (. (require :toggleterm))))
  (progress:report {:message "Setup Complete" :title :Completed! :progress 100})
  (progress:finish))
