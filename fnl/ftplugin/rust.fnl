(let [bufnr (vim.api.nvim_get_current_buf)
      auOpts {:focusable false
              :close_events {:BufLeave :CursorMoved :InsertEnter :FocusLost}
              :border :rounded
              :source :always
              :prefix " "
              :scope :line}]
  (vim.api.nvim_create_augroup :RustLsp {:clear true})
  (vim.api.nvim_create_autocmd :CursorHold
                               {:group :RustLsp
                                :buffer bufnr
                                :callback #(vim.diagnostic.open_float auOpts)}))
