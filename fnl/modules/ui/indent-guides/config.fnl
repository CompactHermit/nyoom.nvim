(import-macros {: packadd!} :macros)

(let [fidget (require :fidget)
      progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :hlchunks}})]
  (progress:report {:message "Setting Up :: <hlchunk>"
                    :level vim.log.levels.ERROR
                    :progress 0})
  ((->> :setup (. (require :hlchunk))) {:chunk {:enable true
                                                :priority 10
                                                :use_treesitter false
                                                :duration 100
                                                :delay 15}
                                        :indent {:enable false
                                                 :char "┆"
                                                 :use_treesitter true
                                                 :ahead_lines 7
                                                 :delay 0}
                                        :blank {:enable false}
                                        :line_num {:enable false}
                                        :exclude_filetypes {:help true
                                                            :dashboard true
                                                            :nofile true
                                                            :prompt true
                                                            :quickfix true
                                                            :nofile true
                                                            :oil true
                                                            :make true
                                                            :terminal true}})
  (progress:report {:message "Setup Complete"
                    :title "Indent BlankLine"
                    :progress 100})
  (progress:finish))
