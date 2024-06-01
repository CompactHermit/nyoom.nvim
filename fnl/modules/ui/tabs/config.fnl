(import-macros {: packadd! : map!} :macros)

;; fnlfmt: skip
(local __opts
       {:options {:numbers :none
                  :diagnostics :nvim_lsp
                  :diagnostics_indicator (fn [total-count
                                              level
                                              diagnostics-dict]
                                           (var s "")
                                           (each [kind count (pairs diagnostics-dict)]
                                             (set s
                                                  (string.format "%s %s %d" s
                                                                 (. shared.icons
                                                                    kind)
                                                                 count)))
                                           s)
                  :show_buffer_close_icons true
                  :show_close_icon false
                  :persist_buffer_sort true
                  :separator_style ["│" "│"]
                  :indicator {:icon "│" :style :icon}
                  :enforce_regular_tabs false
                  :always_show_bufferline false
                  :offsets [{:filetype :NvimTree
                             :text :Files
                             :text_align :center}
                            {:filetype :DiffviewFiles
                             :text "Source Control"
                             :text_align :center}]}})

;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds
(fn __bufferSetup []
  (packadd! bufferline)
  (packadd! grug)
  (let [fidget (require :fidget)
        progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :buffer}})
        nio (autoload :nio)
        nr nio.run]
    (nr (fn []
          (progress:report {:message "Setting Up buffer"
                            :level vim.log.levels.ERROR
                            :progress 0})
          (nio.scheduler)
          ((->> :setup (. (require :bufferline))) __opts)
          ((->> :setup (. (require :grug-far))))
          (map! [n] :<M-r> `((->> :grug_far (. (require :grug-far))))
                {:desc "Buffer:: Grug Search"})
          (nio.scheduler)
          (progress:report {:message "Setup Complete"
                            :title :Completed!
                            :progress 100})))))

(vim.api.nvim_create_autocmd [:BufAdd :TabEnter]
                             {:pattern "*"
                              :group (vim.api.nvim_create_augroup :BufferLineLazyLoading
                                                                  {:clear true})
                              :callback #(let [ct (length (vim.fn.getbufinfo {:buflisted 1}))]
                                           (when (>= ct 2)
                                             (__bufferSetup)
                                             (vim.api.nvim_del_augroup_by_name :BufferLineLazyLoading)))})
