(import-macros {: lzn!} :macros)

;;NOTE:: (Hermit) Just a replacement for now, until I learn how to `trick` lz.n's loader
(lzn! :Scratch-Cmds {:nyoom-module editor.scratch :load (fn []) :cmd :Scratch})
