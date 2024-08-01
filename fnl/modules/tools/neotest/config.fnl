(import-macros {: packadd!} :macros)

;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds

(let [fidget (require :fidget)
      animate (fn []
                (vim.tbl_map (fn [s]
                               (.. s " "))
                             ["⠋"
                              "⠙"
                              "⠹"
                              "⠸"
                              "⠼"
                              "⠴"
                              "⠦"
                              "⠧"
                              "⠇"
                              "⠏"]))
      progress ((. (require :fidget.progress) :handle :create) {:lsp_client {:name :neotest}})
      opts {:adapters [;((autoload :neotest-python) {:dap {:justMyCode false}})
                       (require :rustaceanvim.neotest)
                       ((. (require :neotest-zig) :setup) {:dap {:adapter :lldb}})
                       ;; Fennel Has a weird way of loading functions, the return actually fucks with neotest-busted's loader. Odd.
                       (require :neotest-busted)
                       ;(require :neotest-plenary)
                       ((require :neotest-haskell) {:build_tools [:cabal]
                                                    :framework [:tasty :hspec]})]
            :build {:enabled true}
            :diagnostic {:enabled true}
            :highlights {:adapter_name :NeotestAdapterName
                         :border :NeotestBorder
                         :dir :NeotestDir
                         :expand_marker :NeotestExpandMarker
                         :failed :NeotestFailed
                         :file :NeotestFile
                         :focused :NeotestFocused
                         :indent :NeotestIndent
                         :namespace :NeotestNamespace
                         :passed :NeotestPassed
                         :running :NeotestRunning
                         :skipped :NeotestSkipped
                         :test :NeotestTest}
            :icons {:passed " "
                    :running " "
                    :failed " "
                    :unknown " "
                    :running_animated (animate)}
            :output {:enabled true :open_on_build :short :open_on_run true}
            :status {:enabled true :virtual_text true}
            :strategies {:integrated {:height 40 :width 120}}
            :overseer {:enabled true :force_default true}
            :discovery {:enabled true
                        :filter_dir #(match $1
                                       (where _haskell
                                              (vim.startswith _haskell
                                                              :dist-newstyle))
                                       false
                                       (where _node
                                              (vim.startswith _node
                                                              :node-modules))
                                       false
                                       _ (values true))}
            :quickfix {:enabled true}
            :summary {:enabled true
                      :expand_errors true
                      :follow true
                      :mappings {:attach :a
                                 :build :r
                                 :expand [:<CR> :<2-LeftMouse>]
                                 :expand_all :e
                                 :jumpto :i
                                 :output :o
                                 :short :O
                                 :stop :u}}}]
  (progress:report {:message "Setting Up neotest"
                    :level vim.log.levels.ERROR
                    :progress 0})
  ((->> :setup (. (require :neotest))) opts)
  (progress:report {:message "Setup Complete" :title :Completed! :progress 100}))
