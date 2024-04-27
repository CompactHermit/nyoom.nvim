(import-macros {: nyoom-module!} :macros)

(nyoom-module! tools.tree-sitter)
; (use-package! :nvim-treesitter/nvim-treesitter
;               {:nyoom-module tools.tree-sitter
;                :cmd [:TSInstall
;                      :TSUpdate
;                      :TSInstallSync
;                      :TSUpdateSync
;                      :TSBufEnable
;                      :TSBufDisable
;                      :TSEnable
;                      :TSDisable
;                      :TSModuleInfo]
;                :requires [(pack :nvim-treesitter/playground
;                                 {:cmd :TSPlayground})
;                           (pack :HiPhish/nvim-ts-rainbow2 {:opt true})
;                           (pack :JoosepAlviste/nvim-ts-context-commentstring
;                                 {:opt true})
;                           (pack :nvim-treesitter/nvim-treesitter-refactor
;                                 {:opt true})
;                           (pack :nvim-treesitter/nvim-treesitter-textobjects
;                                 {:opt true})
;                           (pack :Ckolkey/ts-node-action {:opt true})]
;                :setup (fn []
;                         (vim.api.nvim_create_autocmd [:BufRead]
;                                                      {:group (vim.api.nvim_create_augroup :nvim-treesitter
;                                                                                           {})
;                                                       :callback (fn []
;                                                                   (when (fn []
;                                                                           (local file
;                                                                                  (vim.fn.expand "%"))
;                                                                           (and (and (not= file
;                                                                                           :nvimTree_1)
;                                                                                     (not= file
;                                                                                           "[packer]"))
;                                                                                (not= file
;                                                                                      "")))
;                                                                     (vim.api.nvim_del_augroup_by_name :nvim-treesitter)
;                                                                     ((. (autoload :packer)
;                                                                         :loader) :nvim-treesitter)))}))})
;
; (use-package! :nvim-treesitter/nvim-treesitter-context
;               {:opt true
;                :event [:BufWritePost]
;                :config (fn []
;                          (local {: setup} (require :treesitter-context))
;                          (setup {:enable true}))})
