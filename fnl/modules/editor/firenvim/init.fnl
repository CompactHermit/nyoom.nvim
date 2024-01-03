(import-macros {: use-package!} :macros)

(use-package! :glacambre/firenvim
 {:opt false
  :nyoom-module editor.firenvim
  :run "vim.fn['firenvim#install'](0)"})
 
