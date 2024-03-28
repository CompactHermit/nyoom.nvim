(import-macros {: autocmd! : augroup! : packadd!} :macros)
(local {: capabilities : on_init} (require :util.lsp))

(do
  (vim.api.nvim_create_augroup :goSetup {:clear true})
  (autocmd! BufReadPost :*.go
            (fn []
              (packadd! go-nvim)
              ((->> :setup (. (require :go))) {:go :go
                                               :goimport :gopls
                                               :fillstruct :gopls
                                               :gofmt :gopls
                                               :lsp_cfg true
                                               :lsp_gofumpt false
                                               :lsp_keymaps false
                                               :lsp_codelens true
                                               :lsp_document_formatting false
                                               :diagnostic {:hdlr true
                                                            :underline true
                                                            :virtual_text true
                                                            :signs true}
                                               :lsp_inlay_hints {:enable true
                                                                 :only_current_line false
                                                                 :only_current_line_autocmd :CursorHold
                                                                 :show_variable_name true
                                                                 :show_parameter_hints true
                                                                 :parameter_hints_prefix ""
                                                                 :max_len_align false
                                                                 :max_len_align_padding 1
                                                                 :other_hints_prefix "=>"
                                                                 :right_align false
                                                                 :right_align_padding 6
                                                                 :highlight :Comment}
                                               :textobjects true})
              {:group :goSetup :desc "Go Setup"})))
