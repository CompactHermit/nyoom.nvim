(import-macros {: lzn!} :macros)

(lzn! :dap {:nyoom-module editor.debug
            :cmd [:DapNew :DapToggleRepl :DapEval]
            :wants [:overseer :telescope]
            :deps [:dapui :dap-python]})
