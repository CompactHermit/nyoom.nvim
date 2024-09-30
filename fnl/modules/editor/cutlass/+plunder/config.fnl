(let [sub (require :substitute)
      setup sub.setup]
  (setup {:highlight_substituted_text {:enabled true :timer 200}
          :on_substitute ((. (require :yanky.integration) :substitute))
          :exchange {:motion false
                     :use_esc_to_cancel true
                     :preserve_cursor_position false}
          :range {:prefix :s
                  :prompt_current_text false
                  :confirm true
                  :complete_word false
                  :motion1 true
                  :motion2 true}
          :suffix ""}))
