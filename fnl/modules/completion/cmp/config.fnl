(import-macros {: set!
                : nyoom-module-p!
                : packadd!
                : autocmd!
                : augroup!
                : map!} :macros)

(local cmp (autoload :cmp))
(local luasnip (autoload :luasnip))
;; (local {: func} (require :utils.cmp))

; REFACTOR:: (Hermit) Rewrite this shit
(local fuzzy-path-option {:fd_cmd [:fd
                                   :-p
                                   :-H
                                   :-L
                                   :-td
                                   :-tf
                                   :-tl
                                   :-d4
                                   :--mount
                                   :-c=never
                                   :-E=*$*
                                   "-E=*%*"
                                   :-E=*.bkp
                                   :-E=*.bz2
                                   :-E=*.db
                                   :-E=*.directory
                                   :-E=*.dll
                                   :-E=*.doc
                                   :-E=*.docx
                                   :-E=*.drawio
                                   :-E=*.gif
                                   :-E=*.git/
                                   :-E=*.gz
                                   :-E=*.ico
                                   :-E=*.iso
                                   :-E=*.jar
                                   :-E=*.jpeg
                                   :-E=*.jpg
                                   :-E=*.mp3
                                   :-E=*.mp4
                                   :-E=*.o
                                   :-E=*.otf
                                   :-E=*.out
                                   :-E=*.pdf
                                   :-E=*.pickle
                                   :-E=*.png
                                   :-E=*.ppt
                                   :-E=*.pptx
                                   :-E=*.pyc
                                   :-E=*.rar
                                   :-E=*.so
                                   :-E=*.svg
                                   :-E=*.tar
                                   :-E=*.ttf
                                   :-E=*.venv/
                                   :-E=*.xls
                                   :-E=*.xlsx
                                   :-E=*.zip
                                   :-E=*Cache*/
                                   "-E=*\\~"
                                   :-E=*cache*/
                                   :-E=.*Cache*/
                                   :-E=.*cache*/
                                   :-E=.*wine/
                                   :-E=.cargo/
                                   :-E=.conda/
                                   :-E=.dot/
                                   :-E=.fonts/
                                   :-E=.ipython/
                                   :-E=.java/
                                   :-E=.jupyter/
                                   :-E=.luarocks/
                                   :-E=.mozilla/
                                   :-E=.npm/
                                   :-E=.nvm/
                                   :-E=.steam*/
                                   :-E=.thunderbird/
                                   :-E=.tmp/
                                   :-E=__pycache__/
                                   :-E=dosdevices/
                                   :-E=events.out.tfevents.*
                                   :-E=node_modules/
                                   :-E=vendor/
                                   :-E=venv/]})

(fn entry_filter [entry _]
  (not (vim.tbl_contains ["No matches found" :Searching... "Workspace loading"]
                         entry.completion_item.label)))

(set! completeopt [:menu :menuone :noselect])

;; add general cmp sources
(local cmp-sources [])

(table.insert cmp-sources {:name :luasnip :group_index 1})
(table.insert cmp-sources {:name :buffer :group_index 2})
(table.insert cmp-sources {:name :path :group_index 2})

(nyoom-module-p! rust (table.insert cmp-sources {:name :crates :group_index 1}))
(nyoom-module-p! tree-sitter
                 (do
                   ;;(packadd! cmp-treesitter)
                   (table.insert cmp-sources {:name :treesitter :group_index 2})))

(nyoom-module-p! latex
                 (table.insert cmp-sources {:name :vimtex :group_index 1}))

(nyoom-module-p! neorg
                 (do
                   ;;(packadd! cmp-latexsym)
                   (doto cmp-sources
                     (table.insert {:name :neorg :group_index 1})
                     (table.insert {:name :otter})
                     (table.insert {:name :latex_symbols :option {:strategy 0}}))))

(nyoom-module-p! overseer
                 (table.insert cmp-sources {:name :cmp_overseer :group_index 2}))

(nyoom-module-p! eval
                 (table.insert cmp-sources {:name :conjure :group_index 1}))

(nyoom-module-p! lsp (do
                       (table.insert cmp-sources {:name :nvim_lsp})
                       (table.insert cmp-sources
                                     {:name :nvim_lsp_signature_help
                                      :group_index 2})))

(fn has-words-before []
  (let [(line col) (unpack (vim.api.nvim_win_get_cursor 0))]
    (and (not= col 0) (= (: (: (. (vim.api.nvim_buf_get_lines 0 (- line 1) line
                                                              true)
                                  1) :sub col
                               col) :match "%s") nil))))

(setup :cmp {:experimental {:ghost_text false}
             :window {:documentation {:border :solid}
                      :completion {:col_offset (- 3)
                                   :side_padding 0
                                   :winhighlight "Normal:NormalFloat,NormalFloat:Pmenu,Pmenu:NormalFloat"}}
             :view {:entries {:name :custom :selection_order :near_cursor}}
             :enabled (fn []
                        (local context (autoload :cmp.config.context))
                        (nyoom-module-p! tree-sitter
                                         (if (= (. (vim.api.nvim_get_mode)
                                                   :mode)
                                                :c)
                                             true
                                             (and (not (context.in_treesitter_capture :comment))
                                                  (not (context.in_syntax_group :Comment))))))
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
             :sources cmp-sources
             :formatting {:fields {1 :kind 2 :abbr 3 :menu}
                          :format (fn [_ vim-item]
                                    (set vim-item.menu vim-item.kind)
                                    (set vim-item.kind
                                         (. shared.codicons vim-item.kind))
                                    vim-item)}})

;; LSP specific Autocompletions::

(nyoom-module-p! c
                 (cmp.setup.filetype [:c :cpp]
                                     {:sorting {:comparators (vim.list_extend [(require :clangd_extensions.cmp_scores)]
                                                                              ((->> :comparators
                                                                                    (. (require :cmp.config)
                                                                                       :get
                                                                                       :sorting))))}}))

;; Enable command-line completions

(cmp.setup.cmdline "/"
                   {:mapping (cmp.mapping.preset.cmdline)
                    :sources [{:name :buffer :group_index 1}]})

;; Enable search completions

(cmp.setup.cmdline ":"
                   {:mapping (cmp.mapping.preset.cmdline)
                    :sources [{:name :path} {:name :cmdline :group_index 1}]})

;; Enable Completion for vim.ui.select()
(cmp.setup.cmdline "@"
                   {:mapping (cmp.mapping.preset.cmdline)
                    :sources [{: entry_filter
                               :group_index 1
                               :name :fuzzy_path
                               :option fuzzy-path-option}
                              {:group_index 1
                               :name :cmdline
                               :option {:ignore_cmds {}}}]})

;; Snippets-nvim::
(do
  (vim.api.nvim_create_augroup :nvim-scissors {:clear true})
  (autocmd! InsertEnter *
            `(fn []
               ((->> :setup
                     (. (require :scissors))) {:snipperDir "~/.config/nvim"}))))

(map! [n] :<leader>cse `((->> :editSnippet
                              (. (require :scissors))))
      {:desc "Edit Snippet"})

(map! [n] :<leader>csc `((->> :addNewSnippet
                              (. (require :scissors))))
      {:desc "create Snippet"})

;; custom snippets
((. (autoload :luasnip.loaders.from_vscode) :lazy_load) {:paths ["~/.config/nvim/snippets/"]})
;;require("luasnip.loaders.from_vscode").lazy_load { paths = { "path/to/your/snippetFolder" } }
((. (autoload :luasnip.loaders.from_lua) :load) {:paths ["~/.config/nvim/snippets/"]})

(nyoom-module-p! haskell (local haskell_snippets (autoload :haskell_snippets))
                 ((. (luasnip.add_snippets :haskell haskell_snippets
                                           [:key :haskell]))))
