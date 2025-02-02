(import-macros {: map! : nyoom-module-p!} :macros)
(local qn (require :quicknote))

(setup :quicknote {:mode :portable
                   :sign :N
                   :filetype :norg})

;; TODO:: find a way to handle a vim.ui.input that returns back a value, rather then exec a function and consume the val.
;; It's this stupid thing that's forcing me to use the "require". 


(nyoom-module-p! neorg
   (do
      (map! [n] :<leader>nqC `(qn.NewNoteAtCWD) {:desc "Create Note:: CWD"})
      ;;(map! [n] :<leader>nql `(qn.NewNoteAtLine (choose_line)) {:desc "Create Note:: Line + Input"})
      (map! [n] :<leader>nqc `(qn.NewNoteAtCurrentLine) {:desc "Create Note:: Current Line"})
      (map! [n] :<leader>nqg `(qn.NewNoteAtGlobal) {:desc "Create Note:: Global + Input"})
      (map! [n] :<leader>nqo `(qn.OpenNoteAtCWD) {:desc "Open Note:: CWD + Input"})
      ; (map! [n] :<leader>nqO `(qn.OpenNoteAtLine (choose_line)) {:desc "Open Note:: Choose Line"})
      (map! [n] :<leader>nqL `(qn.OpenNoteAtCurrentLine) {:desc "Open Note:: Current Line"})
      (map! [n] :<leader>nqG `(qn.OpenNoteAtGlobal) {:desc "Open Note:: Global + Input"})
      (map! [n] :<leader>nqm `(qn.DeleteNoteAtCWD) {:desc "Delete Note::CWD + Input"})
      ; (map! [n] :<leader>nqM `(qn.DeleteNoteAtLine (choose_line)) {:desc "Delete Note:: Choose Line"})
      (map! [n] :<leader>nqd `(qn.DeleteNoteAtCurrentLine) {:desc "Delete Note:: Current Line"})
      (map! [n] :<leader>nqD `(qn.DeleteNoteGlobal) {:desc "Delete Note:: Global + Input"})
      (map! [n] :<leader>nqb `(qn.ListNotesForCurrentBuffer) {:desc "List Note:: Buffer"})
      (map! [n] :<leader>nqw `(qn.ListNotesForCWD) {:desc "List Notes:: CWD"})
      (map! [n] :<leader>nqW `(qn.ListNotesForGlobal) {:desc "List Notes:: Global"})
      (map! [n] :<leader>nqj `(qn.JumpToNextNote) {:desc "Jump Note:: Next"})
      (map! [n] :<leader>nqh `(qn.JumpToNextNote) {:desc "Jump Note:: Previous"})
      (map! [n] :<leader>nqs `(qn.ToggleNoteSigns) {:desc "Show Signs"})
      (map! [n] :<leader>nqR `(qn.SwitchToResidentMode) {:desc "Switch Mode:: Resident"})
      (map! [n] :<leader>nqP `(qn.SwitchToPortableMode) {:desc "Switch Mode:: Portable"})))
