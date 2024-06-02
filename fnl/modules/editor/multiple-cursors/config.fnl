(import-macros {: packadd! : map!} :macros)

(let [fidget (require :fidget)
      nio (autoload :nio)
      progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :multiCursor}})]
  (progress:report {:message "Setting Up multiCursor"
                    :level vim.log.levels.ERROR
                    :progress 0})
  ;;NOTE(Hemrit): This will never check for failure, look into a nio function which softwraps errors
  ((->> :setup (. (require :multicursors))) {})
  (progress:report {:message "Setup Complete" :title :Completed! :progress 100})
  (progress:finish))
