(import-macros {: use-package!} :macros)

(use-package! :RaafatTurki/hex.nvim
              {:nyoom-module tools.hex
               :opt true
               :cmd [:HexDump :HexAssemble :HexToggle]})
