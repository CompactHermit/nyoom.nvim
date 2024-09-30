;; This is just stolen from <https://github.com/NvChad/ui?tab=GPL-3.0-1-ov-file>

(let [state (require :modules.tools.rgb.+colorify.state)
      attach (require :modules.tools.rgb.+colorify.attach)]
  (do
    (vim.api.nvim_create_autocmd [:TextChanged
                                  :TextChangedI
                                  :TextChangedP
                                  :VimResized
                                  :LspAttach
                                  :WinScrolled
                                  :BufEnter]
                                 {:callback #(when (. vim.bo $1.buf :bl)
                                               (attach $1.buf $1.event))})
    (set state.ns (vim.api.nvim_create_namespace :Colorify))))
