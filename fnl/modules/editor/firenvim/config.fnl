(import-macros {: autocmd! : let!} :macros)
(fn load-firenvim [event]
  (let [client (. (vim.api.nvim_get_chan_info vim.v.event.chan) :client)]
    (if (and (not= client nil) (= client.name :firenvim))
        (vim.o.laststatus 0))))

(autocmd! :UIEnter "*" `(load-firenvim))
(autocmd! :BufEnter :github.com_*.txt "set filetype=markdown")
