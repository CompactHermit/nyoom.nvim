(import-macros {: use-package!} :macros)

(use-package! :danielhp95/tmpclone-nvim 
              {:nyoom-module tools.browse.+tmp_clone}
              :opt true
              :cmd ["TmpcloneClone" "TmpcloneOpen" "TmpcloneRemove"])

