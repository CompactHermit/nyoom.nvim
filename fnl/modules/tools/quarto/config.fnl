(import-macros {: packadd! : map! : autocmd! : command!} :macros)

(do
  (vim.api.nvim_create_augroup :otterSetup {:clear true})
  (autocmd! BufReadPost :*.norg
            (fn []
              (packadd! otter)
              ((->> :setup (. (require :otter))) {:handle_leading_whitespace true
                                                  :lsp {:hover {:border :none}}
                                                  :buffers {:write_to_disk true}}))
            {:group :otterSetup :desc "Otter Setup"}))

;; Note::(Hermit) Formatter has an aneurysm formating this

;; fnlfmt: skip
(do
  (vim.api.nvim_create_augroup :quartoSetup {:clear true})
  (autocmd! BufWritePost :*.norg (fn []
                                   (packadd! quarto)
                                   ((. (require :quarto) :setup) {:lspFeatures {:lang [:r :python :rust :lua :nix :go :c :cpp :typ :hs]
                                                                                :chunks :all
                                                                                :diagnostics {:enabled true
                                                                                              :triggers :BufWritePost}
                                                                                :completions {:enabled true}}}))) {:group "quartoSetup" :desc "Quarto Setup"})

(command! NeorgOtter
          (fn []
            ((->> :activate (. (require :quarto))))
            (let [bufnr (vim.api.nvim_get_current_buf)
                  bufmap (fn [bufnr lhs rhs]
                           (vim.api.nvim_buf_set_keymap bufnr :n lhs rhs
                                                        {:silent false
                                                         :noremap true}))]
              (doto bufnr
                (bufmap :<leader>noa ":lua require'otter'.ask_definition()<cr>")
                (bufmap :<leader>not
                        ":lua require'otter'.ask_type_definition()<cr>")
                (bufmap :<leader>non ":lua require'otter'.ask_rename()<cr>")
                (bufmap :<leader>nor ":lua require'otter'.ask_references()<cr>")
                (bufmap :<leader>nod
                        ":lua require'otter'.ask_document_symbols()<cr>")
                (bufmap :<leader>nos ":lua require'otter'.ask_hover()<cr>")))))
