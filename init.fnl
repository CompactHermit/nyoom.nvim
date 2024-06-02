;; disable builtin vim plugins and providers, small speedup
; (local default-plugins [:2html_plugin
;                         :getscript
;                         :getscriptplugin
;                         :gzip
;                         :logipat
;                         :netrw
;                         :netrwplugin
;                         :netrwsettings
;                         :netrwfilehandlers
;                         :matchit
;                         :tar
;                         :tarplugin
;                         :rrhelper
;                         :spellfile_plugin
;                         :vimball
;                         :vimballplugin
;                         :zip
;                         :zipplugin
;                         :tutor
;                         :rplugin
;                         :syntax
;                         :synmenu
;                         :optwin
;                         :compiler
;                         :bugreport])
;
; (each [_ plugin (pairs default-plugins)] (tset vim.g (.. :loaded_ plugin) 1))
;
; ((. (require :hotpot) :setup) {:enable_hotpot_diagnostics true
;                                :provide_require_fennel true
;                                :compiler {:macros {:allowGlobals true
;                                                    :compilerEnv _G
;                                                    :env :_COMPILER}
;                                           :modules {:correlate true
;                                                     :useBitLib true}}})
;
; ; (each [_ dir (ipairs (: vim.opt.runtimepath :get))]
; ;   (if (vim.endswith dir :hermit_Cache)
; ;       (let [home (vim.fn.stdpath :config)]
; ;         (vim.opt.runtimepath [home dir vim.env.VIMRUNTIME (.. home :/after)])
; ;         (vim.opt.packpath [dir vim.env.VIMRUNTIME]))))
; ;
; ;; if NYOOM_PROFILE is set, load profiling code
; ;(when (os.getenv :NYOOM_PROFILE) ;  ((. (require :core.lib.profile) :toggle)))
; ;; load nyoom standard library
; (local stdlib (require :core.lib))
;
; (each [k v (pairs stdlib)] (rawset _G k v))
(require :core)
