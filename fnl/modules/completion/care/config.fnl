(local care (require :care))
;
; ;;https://github.com/nvim-neorocks/lz.n/wiki/lazy%E2%80%90loading-nvim%E2%80%90cmp-and-its-extensions
(local source-plugins [:cmp-path :cmp-buffer :cmp-cmdline :cmp-luasnip])
(-> (vim.iter source-plugins)
    (: :each
       #(each [_ dir (ipairs (vim.opt.packpath:get))]
          (let [glob (vim.fs.joinpath :pack "*" :opt $1)
                plugdir (vim.fn.globpath dir glob nil true true)]
            (when (not (vim.tbl_isempty plugdir))
              (do
                ((. (require :rtp_nvim) :source_after_plugin_dir) (. plugdir 1))))))))

;; 7 Labels

;; LuaSnip Stuffs
(local luasnip (autoload :luasnip))
((->> :setup (. luasnip)) {:enable_autosnippets true
                           :load_ft_func (. (autoload :luasnip_snippets.common.snip_utils)
                                            :load_ft_func)
                           :ft_func (. (autoload :luasnip_snippets.common.snip_utils)
                                       :ft_func)})

((. (require :luasnip.loaders.from_vscode) :lazy_load) {:paths ["~/.config/nvim/snippets/"]})

; (local haskell_snippets (. (require :haskell-snippets) :all))
; (luasnip.add_snippets :haskell haskell_snippets {:key :haskell})
((. (autoload :luasnip.loaders.from_lua) :load) {:paths ["~/.config/nvim/snippets/"]})

(local labels [:q :r :t :z :i :o])

;; fnlfmt: skip
(care.setup {:preselect false
             :snippet_expansion (. (require :luasnip) :lsp_expand)
             :sources {:lsp {:enabled true}
                       :cmp_buffer {:enabled true}
                       :cmp_cmdline {:enabled true}
                       :cmp_luasnip {:enabled true}}
             :ui {:docs_view {:border :none :max_height 10 :max_width 80}
                  :ghost_text {:enabled false}
                  :menu {:border :none
                         :format_entry (fn [entry data]
                                         (local deprecated
                                                (or entry.completion_item.deprecated
                                                    (vim.tbl_contains (or entry.completion_item.tags
                                                                          {})
                                                                      1)))
                                         (local completion-item
                                                entry.completion_item)
                                         (local type-icons
                                                (. (. (. (require :care.config)
                                                         :defaults)
                                                      :ui)
                                                   :type_icons))
                                         (local entry-kind
                                                (or (and (= (type completion-item.kind)
                                                            :string)
                                                         completion-item.kind)
                                                    ((. (require :care.utils.lsp)
                                                        :get_kind_name) completion-item.kind)))
                                         [[[(.. " "
                                                (((. (require :care.presets.utils)
                                                     :LabelEntries) labels) entry data)
                                                " ")
                                            :Comment]]
                                          [[(completion-item.label:sub 1 26)
                                            (or (and deprecated
                                                     "@lsp.mod.deprecated")
                                                "@care.entry")]]
                                          [[(.. " "
                                                (or (. type-icons entry-kind)
                                                    type-icons.Text))
                                            (: "@care.type.%s" :format
                                               entry-kind)]]])
                         :max_width 25}}})

(let [labels [:q :r :t :z :i :o]]
  (each [i label (ipairs labels)]
    (vim.keymap.set :i (.. :<c- label ">")
                    #((. (. (require :care) :api) :select_visible) i))))

;;OMNIFUNC
(vim.keymap.set :i :<c-x><c-o> #(. (require :care) :api :complete #(= $1 :lsp)))

;; Snippet Expand
(vim.keymap.set :i :<c-n> #(vim.snippet.jump 1))
(vim.keymap.set :i :<c-m> #(vim.snippet.jump (- 1)))
(vim.keymap.set :i :<CR> #((. (. (require :care) :api) :complete)))

(vim.keymap.set :i :<c-f>
                #(if ((. (. (require :care) :api) :doc_is_open))
                     ((. (. (require :care) :api) :scroll_docs) 4)
                     ((. (require :luasnip) :choice_active))
                     ((. (require :luasnip) :change_choice) 1)
                     (vim.api.nvim_feedkeys (vim.keycode :<c-f>) :n false)))

(vim.keymap.set :i :<c-d>
                #(if ((. (. (require :care) :api) :doc_is_open))
                     ((. (. (require :care) :api) :scroll_docs) (- 4))
                     ((. (require :luasnip) :choice_active))
                     ((. (require :luasnip) :change_choice) (- 1))
                     (vim.api.nvim_feedkeys (vim.keycode :<c-f>) :n false)))

(vim.keymap.set :i :<cr> "<Plug>(CareConfirm)")
(vim.keymap.set :i :<c-e> "<Plug>(CareClose)")
(vim.keymap.set :i :<S-Tab> "<Plug>(CareSelectPrev)")
(vim.keymap.set :i :<Tab> "<Plug>(CareSelectNext)")
