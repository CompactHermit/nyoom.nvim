(let [fidget (autoload :fidget)
      progress ((. (autoload :fidget.progress) :handle :create) {:lsp_client {:name :neotest}})]
  (progress:report {:message "Setting Up neotest"
                    :level vim.log.levels.ERROR
                    :progress 0})
  ((->> :setup (. (require :markview))) {:hybrid_modes [:i]
                                         :callback {:on_enable #(do
                                                                  (tset vim.wo
                                                                        $2
                                                                        :conceallevel
                                                                        2)
                                                                  (tset vim.wo
                                                                        $2
                                                                        :concealcursor
                                                                        :nc))}})
  (progress:report {:message "Setup Complete" :title :Completed! :progress 100})
  (progress:finish))
