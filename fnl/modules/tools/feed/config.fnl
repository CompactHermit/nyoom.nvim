(let [feed (autoload :feed)]
  (feed.setup {:colorscheme :carbonfox
               :index {:keys {:m :tag :M :untag}
                       :opts {:conceallevel 0
                              :wrap false
                              :cmdheight 0
                              :number true
                              :relativenumber false
                              :modifiable false}}
               :entry {:keys {:m :tag :M :untag}
                       :opts {:conceallevel 0
                              :wrap false
                              :cmdheight 0
                              :number true
                              :relativenumber false
                              :modifiable false}}
               :feeds ["https://ludic.mataroa.blog/rss/"
                       "https://andrewkelley.me/rss.xml"
                       "https://vhyrro.github.io/rss.xml"]}))
