(import-macros {: packadd!
                : nyoom-module-p!
                : map!
                : custom-set-face!
                : let!
                : autocmd!
                : augroup!} :macros)

;; (local utils (require :util.treesitter))

;; Conditionally enable leap-ast

(nyoom-module-p! bindings
                 (do
                   (packadd! leap-ast.nvim)
                   (let [leap-ast (autoload :leap-ast)]
                     (map! [nxo] :gs `(leap-ast.leap) {:desc "Leap AST"}))))

(local treesitter-filetypes [:vimdoc :fennel :vim :regex :query])

;; SEE:: https://github.com/nickel-lang/tree-sitter-nickel/tree/main
(nyoom-module-p! nickel
                 (do
                   ;; Autoload for efficiency
                   (local tsp (autoload :nvim-treesitter.parsers))
                   (local parser-config (tsp.get_parser_configs))
                   (set parser-config.nickel
                        {:install_info {:url "https://github.com/nickel-lang/tree-sitter-nickel"
                                        :files [:src/parser.c :src/scanner.cc]
                                        :branch :main
                                        :generate_requires_npm false
                                        :requires_generate_from_grammar false}})
                   (table.insert treesitter-filetypes :nickel)))

;; conditionally install parsers

(nyoom-module-p! clojure (table.insert treesitter-filetypes :clojure))

(nyoom-module-p! common-lisp (table.insert treesitter-filetypes :commonlisp))

(nyoom-module-p! csharp (table.insert treesitter-filetypes :c_sharp))

(nyoom-module-p! java (table.insert treesitter-filetypes :java))

(nyoom-module-p! go (table.insert treesitter-filetypes :go))

(nyoom-module-p! julia (table.insert treesitter-filetypes :julia))

(nyoom-module-p! kotlin (table.insert treesitter-filetypes :kotlin))

(nyoom-module-p! latex (table.insert treesitter-filetypes :latex))

(nyoom-module-p! lua (table.insert treesitter-filetypes :lua))

(nyoom-module-p! nix (table.insert treesitter-filetypes :nix))

(nyoom-module-p! python (table.insert treesitter-filetypes :python))

(nyoom-module-p! sh (table.insert treesitter-filetypes :bash))

(nyoom-module-p! sh.+fish (table.insert treesitter-filetypes :fish))

(nyoom-module-p! sh.+nu (table.insert treesitter-filetypes :nu))

(nyoom-module-p! zig (table.insert treesitter-filetypes :zig))

(nyoom-module-p! cc
                 (do
                   (table.insert treesitter-filetypes :c)
                   (table.insert treesitter-filetypes :cpp)))

(nyoom-module-p! rust
                 (do
                   (table.insert treesitter-filetypes :rust)
                   (table.insert treesitter-filetypes :toml)))

(nyoom-module-p! markdown
                 (do
                   (table.insert treesitter-filetypes :markdown)
                   (table.insert treesitter-filetypes :markdown_inline)
                   (table.insert treesitter-filetypes :html)))

(nyoom-module-p! vc-gutter
                 (do
                   (table.insert treesitter-filetypes :git_rebase)
                   (table.insert treesitter-filetypes :gitattributes)
                   (table.insert treesitter-filetypes :gitcommit)))

;; (table.insert treesitter-filetypes :gitignore)))

(nyoom-module-p! org
                 (do
                   (local tsp (autoload :nvim-treesitter.parsers))
                   (local parser-config (tsp.get_parser_configs))
                   (set parser-config.org
                        {:filetype :org
                         :install_info {:url "https://github.com/milisims/tree-sitter-org"
                                        :files [:src/parser.c :src/scanner.cc]
                                        :branch :main}})
                   (table.insert treesitter-filetypes :org)))

(nyoom-module-p! ocaml (table.insert treesitter-filetypes :ocaml))

(nyoom-module-p! zellij (table.insert treesitter-filetypes :kdl))

(nyoom-module-p! neorg
                 (do
                   (local tsp (autoload :nvim-treesitter.parsers))
                   (local parser-config (tsp.get_parser_configs)) ; (set parser-config.norg ;      {:install_info {:url "https://github.com/nvim-neorg/tree-sitter-norg"
                   ;                      :files [:src/parser.c :src/scanner.cc]
                   ;                      :branch :main ;                      :use_makefile true}})
                   (set parser-config.norg_meta
                        {:install_info {:url "https://github.com/nvim-neorg/tree-sitter-norg-meta"
                                        :files [:src/parser.c]
                                        :branch :main}})
                   (set parser-config.norg_table
                        {:install_info {:url "https://github.com/nvim-neorg/tree-sitter-norg-table"
                                        :files [:src/parser.c]
                                        :branch :main}})
                   (table.insert treesitter-filetypes :norg)
                   (table.insert treesitter-filetypes :norg_table)
                   (table.insert treesitter-filetypes :norg_meta)))

;; load dependencies

;(packadd! nvim-ts-rainbow2)
;; (packadd! nvim-ts-refactor)
(packadd! nvim-treesitter-textobjects)
(packadd! ts-node-action)

;; setup hl groups for ts-rainbow

(custom-set-face! :TSRainbowRed [] {:fg "#878d96" :bg :NONE})
(custom-set-face! :TSRainbowYellow [] {:fg "#a8a8a8" :bg :NONE})
(custom-set-face! :TSRainbowBlue [] {:fg "#8d8d8d" :bg :NONE})
(custom-set-face! :TSRainbowOrange [] {:fg "#a2a9b0" :bg :NONE})
(custom-set-face! :TSRainbowGreen [] {:fg "#8f8b8b" :bg :NONE})
(custom-set-face! :TSRainbowViolet [] {:fg "#ada8a8" :bg :NONE})
(custom-set-face! :TSRainbowCyan [] {:fg "#878d96" :bg :NONE})

;; ┌─────────────────────────┬
;; │  Treesitter Autocmds::  │
;; └─────────────────────────┘

; (autocmd! :FileType "*" #(fn [ci]
;                            (vim.fn.schedule (fn []
;                                               (if (and (utils.active? (ci.buf)) (not= (: vim.opt_local.foldmethod :get) :diff))
;                                                   (print :hello)))))
;
;           {:group (vim.api.nvim_create_augroup :TSFolds {})})

;; ┌─────────────────────────┬
;; │  Treesitter Setup:   :  │
;; └─────────────────────────┘

(setup :nvim-treesitter.configs
       {;;:ensure_installed treesitter-filetypes
        :highlight {:enable true :use_languagetree true}
        :indent {:enable true}
        :refactor {:enable true :keymaps {:smart_rename :<localleader>rn}}
        :query_linter {:enable true
                       :use_virtual_text true
                       :lint_events [:BufWrite :CursorHold]}
        :rainbow {:enable true
                  :query {1 :rainbow-parens
                          :html :rainbow-tags
                          :latex :rainbow-blocks
                          :tsx :rainbow-tags
                          :vue :rainbow-tags}}
        :incremental_selection {:enable true
                                :keymaps {:init_selection :gn
                                          :node_incremental :gnn
                                          :scope_incremental :gnc
                                          :node_decremental :gnm}}
        :textobjects {:select {:enable true}
                      :lookahead true
                      :keymaps {:af "@function.outer"
                                :if "@function.inner"
                                :ac "@class.outer"
                                :ic "@class.inner"}
                      :move {:enable true
                             :set_jumps true
                             ;; Whether to add to jumplist, IDK y u'd disable this
                             :goto_next_start {"]n" "@function.outer"
                                               "]]" "@class.outer"
                                               "]nif" "@function.inner"
                                               "]np" "@parameter.inner"
                                               "]nc" "@call.outer"
                                               "]nic" "@call.inner"}
                             :goto_next_end {"]N" "@function.outer"
                                             "][" "@class.outer"}
                             :goto_previous_start {"[n" "@function.outer"
                                                   "[[" "@class.outer"}
                             :goto_previous_end {"[N" "@function.outer"
                                                 "[]" "@class.outer"}}}})

(packadd! nvim-ts-context-commentstring)
((->> :setup
      (. (require :ts_context_commentstring))))

(let! skip_ts_context_commentstring_module true)
