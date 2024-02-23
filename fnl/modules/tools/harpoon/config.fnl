(import-macros {: nyoom-module-p! : map!} :macros {: -m>} :util.macros)

(setup :harpoon {:global_settings {:save_on_toggle false
                                   :enter_on_sendcmd true
                                   :tmux_autoclose_windows true
                                   :mark_branch true}})

(let [conf (autoload :telescope.config.values)
      picker (autoload :telescope.pickers)
      themes (autoload :telescope.themes)
      finders (autoload :telescope.finders)
      actions (autoload :telescope.actions)
      action_state (autoload :telescope.actions.state)
      harpoon (autoload :harpoon)]
  (fn __finder [__files]
    "__finder:: Path[] -> Telescope::Finder()"
    (var files [])
    (each [k v (ipairs __files.item)]
      (table.insert files (.. k ". " v.value)))
    ((. finders :new_table) {:result __files}))

  (fn __neo_harpTele [Harpfiles]
    (: (picker.new [(themes.get_dropdown {:previewer false})
                    {:prompt_title :Harpoon
                     :finder (__finder Harpfiles)
                     :previewer (conf.file_previewer)
                     :sorter (conf.generic_sorter)
                     :initial_mode :normal
                     :attach_mappings (fn [_ map]
                                        (: actions.select_default :replace
                                           (fn [p_buf]
                                             (local curr
                                                    (actions.state.get_selected_entry))
                                             (when (not= curr nil)
                                               (actions.close p_buf)
                                               (: (: harpoon :list) :select
                                                  curr.index))))
                                        (map! [n i] :<C-d>
                                              `(fn [p_buf]
                                                 (let [curr (action_state.get_current_picker :p_buf)]
                                                   (: curr :delete_selection
                                                      (fn [__selection]
                                                        (: harpoon :list
                                                           :removeAt
                                                           __selection.index)))))))}])
       ; attach_mappings = function(_, map)
       ; actions.select_default:replace(function(prompt_bufnr)
       ;                                local curr_entry = action_state.get_selected_entry()
       ;                                if not curr_entry then
       ;                                return
       ;                                end
       ;                                actions.close(prompt_bufnr)
       ;
       ;                                harpoon:list():select(curr_entry.index)
       ;                                end)
       ; -- Delete entries in insert mode from harpoon list with <C-d>
       ; -- Change the keybinding to your liking
       ; map({ "n", "i" }, "<C-d>", function(prompt_bufnr)
       ;     local curr_picker = action_state.get_current_picker(prompt_bufnr)
       ;
       ;     curr_picker:delete_selection(function(selection)
       ;                                  harpoon:list():removeAt(selection.index)
       ;                                  end)
       ;     end)
       ; -- Move entries up and down with <C-j> and <C-k>
       ; -- Change the keybinding to your liking
       ; map({ "n", "i" }, "<C-j>", function(prompt_bufnr)
       ;     move_mark_down(prompt_bufnr, harpoon_files)
       ;     end)
       ; map({ "n", "i" }, "<C-k>", function(prompt_bufnr)
       ;     move_mark_up(prompt_bufnr, harpoon_files)
       ;     end)
       ;
       ; return true
       ; end,}])
       :find)))
