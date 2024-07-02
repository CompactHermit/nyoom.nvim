;; An Opiniated Hydra Keybind API::

;; TODO:: allow custom modes
;; TODO:: Cananocalize "config/body/hint" options. 
;;E.g:: config is a table, and passes onto the hydra arg {:config {:color :_color_ :position :_position_}}
(fn chunks [arr size]
  (var chunk 1)
  (var idx-in-chunk 1)
  (var out [[]])
  (each [_ v (pairs arr)]
    (tset out chunk idx-in-chunk v)
    (if (= idx-in-chunk size)
        (do
          (table.insert out [])
          (set chunk (+ chunk 1))
          (set idx-in-chunk 1))
        (do
          (set idx-in-chunk (+ 1 idx-in-chunk)))))
  (if (= 0 (table.maxn (. out (table.maxn out))))
      (table.remove out))
  out)

(fn respace-str [str size]
  (let [space (string.rep " " (- size (length str)))]
    (.. str space)))

(lambda hydra-key! [mode keymaps ?opts ?num]
  "
      Recursively define keybinds using nested tables

      ```fennel
      (hydra-key! :n
                   {:a {:name :abc
                   :hydra true
                   :which-key false
                   :hint '{:length num :alignment [h|v]}'
                   :config (fn [] yadada, e.g:: color, body, etc etc)
                   :b [#(print :ab) \"Print ab\"]
                   :c #(print :ac)}}
                   {:prefix :<leader>})
      ```

      The above example defines two keybinds:
      <leader>ab - prints 'ab', (has optional description)
      <leader>ac - prints 'ac'

      A group of keymaps can be 'hydrated' using `:hydra true` and its friends
   "
  (let [hydra (require :hydra)
        which-key (require :which-key)
        lines (or ?num 4)
        opts (or ?opts {})
        {:prefix ?prefix & opts} opts
        prefix (or ?prefix nil)
        {:hydra hydra? :name name? :config config? & keymaps} keymaps
        is-valid-cmd (fn [rhs]
                       (vim.tbl_contains [:string :function] (type rhs)))
        canonicalize-rhs (fn [rhs]
                           (if ;; Undocumented rhs
                               (is-valid-cmd rhs)
                               {:cmd rhs :final true}
                               ;; Documented rhs
                               (and (vim.islist rhs) (is-valid-cmd (. rhs 1)))
                               {:cmd (. rhs 1)
                                :desc (. rhs 2)
                                :exit (or false (. rhs 3))
                                :final true}
                               ;; Nested table, leave be
                               (not (vim.islist rhs))
                               rhs
                               ;; else
                               nil))
        keymaps (vim.tbl_map canonicalize-rhs keymaps)
        autogen-hint (fn [keysMAP name num]
                       (let [bind-desc (collect [lhs rhs (pairs keysMAP)]
                                         (. lhs)
                                         (. rhs :desc))
                             max-strlen (accumulate [max 0 k v (pairs bind-desc)]
                                          (math.max max (length (.. k v))))
                             spaced-strs (icollect [k v (pairs bind-desc)]
                                           (respace-str (.. "_" k "_: " v)
                                                        (+ 7 max-strlen)))
                             name (or name "")]
                         (table.sort spaced-strs)
                         (.. "  " name ":\n"
                             (-> (icollect [_ v (ipairs (chunks spaced-strs num))]
                                   (.. "    " (table.concat v)))
                                 (table.concat "\n")))))
        base-keymap-opts {:silent true :noremap true}
        keymap-opts (vim.tbl_extend :force base-keymap-opts opts)]
    ;; NOTE:: (Hermit) Just use a Match, wtf are you doing??
    (if (= hydra? true)
        (do
          (local v
                 (hydra {:name name?
                         :hint (autogen-hint keymaps name? lines)
                         :config config?
                         : mode
                         :body prefix
                         :heads (icollect [lhs rhs (pairs keymaps)]
                                  (if rhs.final
                                      [lhs
                                       rhs.cmd
                                       {:desc rhs.desc :exit rhs.exit}]))}))
          (values v))
        (each [lhs rhs (pairs keymaps)]
          (let [lhs (.. prefix lhs)]
            (if rhs.final
                (vim.keymap.set mode lhs rhs.cmd
                                (vim.tbl_extend :force keymap-opts
                                                {:desc rhs.desc}))
                ;; else
                (do
                  (when (and rhs.name)
                    ;; Add name for group
                    (which-key.register {lhs {:name rhs.name}}))
                  (hydra-key! mode rhs
                              (vim.tbl_extend :force opts {:prefix lhs})))))))))

; (lambda sub-hydra! []
;   "
;     sub-hydra!:: <VarArgs> -> Hydra::Hydra!
;     Returns a subhydra. 
;     Inspired from vsedov's `innerModule` design
;   "
;   (nil))

{: hydra-key!}
