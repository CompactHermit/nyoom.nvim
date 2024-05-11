(import-macros {: nyoom-module-p! : map! : autocmd! : packadd!} :macros)

(local terminals
       {:automated true
        :encode false
        :prepopulate (fn []
                       (local bufs (vim.api.nvim_list_bufs))
                       (: (: (: (vim.iter bufs) :filter
                                (fn [buf]
                                  (= (. (. vim.bo buf) :buftype) :terminal)))
                             :map
                             (fn [buf]
                               {:context {:bufnr buf}
                                :value (vim.api.nvim_buf_get_name buf)}))
                          :totable))
        :remove (fn [list-item _list]
                  (when (vim.api.nvim_buf_is_valid list-item.context.bufnr)
                    ((. (require :bufdelete) :bufdelete) list-item.context.bufnr
                                                         true)))
        :select (fn [list-item _list _opts]
                  (local wins (vim.api.nvim_tabpage_list_wins 0))
                  (each [_ win (ipairs wins)]
                    (local buf (vim.api.nvim_win_get_buf win))
                    (when (= buf list-item.context.bufnr)
                      (vim.api.nvim_set_current_win win)
                      (lua "return ")))
                  (vim.api.nvim_set_current_buf list-item.context.bufnr))})

;; CMDS:: 'HarpoonTerm', 'HarpoonSend', 'HarpoonSendLine'

(fn __harpSetup []
  " The Harpoon Handler::
        It exposes two handlers::
            Overseer::
            Harpoon::
        If one or the other is not loaded, it packadds! them automatically
        "
  (packadd! harpoon)
  (packadd! oqt)
  (packadd! yeet)
  (if (not= (pcall require :plenary) true)
      (packadd! plenary.nvim))
  (if (not= (pcall require :overseer) true)
      (packadd! overseer))
  (let [fidget (require :fidget)
        progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :harpoon}})
        harpn (require :harpoon)
        oqt (require :oqt)
        titles {:ADD :added :REMOVE :removed}
        get_width vim.api.nvim_win_get_width
        Path (require :plenary.path)
        genKeymap (lambda [?mode _key ?type _cb]
                    (vim.keymap.set ?mode _key
                                    #(: (. harpn :ui) :select_menu_item
                                        {?type true})
                                    {:buffer _cb.bufnr}))
        __handler (fn [event _cb]
                    (when (not= _cb nil)
                      (let [path (: Path :new (. _cb :item :value))
                            display (or (: path :make_relative vim.uv.cwd)
                                        (: path :make_relative vim.env.HOME)
                                        (: path :normalize))]
                        ((. fidget :progress :handle :create) {:lsp_client {:name :harpoon}
                                                               :title (. titles
                                                                         event)
                                                               :message display
                                                               :level vim.log.levels.ERROR}))))
        handler (fn [evt ...]
                  #(__handler evt $...))]
    (progress:report {:message "Setting Up <Harpoon>"
                      :level vim.log.levels.ERROR
                      :progress 0})
    (harpn:setup {:menu {:width (- (get_width 0) 4)}
                  :settings {:save_on_toggle true}
                  :oqt oqt.harppon_list_config
                  : terminals
                  :yeet {:select (fn [__listI _ _]
                                   ((->> :execute (. (require :yeet))) __listI.value))}})
    (progress:report {:message "Setup Complete"
                      :title :Completed!
                      :progress 99})
    (harpn:extend {:LIST_READ (fn [list])
                   :ADD (__handler :ADD)
                   :REMOVE (__handler :REMOVE)
                   :UI_CREATE (fn [cx]
                                (for [i 1 9]
                                  (vim.keymap.set :n (.. "" i)
                                                  #(: (harpn:list) :select i)
                                                  {:buffer cx.bufnr}))
                                (doto :n
                                  (genKeymap :<C-v> :vsplit cx)
                                  (genKeymap :<C-x> :split cx)
                                  (genKeymap :<C-t> :tabedit cx)))})))

;; fnlfmt: skip
(do
  (vim.api.nvim_create_autocmd :User
                               {:pattern :harpoon.setup
                                :callback #(__harpSetup)
                                :once true}))
