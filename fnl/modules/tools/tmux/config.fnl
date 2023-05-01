;;(local {: register} (autoload :which-key))
;;(local tmux-term (require :tmux-awsome-manager.src.term))
;;
;;(register {:r {:R (tmux-term {:cmd "rails s"
;;                                        :name "Rails Server"
;;                                        :open_as :separated_session
;;                                        :session_name "My Terms"
;;                                        :visit_first_call false})
;;                  :b (tmux-term {:close_on_timer 2
;;                                        :cmd "bundle install"
;;                                        :focus_when_call false
;;                                        :name "Bundle Install"
;;                                        :open_as :pane
;;                                        :visit_first_call false})
;;                  :d (tmux-term {:cmd "rails destroy %1"
;;                                        :name "Rails Destroy"
;;                                        :questions [{:close_on_timer 4
;;                                                     :focus_when_call false
;;                                                     :open_as :pane
;;                                                     :question "Rails destroy: "
;;                                                     :required true
;;                                                     :visit_first_call false}]})
;;                  :g (tmux-term {:cmd "rails generate %1"
;;                                        :name "Rails Generate"
;;                                        :questions [{:close_on_timer 4
;;                                                     :focus_when_call false
;;                                                     :open_as :pane
;;                                                     :question "Rails generate: "
;;                                                     :required true
;;                                                     :visit_first_call false}]})
