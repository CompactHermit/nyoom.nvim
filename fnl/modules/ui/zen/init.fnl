(import-macros {: lzn!} :macros)

(lzn! :truezen
      {:nyoom-module ui.zen
       :event "BufReadPre *.norg"
       :cmd [:TZAtaraxis :TZNarrow :TZFocus :TZMinimalist :TZAtaraxis]})
