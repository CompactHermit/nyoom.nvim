(import-macros {: packadd! : nyoom-module-p! : map! : custom-set-face!} :macros)

;; Conditionally enable leap-ast

(nyoom-module-p! bindings
                 (do
                   (packadd! leap-ast.nvim)
                   (let [leap-ast (autoload :leap-ast)]
                     (map! [nxo] :gs `(leap-ast.leap) {:desc "Leap AST"}))))

(local treesitter-filetypes [:vimdoc :fennel :vim :regex :query])

;; conditionally install parsers

(nyoom-module-p! clojure (table.insert treesitter-filetypes :clojure))

(nyoom-module-p! common-lisp (table.insert treesitter-filetypes :commonlisp))

(nyoom-module-p! csharp (table.insert treesitter-filetypes :c_sharp))

(nyoom-module-p! java (table.insert treesitter-filetypes :java))

(nyoom-module-p! julia (table.insert treesitter-filetypes :julia))

(nyoom-module-p! kotlin (table.insert treesitter-filetypes :kotlin))

(nyoom-module-p! latex (table.insert treesitter-filetypes :latex))

(nyoom-module-p! lua (table.insert treesitter-filetypes :lua))

(nyoom-module-p! nix (table.insert treesitter-filetypes :nix))

(nyoom-module-p! python (table.insert treesitter-filetypes :python))

(nyoom-module-p! sh (table.insert treesitter-filetypes :bash))

(nyoom-module-p! sh.+fish (table.insert treesitter-filetypes :fish))

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
                   (table.insert treesitter-filetypes :markdown_inline)))

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

(nyoom-module-p! neorg
                 (do
                   (local tsp (autoload :nvim-treesitter.parsers))
                   (local parser-config (tsp.get_parser_configs))
                   (set parser-config.norg
                        {:install_info {:url "https://github.com/nvim-neorg/tree-sitter-norg"
                                        :files [:src/parser.c :src/scanner.cc]
                                        :branch :dev
                                        :use_makefile true}})
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

(packadd! nvim-ts-rainbow2)
(packadd! nvim-ts-refactor)
(packadd! nvim-treesitter-textobjects)
(packadd! nvim-ts-context-commentstring) 

;; setup hl groups for ts-rainbow

(custom-set-face! :TSRainbowRed  [] {:fg "#878d96" :bg :NONE})
(custom-set-face! :TSRainbowYellow [] {:fg "#a8a8a8" :bg :NONE})
(custom-set-face! :TSRainbowBlue [] {:fg "#8d8d8d" :bg :NONE})
(custom-set-face! :TSRainbowOrange [] {:fg "#a2a9b0" :bg :NONE})
(custom-set-face! :TSRainbowGreen [] {:fg "#8f8b8b" :bg :NONE})
(custom-set-face! :TSRainbowViolet [] {:fg "#ada8a8" :bg :NONE})
(custom-set-face! :TSRainbowCyan [] {:fg "#878d96" :bg :NONE})

;; the usual
(setup :nvim-treesitter.configs
       {:ensure_installed treesitter-filetypes
        :highlight {:enable true :use_languagetree true}
        :indent {:enable true}
        :context_commentstring {:enable true}
        :refactor {:enable true
                   :keymaps {:smart_rename "<localleader>rn"}}
        :query_linter {:enable true
                       :use_virtual_text true
                       :lint_events ["BufWrite" "CursorHold"]}
        :rainbow {:enable true
                  ;;:extended_mode true
                  :query {1 :rainbow-parens
                          :html :rainbow-tags
                          :latex :rainbow-blocks
                          :tsx :rainbow-tags
                          :vue :rainbow-tags}}
        :incremental_selection {:enable true
                                :keymaps {:init_selection :gnn
                                          :node_incremental :grn
                                          :scope_incremental :grc
                                          :node_decremental :grm}}
        :textobjects {:select {:enable true}
                      :lookahead true
                      :keymaps {:af "@function.outer"
                                :if "@function.inner"
                                :ac "@class.outer"
                                :ic "@class.inner"}
                      :move {:enable true
                             :set_jumps true ;; Whether to add to jumplist, IDK y u'd disable this
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
; peek_definition_code = {
;                         ["gl"] = "@function.outer",
;                         ["gK"] = "@class.outer",}
;                 ,
;             ,
;             move = {
;                     enable = enable,
;                     set_jumps = true, -- whether to set jumps in the jumplist
;                     goto_next_start = {
;                                        ["gnf"] = "@function.outer",
;                                        ["gnif"] = "@function.inner",
;                                        ["gnp"] = "@parameter.inner",
;                                        ["gnc"] = "@call.outer",
;                                        ["gnic"] = "@call.inner",}
;                     ,
;                     goto_next_end = {
;                                      ["gnF"] = "@function.outer",
;                                      ["gniF"] = "@function.inner",
;                                      ["gnP"] = "@parameter.inner",
;                                      ["gnC"] = "@call.outer",
;                                      ["gniC"] = "@call.inner",}
;                     ,
;                     goto_previous_start = {
;                                            ["gpf"] = "@function.outer",
;                                            ["gpif"] = "@function.inner",
;                                            ["gpp"] = "@parameter.inner",
;                                            ["gpc"] = "@call.outer",
;                                            ["gpic"] = "@call.inner",}
;                     ,
;                     goto_previous_end = {
;                                          ["gpF"] = "@function.outer",
;                                          ["gpiF"] = "@function.inner",
;                                          ["gpP"] = "@parameter.inner",
;                                          ["gpC"] = "@call.outer",
;                                          ["gpiC"] = "@call.inner",}
;                     ,}
;             ,
;             select = {
;                       enable = true,
;                       include_surrounding_whitespace = true,
;                       keymaps = {
;                                  ["af"] = { query = "@function.outer", desc = "ts: all function" },
;                                  ["if"] = { query = "@function.inner", desc = "ts: inner function" },
;                                  ["ac"] = { query = "@class.outer", desc = "ts: all class" },
;                                  ["ic"] = { query = "@class.inner", desc = "ts: inner class" },
;                                  ["aC"] = { query = "@conditional.outer", desc = "ts: all conditional" },
;                                  ["iC"] = { query = "@conditional.inner", desc = "ts: inner conditional" },
;                                  -- FIXME: this is unusable
;                                  -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects/issues/133 is resolved
;                                  -- ['ax'] = '@comment.outer',}
;                       ,}
;             ,
;             swap = {
;                     enable = enable,
;                     swap_next = { ["<leader>a"] = "@parameter.inner" },
;                     swap_previous = { ["<leader>A"] = "@parameter.inner" },}
;             ,
;         ,
