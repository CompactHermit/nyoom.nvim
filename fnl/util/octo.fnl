(local choice_edge_case {:all ""})
(local defaults {:repo :CompactHermit
                 :pr :all
                 :issue :all
                 :label :Bug
                 :gist :all})

(fn caller [options ch]
  (vim.ui.select options {:format_item (fn [item] (.. "Octo " ch " " item))
                          :prompt "Select a choice"}
                 (fn [choice]
                   (when (vim.tbl_contains [:issue
                                            :gist
                                            :pr
                                            :repo
                                            :search
                                            :label]
                                           ch)
                     (when (vim.tbl_contains [:search
                                              :list
                                              :edit
                                              :create
                                              :resolve
                                              :unresolve
                                              :add
                                              :remove
                                              :create]
                                             choice)
                       (vim.ui.input {:default (. defaults ch)
                                      :prompt (.. "Enter a option for " ch
                                                  " > ")}
                                     (fn [ch2]
                                       (when (vim.tbl_contains options ch2)
                                         (set-forcibly! ch2
                                                        (. choice_edge_case ch2)))
                                       (vim.cmd (.. "Octo " ch2 " " choice " "
                                                    ch2))))
                       (fn []
                         (vim.cmd (.. "Octo " ch " " choice))))
                     (fn []
                       (vim.notify "No Optional Params listed")
                       (when (and (not= choice nil) (not= ch nil))
                         (global command (.. "Octo " ch " " choice))
                         (vim.cmd command)))))))

{: caller}
