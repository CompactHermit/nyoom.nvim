(import-macros {: map! : nyoom-module-p! : packadd!} :macros)

;; TODO:: find a way to handle a vim.ui.input that returns back a value, rather then exec a function and consume the val.
;; It's this stupid thing that's forcing me to use the "require". 
;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds
(fn __qnSetup []
  (packadd! quicknote)
  (let [fidget (require :fidget)
        qn (autoload :quicknote)
        progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :qn}})]
    (progress:report {:message "Setting Up qn"
                      :level vim.log.levels.ERROR
                      :progress 0})
    ((->> :setup (. (require :quicknote))) {:mode :resident
                                            :sign " "
                                            :filetype :norg})

    (fn qn_choose_line [opt]
      (match opt
        (where cond1 (= opt :Create)) (vim.ui.input {:prompt "Create a Line # :: "}
                                                    (fn [choice]
                                                      (qn.NewNoteAtLine (tonumber choice))))
        (where cond2 (= opt :Open)) (vim.ui.input {:prompt "Open at Line #:: "}
                                                  (fn [choice]
                                                    (qn.OpenNoteAtLine (tonumber choice))))))

    (nyoom-module-p! neorg
                     (do
                       (map! [n] :<leader>nqC `(qn.NewNoteAtCWD)
                             {:desc "Create Note:: CWD"})
                       (map! [n] :<leader>nql `(qn_choose_line :Create)
                             {:desc "Create Note:: Line + Input"})
                       (map! [n] :<leader>nqc `(qn.NewNoteAtCurrentLine)
                             {:desc "Create Note:: Current Line"})
                       (map! [n] :<leader>nqg `(qn.NewNoteAtGlobal)
                             {:desc "Create Note:: Global + Input"})
                       (map! [n] :<leader>nqw `(qn.OpenNoteAtCWD)
                             {:desc "Open Note:: CWD + Input"})
                       (map! [n] :<leader>nqL `(qn_choose_line :Open)
                             {:desc "Open Note:: Choose Line"})
                       (map! [n] :<leader>nqo `(qn.OpenNoteAtCurrentLine)
                             {:desc "Open Note:: Current Line"})
                       (map! [n] :<leader>nqG `(qn.OpenNoteAtGlobal)
                             {:desc "Open Note:: Global + Input"})
                       (map! [n] :<leader>nqm `(qn.DeleteNoteAtCWD)
                             {:desc "Delete Note::CWD + Input"})
                       (map! [n] :<leader>nqd `(qn.DeleteNoteAtCurrentLine)
                             {:desc "Delete Note:: Current Line"})
                       (map! [n] :<leader>nqD `(qn.DeleteNoteGlobal)
                             {:desc "Delete Note:: Global + Input"})
                       (map! [n] :<leader>nqb `(qn.ListNotesForCurrentBuffer)
                             {:desc "List Note:: Buffer"})
                       (map! [n] :<leader>nqw `(qn.ListNotesForCWD)
                             {:desc "List Notes:: CWD"})
                       (map! [n] :<leader>nqW `(qn.ListNotesForGlobal)
                             {:desc "List Notes:: Global"})
                       (map! [n] :<leader>nqj `(qn.JumpToNextNote)
                             {:desc "Jump Note:: Next"})
                       (map! [n] :<leader>nqh `(qn.JumpToNextNote)
                             {:desc "Jump Note:: Previous"})
                       (map! [n] :<leader>nqs `(qn.ShowNoteSigns)
                             {:desc "Show Signs"})
                       (map! [n] :<leader>nqR `(qn.SwitchToResidentMode)
                             {:desc "Switch Mode:: Resident"})
                       (map! [n] :<leader>nqP `(qn.SwitchToPortableMode)
                             {:desc "Switch Mode:: Portable"})))
    (progress:report {:message "Setup Complete"
                      :title :Completed!
                      :progress 99})))

(vim.api.nvim_create_autocmd :BufReadPost
                             {:pattern :*.norg
                              :callback #(__qnSetup)
                              :once true})
