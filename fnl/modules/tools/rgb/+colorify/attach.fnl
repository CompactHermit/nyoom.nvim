(local api vim.api)
(local conf {:enabled true
             :mode :virtual
             :virt_text "󱓻 "
             :highlight {:hex true :lspvars true}})

(local ns (. (require :modules.tools.rgb.+colorify.state) :ns))
(local get-extmarks api.nvim_buf_get_extmarks)
(local methods (require :modules.tools.rgb.+colorify.methods))
(fn del-extmarks-on-textchange [buf]
  (tset (. vim.b buf) :colorify_attached true)
  (api.nvim_buf_attach buf false
                       {:on_bytes (fn [_
                                       b
                                       _
                                       s-row
                                       s-col
                                       _
                                       old-e-row
                                       old-e-col
                                       _
                                       _
                                       new-e-col
                                       _]
                                    (when (and (and (= old-e-row 0)
                                                    (= new-e-col 0))
                                               (= old-e-col 0))
                                      (lua "return "))
                                    (var (row1 col1 row2 col2) nil)
                                    (if (> old-e-row 0)
                                        (set (row1 col1 row2 col2)
                                             (values s-row 0
                                                     (+ s-row old-e-row) 0))
                                        (set (row1 col1 row2 col2)
                                             (values s-row s-col s-row
                                                     (+ s-col old-e-col))))
                                    (local ms
                                           (get-extmarks b ns [row1 col1]
                                                         [row2 col2]
                                                         {:overlap true}))
                                    (each [_ mark (ipairs ms)]
                                      (api.nvim_buf_del_extmark b ns (. mark 1))))
                        :on_detach (fn []
                                     (tset (. vim.b buf) :colorify_attached
                                           false))}))

(fn [buf event]
  (let [winid (vim.fn.bufwinid buf)
        min (- (vim.fn.line :w0 winid) 1)
        max (+ (vim.fn.line :w$ winid) 1)]
    (when (= event :TextChangedI)
      (local cur-linenr (- (vim.fn.line "." winid) 1))
      (when conf.highlight.hex
        (methods.hex buf cur-linenr (api.nvim_get_current_line)))
      (when conf.highlight.lspvars (methods.lsp_var buf cur-linenr))
      (lua "return "))
    (local lines (api.nvim_buf_get_lines buf min max false))
    (when conf.highlight.hex
      (each [i str (ipairs lines)]
        (methods.hex buf (- (+ min i) 1) str)))
    (when conf.highlight.lspvars (methods.lsp_var buf nil min max))
    (when (and (= event :BufEnter) (not (. vim.b buf :colorify_attached)))
      (del-extmarks-on-textchange buf))))
