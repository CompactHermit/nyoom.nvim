;; TODO:: Port the lua autocmds
(import-macros {: augroup! : autocmd! : packadd!} :macros)
(setup :windows
       {:autowidth {:enable true :winwidth 50}
        :animation {:enable true :duration 100 :fps 60}})

; (local oxocarbon {:base04 "#37474F"
;                   :base05 "#90A4AE"
;                   :base06 "#525252"
;                   :base07 "#08bdba"
;                   :base08 "#ff7eb6"
;                   :base09 "#ee5396"
;                   :base10 "#FF6F00"
;                   :base11 "#0f62fe"
;                   :base12 "#673AB7"
;                   :base13 "#42be65"
;                   :base14 "#be95ff"
;                   :base15 "#FFAB91"
;                   :blend "#FAFAFA"
;                   :none :NONE})

(local oxo (. (require :oxocarbon) :oxocarbon))
(local modes
       {:i {:hl {:MyCursor {:bg oxo.base08}}
            :winhl {:CursorLine {:fg oxo.base08}
                    :CursorLineNr {:fg oxo.base08}}}
        :n {:winhl {:CursorLine {:fg oxo.base08}
                    :CursorLineNr {:fg oxo.base12}}}
        :no {:hl {}
             :operators {:d {:hl {:MyCursor {:fg oxo.base15}}
                             :winhl {:CursorLine {:fg oxo.base14}}}
                         :y {:hl {:MyCursor {:fg oxo.base10}}
                             :winhl {:CursorLine {:fg oxo.base12}}}}
             :winhl {}}
        [:v :V "\022"] {:winhl {:CursorLineNr {:fg oxo.base04}}}})

(local __mode {:init (fn [] (vim.opt.guicursor:append "a:MyCursor")
                       (set vim.opt.cursorline true)
                       (vim.cmd "hi! ColorColumn guifg=Red guibg='#380000'
                                hi! CursorLine guibg=#021020
                                hi! CursorLineNr gui=bold"))
               :lazy false
               : modes
               :name :default
               :priority 100})

(packadd! :reactive-nvim)
((->> :setup (. (require :reactive))) {:builtin {:cursorline true
                                                 :cursor true
                                                 :modemsg true}})

((->> :add_preset (. (require :reactive))) __mode)
