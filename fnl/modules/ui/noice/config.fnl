(import-macros {: packadd! : command!} :macros)

(local _opts {:health {:checker false}
              :cmdline {:format {:cmdline {:pattern "^:"
                                           :icon " "
                                           :lang :vim}
                                 :search_down {:kind :search
                                               :pattern "^/"
                                               :icon " "
                                               :lang :regex}
                                 :search_up {:kind :search
                                             :pattern "^%?"
                                             :icon " "
                                             :lang :regex}
                                 :filter {:pattern "^:%s*!"
                                          :icon "$"
                                          :lang :bash}
                                 :lua {:pattern "^:%s*lua%s+"
                                       :icon ""
                                       :lang :lua}
                                 :help {:pattern "^:%s*h%s+" :icon ""}
                                 :input {}}
                        :opts {:win_options {:winhighlight {:Normal :NormalFloat
                                                            :FloatBorder :FloatBorder}}}}
              :lsp {:progress {:enabled false}
                    :override {:vim.lsp.util.convert_input_to_markdown_lines true
                               :vim.lsp.util.stylize_markdown true
                               :cmp.entry.get_documentation true}}
              :messages {:enabled true}
              :commands {:history {:view :split
                                   :opt {:enter true :format :details}}}
              :documentation {:view :hover
                              :opts {:lang :markdown
                                     :replace true
                                     :render :plain
                                     :format ["{message}"]
                                     :win_options {:concealcursor :n
                                                   :conceallevel 3}}}
              :views {:cmdline_popup {:position {:row 0 :col "50%"}
                                      :size {:width "98%"}}}
              :presets {:long_message_to_split true :lsp_doc_border true}
              :popupmenu {:enabled true :backend :cmp}
              :notify {:enabled false}
              :format {}})

;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds
(fn __noiceSetup []
  " NoiceConfig::
        "
  (packadd! nvim-notify)
  (packadd! folke_noice)
  (let [fidget (require :fidget)
        progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :noice}})]
    (progress:report {:message "Setting Up noice"
                      :level vim.log.levels.ERROR
                      :progress 0})
    ((->> :setup (. (require :notify))) {:fps 60
                                         :render :wrapped-compact
                                         :stages :slide})
    ((->> :setup (. (require :noice))) _opts)
    (progress:report {:message "Setup Complete"
                      :title :Completed!
                      :progress 99})))

(vim.api.nvim_create_autocmd :BufReadPre {:callback #(__noiceSetup) :once true})
