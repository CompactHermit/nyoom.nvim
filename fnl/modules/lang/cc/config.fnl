(import-macros {: map! : nyoom-module-p!} :macros)
(local icons _G.shared.codicons)
(local diags _G.shared.icons)

(setup :clangd_extensions
       {:inline true
        :extensions {:autoSetHints false
                     :inlay_hints {:only_current_line true
                                   :inline true
                                   :right_align true
                                   :show_parameter_hints true
                                   :highlight :LspInlayHint}
                     :ast {:role_icons {:type icons.Type
                                        :declaration icons.Function
                                        :expression icons.Snippet
                                        :specifier icons.Specifier
                                        :statement icons.Statement
                                        :template icons.TypeParameter}
                           :kind_icons {:Compound icons.Namespace
                                        :Recovery icons.DiagnosticSignError
                                        :TranslationUnit icons.Unit
                                        :PackExpansion icons.Ellipsis
                                        :TemplateTypeParm icons.TypeParameter
                                        :TemplateTemplateParm icons.TypeParameter
                                        :TemplateParamObject icons.TypeParameter}}}
        :memory_usage {:border :none}
        :symbol_info {:border :none}})

;; ┌──────────────────────────────────────┐
;; │       Keybinds and autocmds          │
;; └──────────────────────────────────────┘
(fn setlist [arr]
  " 
     NOTE:: Might Be better to use telescope, IMO
     setlist:: x[] -> x*[]
         Returns list of formatted strings for norg to render
     "
  (local _list [])
  (each [_ k (ipairs arr)]
    (match k
      (where k1 (not= (string.match k1 :nix) nil))
      (table.insert _list (.. "** {" "/ " (string.gsub k1 ":%d[%d.*]:%s.*" "")
                              "}" "[" (string.gsub k1 ".*[%d]:[%d.*].:." "" 1)
                              "]"))
      (where k (not= (string.match k :home) nil))
      (vim.notify "Links to local strings aren't supported, Need to get my regex wizard license first"
                  2)
      _ nil))
  _list)

(fn __render [array]
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
               :col (- (/ ui.width 2) 25)
               :row (- (/ ui.height 2) 5)
               :anchor :NW
               :style :minimal})
  (doto bufnr
    ;; TODO:: Create a 'toggleable' buffer, which can only be edited via a `Autocmd` 
    (vim.api.nvim_buf_set_option :filetype :norg)
    (vim.api.nvim_buf_set_name :Type_Search)
    (vim.api.nvim_buf_set_lines 0 -1 true list)
    ;; Because nvim is stupid, we have to bind a user event to trigger the split, since Neorg can't autoload itself,fml
    (vim.api.nvim_buf_create_user_command :MonkeyPatched
                                          (fn []
                                            (vim.cmd :vsplit)
                                            (vim.cmd "Neorg keybind norg core.esupports.hop.hop-link"))
                                          {:desc "I hate this, fml"})
    (vim.api.nvim_buf_set_keymap :n :<CR> :<cmd>MonkeyPatched<cr>
                                 {:desc "Bootleg hop-link"})
    (vim.api.nvim_buf_set_option :modifiable false)
    (vim.api.nvim_buf_set_option :winfixbuf true)
    (vim.api.nvim_open_win 1 opts))
  (vim.api.nvim_win_set_cursor [0 0]))

;; NOTE:: This is a WIP, for now we'll just display strings on a buffer. Not entirely sure how to creates links::
(map! [n] :<leader>cr `(vim.ui.input {:prompt "Enter type to check:: "}
                                     (fn [input]
                                       (local out
                                              (vim.fn.systemlist (.. :coogler
                                                                     " "
                                                                     (vim.fn.expand "%:p")
                                                                     " " "'"
                                                                     input "'")))
                                       (__render out)))
      {:desc "Coogler search"})
