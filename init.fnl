;; disable builtin vim plugins and providers, small speedup
(local default-plugins [:2html_plugin
                        :getscript
                        :getscriptPlugin
                        :gzip
                        :logipat
                        :netrw
                        :netrwPlugin
                        :netrwSettings
                        :netrwFileHandlers
                        :matchit
                        :tar
                        :tarPlugin
                        :rrhelper
                        :spellfile_plugin
                        :vimball
                        :vimballPlugin
                        :zip
                        :zipPlugin
                        :tutor
                        :rplugin
                        :syntax
                        :synmenu
                        :optwin
                        :compiler
                        :bugreport
                        :ftplugin])

(local default-providers [:node :perl :ruby])

;; Workaround for Image.nvim
(each [_ plugin (pairs default-plugins)] (tset vim.g (.. :loaded_ plugin) 1))
(each [_ provider (ipairs default-providers)]
  (tset vim.g (.. :loaded_ provider :_provider) 0))

;; check if hotpot exists
(if (pcall require :hotpot)
    (do
      ;; if it does, load it
      ((. (require :hotpot) :setup) {:enable_hotpot_diagnostics true
                                     :provide_require_fennel true
                                     :compiler {:macros {:allowGlobals true
                                                         :compilerEnv _G
                                                         :env :_COMPILER}
                                                :modules {:correlate true
                                                          :useBitLib true}}})
      ;; if NYOOM_PROFILE is set, load profiling code
      (when (os.getenv :NYOOM_PROFILE)
        ((. (require :core.lib.profile) :toggle)))
      ;; load nyoom standard library
      (local stdlib (require :core.lib))
      (each [k v (pairs stdlib)] (rawset _G k v))
      ;; load nyoom
      (require :core))
    ;; else print error
    (print "Unable to require hotpot"))
