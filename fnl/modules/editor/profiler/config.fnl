(local should-profile (os.getenv :NVIM_PROFILE))
(when should-profile
  ((. (require :profile) :instrument_autocmds))
  (if (: (should-profile:lower) :match :^start)
      ((. (require :profile) :start) "*")
      ((. (require :profile) :instrument) "*")))

(fn toggle-profile []
  (let [prof (require :profile)]
    (if (prof.is_recording)
        (do
          (prof.stop)
          (vim.ui.input {:completion :file
                         :default :profile.json
                         :prompt "Save profile to:"}
                        (fn [filename]
                          (when filename (prof.export filename)
                            (vim.notify (string.format "Wrote %s" filename))))))
        (prof.start "*"))))

(vim.keymap.set "" :<M-p> toggle-profile)
;(vim.api.nvim_create_user_command :Profiler #(toggle-profile) {})
