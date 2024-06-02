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

(fn __cmpSetup []
  (packadd! nvim-cmp)
  (packadd! friendly-luasnip)
  (packadd! luasnip)
  (packadd! cmp-path)
  (packadd! cmp-buffer)
  (packadd! cmp-nvim-lua)
  (packadd! cmp-cmdline)
  (packadd! cmp-luasnip)
  (packadd! cmp-nvim-lsp-signature-help)
  (packadd! cmp-nvim-lsp) ; (packadd! cmp-nvim-lsp-signature-help) ; (packadd! cmp-conjure) ; (packadd! cmp-lspkind)  ; (packadd! cmp-vimtex) ; (packadd! cmp-latexsm) ; (packadd! cmp-dap)
  (packadd! haskell-snippets)
  (local fidget (autoload :fidget))
  (local progress
         ((. (autoload :fidget.progress) :handle :create) {:lsp_client {:name "CMP::"}}))
  (local cmp (autoload :cmp))
  (local luasnip (autoload :luasnip))
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
  (cmp.register_source :buffer (autoload :cmp_buffer))
  (cmp.register_source :cmdline ((->> :new (. (autoload :cmp_cmdline)))))
  (cmp.register_source :path ((->> :new (. (autoload :cmp_path)))))
  (cmp.register_source :luasnip ((. (autoload :cmp_luasnip) :new)))
  ;(cmp.register_source :nvim_lsp_document_symbol ((. (autoload :cmp_nvim_lsp_document_symbol) :new)))
  (cmp.register_source :nvim_lua ((. (autoload :cmp_nvim_lua) :new)))
  ((->> :setup (. (autoload :cmp_nvim_lsp))))
  (cmp.register_source :nvim_lsp_signature_help
                       ((. (autoload :cmp_nvim_lsp_signature_help) :new)))
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
                                    :sources [{:name :luasnip}
                                              {:name :nvim_lsp}
                                              {:name :nvim_lua}
                                              {:name :lazydev :group_index 0}
                                              {:name :neorg :group_index 1}
                                              {:name :crates :group_index 2}
                                              {:name :buffer}
                                              {:name :path}]
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
                      :sources [{: entry_filter
                                 :group_index 1
                                 :name :fuzzy_path}
                                {:group_index 1
                                 :name :cmdline
                                 :option {:ignore_cmds {}}}]})
  (cmp.setup.cmdline "/" {:mapping (cmp.mapping.preset.cmdline)
                          :sources [{:name :buffer}]})
  (cmp.setup.cmdline ":"
                     {:mapping (cmp.mapping.preset.cmdline)
                      :sources [{:name :path :group_index 2}
                                {:name :cmdline :group_index 1}]})
  ((->> :setup
        (. (require :scissors))) {:snipperDir "~/.config/nvim"})
  ((. (require :luasnip.loaders.from_vscode) :lazy_load) {:paths ["~/.config/nvim/snippets/"]})
  (map! [n] :<leader>cse
        `((->> :editSnippet
               (. (require :scissors)))) {:desc "Edit Snippet"})
  (map! [n] :<leader>csc
        `((->> :addNewSnippet
               (. (require :scissors)))) {:desc "create Snippet"})
  (luasnip.add_snippets :haskell haskell_snippets {:key :haskell})
  ((. (autoload :luasnip.loaders.from_lua) :load) {:paths ["~/.config/nvim/snippets/"]})
  (progress:report {:message "Setup Completed" :title :Completed! :progress 99}))

(vim.api.nvim_create_autocmd [:InsertEnter]
                             {:callback #(__cmpSetup) :once true})
