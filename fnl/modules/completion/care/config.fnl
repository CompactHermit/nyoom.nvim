(local care (require :care))
;
; ;;https://github.com/nvim-neorocks/lz.n/wiki/lazy%E2%80%90loading-nvim%E2%80%90cmp-and-its-extensions
(local source-plugins [;:cmp-path
                       :cmp-buffer
                       ;:cmp-cmdline 
                       :cmp-luasnip])

(-> (vim.iter source-plugins)
    (: :each
       #(each [_ dir (ipairs (vim.opt.packpath:get))]
          (let [glob (vim.fs.joinpath :pack "*" :opt $1)
                plugdir (vim.fn.globpath dir glob nil true true)]
            (when (not (vim.tbl_isempty plugdir))
              (do
                ((. (require :rtp_nvim) :source_after_plugin_dir) (. plugdir 1))))))))

;; 7 Labels

;; TODO:: Refactor Luasnip Junk ->> +care.Snippets
(local luasnip (autoload :luasnip))
((->> :setup (. luasnip)) {:enable_autosnippets true
                           :update_events [:TextChanged :TextChangedI]
                           :region_check_events :InsertEnter
                           :load_ft_func (. (autoload :luasnip_snippets.common.snip_utils)
                                            :load_ft_func)
                           :ft_func (. (autoload :luasnip_snippets.common.snip_utils)
                                       :ft_func)})

(local snip-expand (. (require :luasnip) :snip_expand))
(tset (require :luasnip) :snip_expand
      (fn [...] (set vim.o.ul vim.o.ul) (snip-expand ...)))

(vim.keymap.set [:i :s] :<c-j> #((. (require :luasnip) :jump) 1))

(vim.keymap.set [:i :s] :<c-k> #((. (require :luasnip) :jump) (- 1)))

((. (require :luasnip.loaders.from_vscode) :lazy_load) {:paths ["~/.config/nvim/snippets/"]})

(local haskell_snippets (. (require :haskell-snippets) :all))
(luasnip.add_snippets :haskell haskell_snippets {:key :haskell})
((. (autoload :luasnip.loaders.from_lua) :load) {:paths ["~/.config/nvim/snippets/"]})

(local labels [:q :e :r :t :z :i])

((. (require :care.sources.path) :setup))
(care.setup {:preselect false
             :snippet_expansion #((. (require :luasnip) :lsp_expand) $1)
             :selection_behavior :insert
             :sorting_direction :away-from-cursor
             :sources {:lsp {:enabled true
                             :priority 1
                             :filter #(values (not= (. $1 :completion_item
                                                       :kind)
                                                    1))}
                       :cmp_path {:enabled false}
                       :cmp_buffer {:enabled true}
                       :path {:priority 1000}
                       ;;:cmp_cmdline {:enabled true}
                       ;;:cmp_conjure {:enabled true}
                       ;;:cmp_overseer {:enabled true}
                       :cmp_luasnip {:enabled true}}
             :ui {:docs_view {:border :none :max_height 10 :max_width 80}
                  :ghost_text {:enabled false}
                  :menu {:border :none
                         :scrollbar {:enabled false}
                         :alignments [:left :left :left :center]
                         :max_view_entries 10
                         :format_entry #(let [labels [:q :e :r :t :z :i]
                                              components (require :care.presets.components)
                                              preset-utils (require :care.presets.utils)]
                                          [(components.ShortcutLabel labels $1
                                                                     $2)
                                           (components.Label $1 $2 true)
                                           (components.KindIcon $1 :blended)
                                           [[(.. " (" $2.source_name ") ")
                                             (preset-utils.kind_highlight $1
                                                                          :fg
                                                                          :max_width
                                                                          15)]]])}}})

(let [labels [:q :e :r :t :z :i]]
  (each [i label (ipairs labels)]
    (vim.keymap.set :i (.. :<c- label ">")
                    #((. (. (require :care) :api) :select_visible) i))))

;;OMNIFUNC
(vim.keymap.set :i :<c-x><c-o>
                #((. (require :care) :api :complete) #(= $1 :lsp)))

(vim.keymap.set :i :<c-x><c-f>
                #((. (require :care) :api :complete) #(= $1 :cmp_path)))

;; Snippet Expand
(vim.keymap.set :i :<c-n> #(vim.snippet.jump 1))
(vim.keymap.set :i :<c-m> #(vim.snippet.jump (- 1)))

(vim.keymap.set [:i] :<c-f>
                #(if ((. (. (require :care) :api) :doc_is_open))
                     ((. (. (require :care) :api) :scroll_docs) 4)
                     ((. (require :luasnip) :choice_active))
                     ((. (require :luasnip) :change_choice) 1)
                     (vim.api.nvim_feedkeys (vim.keycode :<c-f>) :n false)))

(vim.keymap.set [:i] :<c-d>
                #(if ((. (. (require :care) :api) :doc_is_open))
                     ((. (. (require :care) :api) :scroll_docs) (- 4))
                     ((. (require :luasnip) :choice_active))
                     ((. (require :luasnip) :change_choice) (- 1))
                     (vim.api.nvim_feedkeys (vim.keycode :<c-f>) :n false)))

(vim.keymap.set [:i] :<CR> "<Plug>(CareConfirm)")
(vim.keymap.set [:i] :<c-b> "<Plug>(CareClose)")
(vim.keymap.set [:i] :<S-Tab> "<Plug>(CareSelectPrev)")
(vim.keymap.set [:i] :<Tab> "<Plug>(CareSelectNext)")
