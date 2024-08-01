(let [msc (autoload :music-controls)]
  ((. msc :setup) {:default_player :spotify}))
