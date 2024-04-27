(import-macros {: nyoom-module-p! : command!} :macros)

(setup :noice {:health {:checker false}
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
                                  :help {:pattern "^:%s*h%s+" :icon ""}
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

;; A quick hack to get noice-messages to work with edgy-nvim
;;TODO:: To macro
(fn __fmtMSG [text]
  "Formats Messages"
  (: :gsub text "\\n\\n+" "\\n\\n"))

(fn __aliased_bufnr [bufnr]
  " 
  Note:: This would be perfect for a macro, hmmm.
  Just makes it easier for the `doto` block.
  If only vim had a fucking flip operator.
  "
  (vim.api.nvim_set_option_value :bufhidden :delete {:buf bufnr}))

(fn __messages [arg]
  "Buffer::Message -> Buffer::Messages.Split
   A Soft wrapper around `message` with a split and title.
   Useful to get noice to get an edgy-window"
  (let [res (vim.api.nvim_exec2 arg {:output true})
        text (__fmtMSG res.output)
        lines (vim.split text "\n")
        bufnr (vim.api.nvim_create_buf false true)]
    (doto bufnr
      (vim.api.nvim_buf_set_lines 0 -1 true lines)
      (vim.api.nvim_buf_set_name :messages)) ; (__aliased_bufnr))
    (vim.api.nvim_set_option_value :bufhidden :delete {:buf bufnr})
    (vim.cmd :9split)
    (vim.api.set_current_buf bufnr)))

(command! M `(fn []
               (__messages :messages)) {:desc "Message Split"})
