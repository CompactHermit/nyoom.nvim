(import-macros {: nyoom-module-ensure!} :macros)
(nyoom-module-ensure! vc-gutter)
(let [neogit (autoload :neogit)
      gitsigns (autoload :gitsigns)
      fidget (require :fidget)
      progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :neogit}})
      __augroup (vim.api.nvim_create_augroup :HermitGit {:clear true})
      aucmd vim.api.nvim_create_autocmd]
  (progress:report {:message "Setting Up Neogit"
                    :level vim.log.levels.TRACE
                    :progress 0})
  (neogit.setup {:disable_signs true
                 :disable_hint true
                 :disable_context_highlighting false
                 :graph_style :kitty
                 :integrations {:diffview true :telescope true}
                 :sections {:recent {:folded true}}})
  (progress:report {:message "Setup Complete" :title :Completed! :progress 100})
  (aucmd :FileType {:pattern [:NeogitBranchDescription
                              :NeogitCommitMessage
                              :NeogitCommitView
                              :NeogitLogView
                              :NeogitMergeMessage
                              :NeogitPopup
                              :NeogitStatus
                              :NeogitTagMessage]
                    :callback #(set vim.b.toggle_line_style 0)
                    :group __augroup})
  (aucmd :User {:pattern [:NeogitCommitComplete
                          :NeogitPullComplete
                          :NeogitPushComplete
                          :NeogitStatusRefreshed]
                :callback #(gitsigns.refresh)
                :group __augroup}))
