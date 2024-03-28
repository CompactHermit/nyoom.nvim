(import-macros {: nyoom-module-p! : map! : autocmd! : packadd!} :macros {: -m>}
               :util.macros)

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
      (packadd! overseer.nvim))
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
                                ;:group :harpoon.setup
                                :once true}))

;; TODO:: (Hemrit) Make this it's own seperate multicursor module, and add extra functionality to it

;; fnlfmt: skip
(do
  (vim.api.nvim_create_augroup :iedit.setup {:clear true})
  (vim.api.nvim_create_autocmd :User
                               {:pattern :iedit.setup
                                :callback (fn []
                                            (packadd! iedit)
                                            (map! [n i] :fx `((. (require :iedit) :select)) {:desc "Iedit::Select"})
                                            (map! [n i] :fa `((. (require :iedit) :select_all)) {:desc "Iedit::Select_all"})
                                            (map! [n i] :fb `((. (require :iedit) :stop)) {:desc "Iedit::Stop"}))
                                :group :iedit.setup
                                :once true
                                :desc "<IEDIT::Setup>"}))



;; fnlfmt: skip
; (local harpoon (require :harpoon))
; (local M {})
; (set M._maps [])
; (set M._lines [])
; (var longest_line 155)
; ; (fn get_buffer []
; ;   (nil))
;   
; (local buff (vim.api.nvim_create_buf false true))
; (local size (. (vim.api.nvim_list_uis) 1))
;
; (each [k v (ipairs (. (: harpoon :list) :items))]
;       (table.insert  M._maps v))
; (each [i v (ipairs M._maps)]
;   (local __lines (.. (tostring i) " " (vim.fn.fnamemodify (. v :value) ":t")))
;   (table.insert M._lines (tostring __lines)))
;   ; (if (>= (: __lines :len)  (longest_line))
;   ;  (set longest_line (: __lines :len))))
;
;
; ; (each [i v (ipairs M._maps)]
; ;   " NAMESPACE::
; ;     Setups highlights for line# whenever the file == harpoon.filename
; ;   "
; ;   (if (= (vim.fn.expand "%:p") (vim.fn.fnamemodify (. v :value) ":p"))
; ;     (set M._hl (vim.api.nvim_buf_add_highlight buff 0 :Error (- i 1) 0 -1))))
;
; ; (each [_ v (ipairs M._lines)]
; ;   (print v))
; (doto buff
;   (vim.api.nvim_buf_set_name "*faker*")
;   (vim.api.nvim_buf_set_lines 0 -1 true M._lines)
;   (vim.api.nvim_buf_clear_namespace M._hl 0 -1))
;
; (local debug true)
;
; (if M._window (do
;                 (vim.api.nvim_win_set_height M._window (length M._lines))
;                 (vim.api.nvim_win_set_width M._window 120))
;   (set M._window (vim.api.nvim_open_win buff false {:relative  :win
;                                                     :focusable  (if (= debug true) true false)
;                                                     :row   (* 0.2 size.height)
;                                                     :col  size.width
;                                                     :width  19
;                                                     :height  (* 3 (length M._maps))
;                                                     :border  [ :╭ :─ :─ " " :─ :─ :╰ :│]
;                                                     :style  :minimal})))
; (print (.. (string.format "Active Window IS:: %s" M._window)))
; (each [_ v (ipairs (vim.api.nvim_list_wins))]
;   (print v))
; (vim.api.nvim_buf_set_name buff "adjoint-faker")
