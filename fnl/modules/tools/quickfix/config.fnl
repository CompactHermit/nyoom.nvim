;; fnlfmt : skip
(let [fidget (autoload :fidget)
      quicker (require :quicker)
      progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :<Quickfix>}})]
  (progress:report {:message "Setting Up <Quickfix>"} :level
                   vim.log.levels.ERROR :progress 0)
  ((->> :setup (. quicker)) {:keys [{1 ">"
                                     2 #((. quicker :expand) {:before 2})
                                     :desc "[Ex]pand [Q]f Context"}
                                    {1 "<"
                                     2 #((. quicker :collapse))
                                     :desc "[C]ollpase [Q]f"}]})
  (progress:finish))
