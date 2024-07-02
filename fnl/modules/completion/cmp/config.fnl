(import-macros {: set!
                : nyoom-module-p!
                : packadd!
                : autocmd!
                : augroup!
                : map!} :macros)

;; fnlfmt: skip
(fn has-words-before []
          (let [(line col) (unpack (vim.api.nvim_win_get_cursor 0))]
            (and (not= col 0) (= (: (: (. (vim.api.nvim_buf_get_lines 0 (- line 1) line
                                                                      true)
                                          1) :sub col
                                       col) :match "%s") nil))))

(fn entry_filter [entry _]
  (not (vim.tbl_contains ["No matches found" :Searching... "Workspace loading"]
                         entry.completion_item.label)))

(fn load_after_plugin [fpattern]
  "Because cmp-plugins (fuck u Hrshit) /incorrectly/ use `/after/plugin`, we can't just packadd, so we source instead and pray"
  (local after-paths (vim.api.nvim_get_runtime_file (.. :after/plugin/ fpattern)
                                                    true))
  (vim.tbl_map (fn [f]
                 (vim.cmd (.. "source " (vim.fn.fnameescape f))))
               after-paths)
  (length after-paths))

;(fn __cmpSetup []
;(packadd! nvim-cmp)
(local cmp (autoload :cmp))
;(local soft-deps [:friendly-luasnip :luasnip :haskell-snippets])

(. (require :cmp_nvim_lsp) :default_capabilities)

(local source_plugins [:cmp_path
                       :cmp_buffer
                       :cmp_cmdline
                       :cmp_luasnip
                       :cmp_conjure
                       :cmp_nvim_lsp])

; (: (vim.iter (vim.list_extend soft-deps source_plugins)) :each
;    (fn [p] (vim.cmd.packadd p)))

(local after_sourced (load_after_plugin :cmp*.lua))
(when (not= after_sourced (length source_plugins))
  (vim.notify (.. "expected " (length source_plugins)
                  " cmp source after/plugin sources, but got " after_sourced)
              vim.log.levels.WARN))

(local fidget (autoload :fidget))
(local luasnip (autoload :luasnip))
(local progress
       ((. (autoload :fidget.progress) :handle :create) {:lsp_client {:name "CMP::"}}))

(progress:report {:message "Setting Up luasnip"
                  :level vim.log.levels.ERROR
                  :progress 0})

((->> :setup (. (autoload :luasnip))) {:enable_autosnippets true
                                       :load_ft_func (. (autoload :luasnip_snippets.common.snip_utils)
                                                        :load_ft_func)
                                       :ft_func (. (autoload :luasnip_snippets.common.snip_utils)
                                                   :ft_func)})

(local haskell_snippets (. (require :haskell-snippets) :all))
(luasnip.add_snippets :haskell haskell_snippets {:key :haskell})
((. (autoload :luasnip.loaders.from_lua) :load) {:paths ["~/.config/nvim/snippets/"]})
(progress:report {:message "Registering CMP Sources!"
                  :level vim.log.levels.ERROR
                  :progress 20})

((->> :setup (. (require :cmp))) {:experimental {:ghost_text false}
                                  :window {:documentation {:border :solid}
                                           :completion {:col_offset (- 3)
                                                        :side_padding 0
                                                        :winhighlight "Normal:NormalFloat,NormalFloat:Pmenu,Pmenu:NormalFloat"}}
                                  :view {:entries {:name :custom
                                                   :selection_order :near_cursor}}
                                  :enabled (fn []
                                             (local context
                                                    (require :cmp.config.context))
                                             (if (= (. (vim.api.nvim_get_mode)
                                                       :mode)
                                                    :c)
                                                 true
                                                 (and (not (context.in_treesitter_capture :comment))
                                                      (not (context.in_syntax_group :Comment)))))
                                  :sources [{:name :luasnip :group_index 2}
                                            {:name :nvim_lsp :group_index 1}
                                            {:name :lazydev :group_index 0}
                                            {:name :neorg :group_index 1}
                                            {:name :crates :group_index 2}
                                            {:name :buffer :group_index 1}
                                            ;{:name :conjure}
                                            {:name :path :group_index 0}]
                                  :preselect cmp.PreselectMode.None
                                  :snippet {:expand (fn [args]
                                                      (luasnip.lsp_expand args.body))}
                                  :mapping {:<C-b> (cmp.mapping.scroll_docs -4)
                                            :<C-f> (cmp.mapping.scroll_docs 4)
                                            :<C-Space> (cmp.mapping.complete)
                                            :<C-p> (cmp.mapping.select_prev_item)
                                            :<C-n> (cmp.mapping.select_next_item)
                                            :<CR> (cmp.mapping.confirm {:behavior cmp.ConfirmBehavior.Insert
                                                                        :select false})
                                            :<C-e> (fn [fallback]
                                                     (if (cmp.visible)
                                                         (do
                                                           (cmp.mapping.close)
                                                           (vim.cmd :stopinsert))
                                                         (fallback)))
                                            :<Tab> (cmp.mapping (fn [fallback]
                                                                  (if (cmp.visible)
                                                                      (cmp.select_next_item)
                                                                      (luasnip.expand_or_jumpable)
                                                                      (luasnip.expand_or_jump)
                                                                      (has-words-before)
                                                                      (cmp.complete)
                                                                      :else
                                                                      (fallback)))
                                                                [:i :s :c])
                                            :<S-Tab> (cmp.mapping (fn [fallback]
                                                                    (if (cmp.visible)
                                                                        (cmp.select_prev_item)
                                                                        (luasnip.jumpable -1)
                                                                        (luasnip.jump -1)
                                                                        :else
                                                                        (fallback)))
                                                                  [:i :s :c])}
                                  :formatting {:fields {1 :kind
                                                        2 :abbr
                                                        3 :menu}
                                               :format (fn [_ vim-item]
                                                         (set vim-item.menu
                                                              vim-item.kind)
                                                         (set vim-item.kind
                                                              (. shared.codicons
                                                                 vim-item.kind))
                                                         vim-item)}})

((->> :setup (. (autoload :luasnip_snippets.common.snip_utils))))
(progress:report {:message "Setting Up cmp"
                  :level vim.log.levels.ERROR
                  :progress 0})

(cmp.setup.cmdline "@"
                   {:mapping (cmp.mapping.preset.cmdline)
                    :sources [{: entry_filter :group_index 1 :name :fuzzy_path}
                              {:group_index 1
                               :name :cmdline
                               :option {:ignore_cmds {}}}]})

(cmp.setup.cmdline "/" {:mapping (cmp.mapping.preset.cmdline)
                        :sources [{:name :buffer}]})

(cmp.setup.cmdline ":"
                   {:mapping (cmp.mapping.preset.cmdline)
                    :sources [{:name :path :group_index 2}
                              {:name :cmdline :group_index 1}]})

; ((->> :setup
;       (. (require :scissors))) {:snipperDir "~/.config/nvim"})

((. (require :luasnip.loaders.from_vscode) :lazy_load) {:paths ["~/.config/nvim/snippets/"]})
; (map! [n] :<leader>cse `((->> :editSnippet
;                               (. (require :scissors))))
;       {:desc "Edit Snippet"})

; (map! [n] :<leader>csc `((->> :addNewSnippet
;                               (. (require :scissors))))
;       {:desc "create Snippet"})

(luasnip.add_snippets :haskell haskell_snippets {:key :haskell})
((. (autoload :luasnip.loaders.from_lua) :load) {:paths ["~/.config/nvim/snippets/"]})
(progress:report {:message "Setup Completed" :title :Completed! :progress 100})
(progress:finish)
