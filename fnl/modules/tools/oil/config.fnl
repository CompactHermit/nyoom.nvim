(import-macros {: autocmd!} :macros)
(local oil (require :oil))
(local preview-wins {})
(local preview-bufs {})
(local preview-max-fsize 1000000)
(local preview-debounce 64)
(var preview-request-last-timestamp 0)
(fn lcd [dir]
  (let [ok (pcall vim.cmd.lcd dir)]
    (when (not ok)
      (vim.notify (.. "[oil.nvim] failed to cd to " dir) vim.log.levels.WARN))))
(fn nopreview [msg height width]
  (let [lines {}
        fillchar (or (. (vim.opt_local.fillchars:get) :diff) "-")
        msglen (+ (length msg) 4)
        padlen-l (math.max 0 (math.floor (/ (- width msglen) 2)))
        padlen-r (math.max 0 (- (- width msglen) padlen-l))
        line-fill (fillchar:rep width)
        half-fill-l (fillchar:rep padlen-l)
        half-fill-r (fillchar:rep padlen-r)
        line-above (.. half-fill-l (string.rep " " msglen) half-fill-r)
        line-below line-above
        line-msg (.. half-fill-l "  " msg "  " half-fill-r)
        half-height-u (math.max 0 (math.floor (/ (- height 3) 2)))
        half-height-d (math.max 0 (- (- height 3) half-height-u))]
    (for [_ 1 half-height-u] (table.insert lines line-fill))
    (table.insert lines line-above)
    (table.insert lines line-msg)
    (table.insert lines line-below)
    (for [_ 1 half-height-d] (table.insert lines line-fill))
    lines))
(fn end-preview [oil-win]
  (set-forcibly! oil-win (or oil-win (vim.api.nvim_get_current_win)))
  (local preview-win (. preview-wins oil-win))
  (local preview-buf (. preview-bufs oil-win))
  (when (and (and preview-win (vim.api.nvim_win_is_valid preview-win))
             (= (vim.fn.winbufnr preview-win) preview-buf))
    (vim.api.nvim_win_close preview-win true))
  (when (and preview-buf (vim.api.nvim_win_is_valid preview-buf))
    (vim.api.nvim_win_close preview-buf true))
  (tset preview-wins oil-win nil)
  (tset preview-bufs oil-win nil))
(fn preview []
  (let [entry (oil.get_cursor_entry)
        fname (and entry entry.name)
        dir (oil.get_current_dir)]
    (when (or (not dir) (not fname)) (lua "return "))
    (local fpath (vim.fs.joinpath dir fname))
    (local stat (vim.uv.fs_stat fpath))
    (when (or (not stat)
              (and (not= stat.type :file) (not= stat.type :directory)))
      (lua "return "))
    (local oil-win (vim.api.nvim_get_current_win))
    (var preview-win (. preview-wins oil-win))
    (var preview-buf (. preview-bufs oil-win))
    (when (or (or (or (not preview-win) (not preview-buf))
                  (not (vim.api.nvim_win_is_valid preview-win)))
              (not (vim.api.nvim_buf_is_valid preview-buf)))
      (local oil-win-height (vim.api.nvim_win_get_height oil-win))
      (local oil-win-width (vim.api.nvim_win_get_width oil-win))
      (vim.cmd.new {:mods {:vertical (> oil-win-width (* 6 oil-win-height))}})
      (set preview-win (vim.api.nvim_get_current_win))
      (set preview-buf (vim.api.nvim_get_current_buf))
      (tset preview-wins oil-win preview-win)
      (tset preview-bufs oil-win preview-buf)
      (tset (. vim.bo preview-buf) :filetype :oil_preview)
      (tset (. vim.bo preview-buf) :buftype :nofile)
      (tset (. vim.bo preview-buf) :bufhidden :wipe)
      (tset (. vim.bo preview-buf) :swapfile false)
      (tset (. vim.bo preview-buf) :buflisted false)
      (set vim.opt_local.spell false)
      (set vim.opt_local.number false)
      (set vim.opt_local.relativenumber false)
      (set vim.opt_local.signcolumn :no)
      (set vim.opt_local.foldcolumn :0)
      (set vim.opt_local.winbar "")
      (vim.api.nvim_set_current_win oil-win))
    (vim.keymap.set :n :<CR> (fn [] (vim.cmd.edit fpath) (end-preview oil-win))
                    {:buffer preview-buf})
    (local preview-bufname (vim.fn.bufname preview-buf))
    (local preview-bufnewname (.. "oil_preview://" fpath))
    (when (= preview-bufname preview-bufnewname) (lua "return "))
    (local preview-win-height (vim.api.nvim_win_get_height preview-win))
    (local preview-win-width (vim.api.nvim_win_get_width preview-win))
    (var add-syntax false)
    (var lines {})
    (set lines (or (or (or (or (and (= stat.type :directory)
                                    (vim.fn.systemlist (.. "ls -lhA "
                                                           (vim.fn.shellescape fpath))))
                               (and (= stat.size 0)
                                    (nopreview "Empty file" preview-win-height
                                               preview-win-width)))
                           (and (> stat.size preview-max-fsize)
                                (nopreview "File too large to preview"
                                           preview-win-height preview-win-width)))
                       (and (not (: (vim.fn.system [:file fpath]) :match :text))
                            (nopreview "Binary file, no preview available"
                                       preview-win-height preview-win-width)))
                   (and ((fn [] (set add-syntax true) true))
                        (: (: (vim.iter (io.lines fpath)) :map
                              (fn [line] (line:gsub "\r$" "")))
                           :totable))))
    (vim.api.nvim_buf_set_lines preview-buf 0 (- 1) false lines)
    (vim.api.nvim_buf_set_name preview-buf preview-bufnewname)
    (vim.api.nvim_win_call preview-win
                           (fn []
                             (let [target-dir (or (and (= stat.type :directory)
                                                       fpath)
                                                  dir)]
                               (when (not= (not (vim.fn.getcwd 0)) target-dir)
                                 (lcd target-dir)))))
    (vim.api.nvim_buf_call preview-buf
                           (fn [] (vim.treesitter.stop preview-buf)))
    (tset (. vim.bo preview-buf) :syntax "")
    (when (not add-syntax) (lua "return "))
    (local ft (vim.filetype.match {:buf preview-buf :filename fpath}))
    (when (and ft (not (pcall vim.treesitter.start preview-buf ft)))
      (tset (. vim.bo preview-buf) :syntax ft))))
(local groupid-preview (vim.api.nvim_create_augroup :OilPreview {}))
(vim.api.nvim_create_autocmd [:CursorMoved :WinScrolled]
                             {:callback (fn []
                                          (local oil-win
                                                 (vim.api.nvim_get_current_win))
                                          (local preview-win
                                                 (. preview-wins oil-win))
                                          (when (or (not preview-win)
                                                    (not (vim.api.nvim_win_is_valid preview-win)))
                                            (end-preview)
                                            (lua "return "))
                                          (local current-request-timestamp
                                                 (vim.uv.now))
                                          (set preview-request-last-timestamp
                                               current-request-timestamp)
                                          (vim.defer_fn (fn []
                                                          (when (= preview-request-last-timestamp
                                                                   current-request-timestamp)
                                                            (preview)))
                                            preview-debounce))
                              :desc "Update floating preview window when cursor moves or window scrolls."
                              :group groupid-preview
                              :pattern "oil:///*"})
(vim.api.nvim_create_autocmd :BufEnter
                             {:callback (fn [info]
                                          (when (not= (. (. vim.bo info.buf)
                                                         :filetype)
                                                      :oil)
                                            (end-preview)))
                              :desc "Close preview window when leaving oil buffers."
                              :group groupid-preview})
(vim.api.nvim_create_autocmd :WinClosed
                             {:callback (fn [info]
                                          (local win (tonumber info.match))
                                          (when (and win (. preview-wins win))
                                            (end-preview win)))
                              :desc "Close preview window when closing oil windows."
                              :group groupid-preview})
(fn toggle-preview []
  (let [oil-win (vim.api.nvim_get_current_win)
        preview-win (. preview-wins oil-win)]
    (when (or (not preview-win) (not (vim.api.nvim_win_is_valid preview-win)))
      (preview)
      (lua "return "))
    (end-preview)))
(local preview-mapping {:callback toggle-preview
                        :desc "Toggle preview"
                        :mode [:n :x]})
(local permission-hlgroups
       (setmetatable {:- :OilPermissionNone
                      :r :OilPermissionRead
                      :w :OilPermissionWrite
                      :x :OilPermissionExecute}
                     {:__index (fn [] :OilDir)}))
(local type-hlgroups
       (setmetatable {:- :OilTypeFile
                      :d :OilTypeDir
                      :l :OilTypeLink
                      :p :OilTypeFifo
                      :s :OilTypeSocket}
                     {:__index (fn [] :OilTypeFile)}))
(setup :oil {:cleanup_delay_ms 0
             :columns [{1 :type
                        :highlight (fn [type-str] (. type-hlgroups type-str))
                        :icons {:directory :d
                                :fifo :p
                                :file "-"
                                :link :l
                                :socket :s}}
                       {1 :permissions
                        :highlight (fn [permission-str]
                                     (local hls {})
                                     (for [i 1 (length permission-str)]
                                       (local char (permission-str:sub i i))
                                       (table.insert hls
                                                     [(. permission-hlgroups
                                                         char)
                                                      (- i 1)
                                                      i]))
                                     hls)}
                       {1 :size :highlight :Special}
                       {1 :mtime :highlight :Number}
                       {1 :icon
                        :add_padding false}]
                        ;;:default_file icon-file
                        ;;:directory icon-dir}]
             :delete_to_trash true
             :float {:border :solid :win_options {:winblend 0}}
             :keymaps {:+ :actions.select
                       :- :actions.parent
                       :<C-h> :actions.toggle_hidden
                       :<C-i> {:buffer true
                               :callback (fn []
                                           (local jumplist (vim.fn.getjumplist))
                                           (local newloc
                                                  (. (. jumplist 1)
                                                     (+ (. jumplist 2) 2)))
                                           (or (and (and (and newloc
                                                              (vim.api.nvim_buf_is_valid newloc.bufnr))
                                                         (= (. (. vim.bo
                                                                  newloc.bufnr)
                                                               :ft)
                                                            :oil))
                                                    :<C-i>)
                                               :<Ignore>))
                               :desc "Jump to newer cursor position in oil buffer"
                               :expr true
                               :mode :n}
                       :<C-k> preview-mapping
                       :<C-o> {:buffer true
                               :callback (fn []
                                           (local jumplist (vim.fn.getjumplist))
                                           (local prevloc
                                                  (. (. jumplist 1)
                                                     (. jumplist 2)))
                                           (or (and (and (and prevloc
                                                              (vim.api.nvim_buf_is_valid prevloc.bufnr))
                                                         (= (. (. vim.bo
                                                                  prevloc.bufnr)
                                                               :ft)
                                                            :oil))
                                                    :<C-o>)
                                               :<Ignore>))
                               :desc "Jump to older cursor position in oil buffer"
                               :expr true
                               :mode :n}
                       :<CR> :actions.select
                       := :actions.select
                       :K preview-mapping
                       :g? :actions.show_help
                       :gs :actions.change_sort
                       :gx :actions.open_external
                       :gy {:buffer true
                            :callback (fn []
                                        (local entry (oil.get_cursor_entry))
                                        (local dir (oil.get_current_dir))
                                        (when (or (not entry) (not dir))
                                          (lua "return "))
                                        (local entry-path (.. dir entry.name))
                                        (vim.fn.setreg "\"" entry-path)
                                        (vim.fn.setreg vim.v.register entry-path)
                                        (vim.notify (string.format "[oil] yanked '%s' to register '%s'"
                                                                   entry-path
                                                                   vim.v.register)))
                            :desc "Yank the filepath of the entry under the cursor to a register"
                            :mode :n}}
             :preview {:border :solid :win_options {:winblend 0}}
             :progress {:border :solid :win_options {:winblend 0}}
             :prompt_save_on_select_new_entry true
             :skip_confirm_for_simple_edits true
             :use_default_keymaps false
             :view_options {:is_always_hidden (fn [name] (= name ".."))}
             :win_options {:foldcolumn :0
                           :number false
                           :relativenumber false
                           :signcolumn :no
                           :statuscolumn ""}})
(local groupid (vim.api.nvim_create_augroup :OilSyncCwd {}))
(vim.api.nvim_create_autocmd [:BufEnter :TextChanged]
                             {:callback (fn [info]
                                          (when (= (. (. vim.bo info.buf)
                                                      :filetype)
                                                   :oil)
                                            (local cwd
                                                   (vim.fs.normalize (vim.fn.getcwd (vim.fn.winnr))))
                                            (local oildir
                                                   (vim.fs.normalize (oil.get_current_dir)))
                                            (when (and (not= cwd oildir)
                                                       (vim.uv.fs_stat oildir))
                                              (lcd oildir))))
                              :desc "Set cwd to follow directory shown in oil buffers."
                              :group groupid
                              :pattern "oil:///*"})
(vim.api.nvim_create_autocmd :DirChanged
                             {:callback (fn [info]
                                          (when (= (. (. vim.bo info.buf)
                                                      :filetype)
                                                   :oil)
                                            (vim.defer_fn (fn []
                                                            (local cwd
                                                                   (vim.fs.normalize (vim.fn.getcwd (vim.fn.winnr))))
                                                            (local oildir
                                                                   (vim.fs.normalize (or (oil.get_current_dir)
                                                                                         "")))
                                                            (when (not= cwd
                                                                        oildir)
                                                              (oil.open cwd)))
                                              100)))
                              :desc "Let oil buffers follow cwd."
                              :group groupid})
