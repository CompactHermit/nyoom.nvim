(import-macros {: lzn!} :macros)

(lzn! :dap
      {:nyoom-module editor.debug
       ;:on_require [:dap :dapui]
       :cmd [:DapNew :DapToggleRepl :DapEval]
       :wants [:overseer :telescope]
       :deps [:dapui :dap-rr :dap-python :nvim-dap-virtual-text]})
