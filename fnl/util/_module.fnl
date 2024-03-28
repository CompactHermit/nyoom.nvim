(fn _lMods! []
  "
    lMods!:: [Modules]
    Returns a list of modules. Do note, this will not return nested modules
  "
  (let [list {}
        tmp (vim.split (vim.fn.globpath (.. "." :/fnl/modules/) :*/*/config.fnl)
                       "\n")]
    (each [_ f (ipairs tmp)]
      (vim.notify (string.format "Inserting:: %s into %s" f list)
                  vim.log.levels.warning)
      (tset list (+ (length list) 1) f))
    (each [_ f (ipairs list)]
      (print f))))

(_lMods!)
