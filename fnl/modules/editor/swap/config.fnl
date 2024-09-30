(import-macros {: set! : map!} :macros)

;; fnlfmt: skip
((->> :setup
      (. (require :syntax-tree-surfer))))
{:default_desired_types [:function
                         :function_definition
                         :struct_definition
                         :if_statement
                         :else_clause
                         :do_clause
                         :else_statement
                         :elseif_statement
                         :for_statement
                         :let_statement
                         :while_statement
                         :switch_statement]
 :disable_no_instance_found_report false
 :highlight_group :STS_highlight
 :icon_dictionary {:do_statement "𝒟"
                   :else_clause "ℯ"
                   :else_statement "ℯ"
                   :elseif_clause "ℯ"
                   :elseif_statement "ℯ"
                   :for_statement "ﭜ"
                   :function ""
                   :function_definition ""
                   :if_statement "𝒾"
                   :let_statement "ℒ"
                   :struct_definition "𝒮"
                   :switch_statement "ﳟ"
                   :variable_declaration ""
                   :while_statement "ﯩ"}
 :left_hand_side :fdsawervcxqtzb
 :right_hand_side "jkl;oiu.,mpy/n"}

(map! [n] :<A-f>
      `((->> :targeted_jump (. (require :syntax-tree-surfer))) [:function
                                                                :function_definition
                                                                :struct_definition
                                                                :if_statement
                                                                :else_clause
                                                                :do_clause
                                                                :else_statement
                                                                :elseif_statement
                                                                :for_statement
                                                                :let_statement
                                                                :while_statement
                                                                :switch_statement])
      {:desc "Node Jumps " :silent true})
