(local api vim.api)
(local set-extmark api.nvim_buf_set_extmark)
(local conf {:enabled true
             :mode :virtual
             :virt_text "󱓻 "
             :highlight {:hex true :lspvars true}})

(local utils (require :modules.tools.rgb.+colorify.utils))
(local ns (. (require :modules.tools.rgb.+colorify.state) :ns))
(local needs-hl utils.not_colored)
(local M {})
(fn M.hex [buf line str]
  (each [col hex (str:gmatch "()(#%x%x%x%x%x%x)")]
    (set-forcibly! col (- col 1))
    (local hl-group (utils.add_hl hex))
    (local end-col (+ col 7))
    (local opts {:end_col end-col :hl_group hl-group})
    (when (= conf.mode :virtual)
      (set opts.hl_group nil)
      (set opts.virt_text_pos :inline)
      (set opts.virt_text [[conf.virt_text hl-group]]))
    (when (needs-hl buf line col hl-group opts)
      (set-extmark buf ns line col opts))))

(fn M.lsp_var [buf line min max]
  (let [param {:textDocument (vim.lsp.util.make_text_document_params buf)}]
    (each [_ client (pairs (vim.lsp.get_clients {:bufnr buf}))]
      (when client.server_capabilities.colorProvider
        (client.request :textDocument/documentColor param
                        (fn [_ resp]
                          (when (and resp line)
                            (set-forcibly! resp
                                           (vim.tbl_filter (fn [v]
                                                             (= (. v.range
                                                                   :start :line)
                                                                line))
                                                           resp)))
                          (when (and resp min)
                            (set-forcibly! resp
                                           (vim.tbl_filter (fn [v]
                                                             (and (>= (. v.range
                                                                         :start
                                                                         :line)
                                                                      min)
                                                                  (<= (. v.range
                                                                         :end
                                                                         :line)
                                                                      max)))
                                                           resp)))
                          (each [_ val (ipairs (or resp {}))]
                            (local color val.color)
                            (local (r g b a)
                                   (values color.red color.green color.blue
                                           color.alpha))
                            (local hex
                                   (string.format "#%02x%02x%02x" (* r a 255)
                                                  (* g a 255) (* b a 255)))
                            (local hl-group (utils.add_hl hex))
                            (local range-start val.range.start)
                            (local range-end (. val.range :end))
                            (local opts
                                   {:end_col range-end.character
                                    :hl_group hl-group})
                            (when (= conf.mode :virtual)
                              (set opts.hl_group nil)
                              (set opts.virt_text_pos :inline)
                              (set opts.virt_text [[conf.virt_text hl-group]]))
                            (when (needs-hl buf range-start.line
                                            range-start.character hl-group opts)
                              (set-extmark buf ns range-start.line
                                           range-start.character opts))))
                        buf)))))

M
