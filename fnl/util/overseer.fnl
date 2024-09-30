(local overseer (require :overseer))

(fn close-task [bufnr]
  (each [_ winnr (ipairs (vim.api.nvim_tabpage_list_wins 0))]
    (when (vim.api.nvim_win_is_valid winnr)
      (local winbufnr (vim.api.nvim_win_get_buf winnr))
      (when (= (. (. vim.bo winbufnr) :filetype) :OverseerPanelTask)
        (local oldwin (. (vim.tbl_filter (fn [t] (= t.strategy.bufnr bufnr))
                                         (overseer.list_tasks))
                         1))
        (when oldwin (vim.api.nvim_win_close winnr true))))))

;;Under the hood, it simply is passed to overseer's tasklist. 
;; However, the plan is to create tasks per language,)e.g:: Using Poetry takss only when python module is enabled, or c++ tasks when c++ taks are created.)
;; Hence, it only registers when the module is loaded
(lambda overseer! [name args list]
  "Overseer! is a macro used to create custom Overseer tasks. 
  ")

{: close-task}
