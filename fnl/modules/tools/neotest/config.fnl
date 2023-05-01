
(import-macros {: nyoom-module-p! : command!} :macros)

(nyoom-module-p! neotest
    (do
     (local testings {:adapters [((require :neotest-python) {:dap {:justMyCode false}}
                                  (require :neotest-rust)
                                  (require :neotest-haskell))]
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
                      :icons {:child_indent "│"
                              :child_prefix "├"
                              :collapsed "─"
                              :expanded "╮"
                              :failed "✖"
                              :final_child_indent " "
                              :final_child_prefix "╰"
                              :non_collapsible "─"
                              :passed "✔"
                              :running "🗘"
                              :skipped "ﰸ"
                              :unknown "?"}
                      :output {:enabled true :open_on_build :short}
                      :status {:enabled true}
                      :strategies {:integrated {:height 40
                                                :width 120}}
                      :summary {:enabled true
                                :expand_errors true
                                :follow true
                                :mappings {:attach :a
                                           :build :r
                                           :expand [:<CR>
                                                    :<2-LeftMouse>]
                                           :expand_all :e
                                           :jumpto :i
                                           :output :o
                                           :short :O
                                           :stop :u}}})
     (setup :neotest {: testings})))


;;_________________________________________________________________________________________
(fn Near []
  (vim.cmd "lua require('neotest').run.run(vim.fn.expand('%'))"))
(fn Current []
  (vim.cmd "lua require('neotest').run.run(vim.fn.expand('%'))"))
(fn output []
  (vim.cmd "lua require('neotest').output.open({ enter = true})"))
(fn stop []
  (vim.cmd "lua require('neotest').run.stop()"))
(fn summary []
  (vim.cmd "lua require('neotest').summary.toggle()"))
(fn attach []
  (vim.cmd "lua require('neotest').run.attach()"))

(nyoom-module-p! neotest
 (do
  (command! TestNear `(Near) {:desc "Neotest Run test"})
  (command! TestCurrent `(Current) {:desc "Neotest Run Curent file"})
  (command! TestOutput `(output) {:desc "Neotest Open output"})
  (command! TestSummary `(summary) {:desc "Neotest Run test"})
  (command! TestStrat (fn [args]
                       (let [options [:dap :integrated]]
                         (if (vim.tbl_contains options args.arg)
                             ((. (. (require :neotest) :run) :run) {:strategy args.args})
                             ((. (. (require :neotest) :run) :run) {:strategy :integrated}))))
            {:desc "Neotest strategen"})
  (command! TestStop `(stop) {:desc "Neotest Test stop"})
  (command! TestAttach `(attach))))



