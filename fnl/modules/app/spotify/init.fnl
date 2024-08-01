(import-macros {: lzn!} :macros)

(lzn! :music-controler {:nyoom-module app.spotify
                        :cmd [:MusicPlay
                              :MusicNext
                              :MusicPrev
                              :MusicPause
                              :MusicListPlayers
                              :MusicLoop
                              :MusicLoop
                              :MusicShuffle]})
