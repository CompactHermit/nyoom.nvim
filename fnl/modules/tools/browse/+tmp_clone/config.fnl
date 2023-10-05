(import-macros {: map! : nyoom-module-p!} :macros)
(setup :tmpclone {})

(fn  clone-repo []
  (vim.ui.input {:prompt "Repo to clone?"}
                (fn [callback]
                  ((. (require :tmpclone.core) :clone) (tostring callback)))))

(nyoom-module-p! browse
          (do
            (map! [n] "<leader>qc" `(clone-repo) {:desc "Clone Repo"})
            (map! [n] "<leader>qo" "<cmd>TmpcloneOpen<cr>" {:desc "Open Repo"})
            (map! [n] "<leader>qr" "<Cmd>TmpcloneRemove<cr>" {:desc "Remove Repo"})))
