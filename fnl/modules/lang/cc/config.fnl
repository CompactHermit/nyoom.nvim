(import-macros {: map!} :macros)
(local icons _G.shared.codicons)
(local diags _G.shared.icons)

(setup :clangd_extensions {:inline true
                           :extensions {:autoSetHints false
                                        :inlay_hints {:only_current_line  true
                                                      :highlight :LspInlayHint}
                                        :ast  {:role_icons {:type  icons.Type
                                                            :declaration  icons.Function
                                                            :expression  icons.Snippet
                                                            :specifier  icons.Specifier
                                                            :statement  icons.Statement
                                                            :template icons.TypeParameter}
                                               :kind_icons {:Compound  icons.Namespace
                                                            :Recovery  icons.DiagnosticSignError
                                                            :TranslationUnit  icons.Unit
                                                            :PackExpansion  icons.Ellipsis
                                                            :TemplateTypeParm  icons.TypeParameter
                                                            :TemplateTemplateParm  icons.TypeParameter
                                                            :TemplateParamObject  icons.TypeParameter}}}
                                       :memory_usage {:border :solid}
                                       :symbol_info  {:border :solid}})

;; ┌──────────────────────────────────────┐
;; │       Keybinds and autocmds          │
;; └──────────────────────────────────────┘
(fn setlist [arr]
     " 
     setlist:: x[] -> x*[]
         Returns list of formatted strings for norg to render
     "
 (local _list [])
 (each [_ k (ipairs arr)]
   (match k
     (where k (~= (string.match k "nix") nil)) (table.insert _list (.. "** {" "/ " (string.gsub k ":%d[%d.*]:%s.*" "") "}" "[" (string.gsub k ".*[%d]:[%d.*].:." "" 1) "]"))
     (where k (~= (string.match k "home") nil)) (vim.notify "Home Links are broken, will get back after consulting regex wizards" 2)
     _ nil))
 _list)

(fn render [array]
  "
  Takes an Array of paths and renders a norg buffer with links to each
  TODO:: Add keybinds for lines
  "
 (local bufnr (vim.api.nvim_create_buf true true))
 (local ui (. (vim.api.nvim_list_uis) 1))
 (local list (setlist array))
 (local opts {:relative :editor
              :width 150
              :height (+ (length list) 3)
              :col (- (/ ui.width 2)  25)
              :row (- (/ ui.height 2)  5)
              :anchor :NW
              :style :minimal})
 (doto bufnr
   (vim.api.nvim_buf_set_option :filetype :norg)
   (vim.api.nvim_buf_set_lines  0 -1 true list)
   (vim.api.nvim_buf_set_option :modifiable false)
   (vim.api.nvim_buf_set_keymap :n :<CR> "<CMD> lua vim.notify('Hello There', 2)<CR>"  {:desc "IDK"})
   (vim.api.nvim_open_win 1 opts)
   (vim.api.nvim_win_set_cursor [0 0])))

;; NOTE:: This is a WIP, for now we'll just display strings on a buffer. Not entirely sure how to creates links::
(map! [n] :<leader>cs #(vim.ui.input {:prompt "Enter type to check:: " :default "int"}
                         (fn [input]
                           (local out (vim.fn.systemlist (.. :coogler " " (vim.fn.expand "%:p") " " "'" input "'")))
                           (render out))) {:desc "Coogler search"})

