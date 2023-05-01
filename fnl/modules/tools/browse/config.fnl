;; Setup for browse shit, copy and paste the other nyoom module boiler plate bs here
(global bookmarks
       {:default {:github {:code_search "https://github.com/search?q=%s&type=code"
                           :issues_search "https://github.com/search?q=%s&type=issues"
                           :name "search github from neovim"
                           :pulls_search "https://github.com/search?q=%s&type=pullrequests"
                           :repo_search "https://github.com/search?q=%s&type=repositories"}
                  :medium {"article_lookup " "https://medium.com/search?q=%s"
                           :data_science "https://towardsdatascience.com/search?q=%s"
                           :name "Search Medium for data"}
                  :pytorch {:name "Search Pytorch Docs and Forms"
                            :torch_arrow "https://pytorch.org/torcharrow/beta/search.html?q=%s&check_keywords=yes&area=default"
                            :torch_audio "https://pytorch.org/audio/stable/search.html?q=%s&check_keywords=yes&area=default"
                            :torch_data "https://pytorch.org/data/beta/search.html?q=%s&check_keywords=yes&area=default"
                            :torch_docs "https://pytorch.org/docs/stable/search.html?q=%s&check_keywords=yes&area=default"
                            :torch_rec "https://pytorch.org/torchrec/stable/search.html?q=%s&check_keywords=yes&area=default"
                            :torch_serve "https://pytorch.org/serve/stable/search.html?q=%s&check_keywords=yes&area=default"
                            :torch_text "https://pytorch.org/text/stable/search.html?q=%s&check_keywords=yes&area=default"
                            :torch_vision "https://pytorch.org/vision/stable/search.html?q=%s&check_keywords=yes&area=default"
                            :tutorial_search "https://pytorch.org/tutorials/search.html?q=%s&check_keywords=yes&area=default"}}})                              	

(setup :browse {:provider :duckduckgo
                :bookmarks bookmarks})

