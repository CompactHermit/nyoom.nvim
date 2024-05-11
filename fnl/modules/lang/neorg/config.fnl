(import-macros {: packadd! : nyoom-module-p! : autocmd! : nyoom-module-ensure!}
               :macros)

(fn neorg_leader [key]
  (.. :<leader>n key))

(local neorg-modules
       {:core.defaults {}
        :core.esupports.indent {:config {:dedent_excess true
                                         :format_on_escape true
                                         :format_on_enter true}}
        :core.ui {}
        :core.todo-introspector {}
        :core.integrations.telescope {}
        :external.exec {}
        ;;:external.timelog {}
        ;; NOTE:: (Hemrit) Only until janet has been added
        :external.hop-extras {:config {:aliases {:gh "https://github.com/{}"}}}
        ; :external.chronicle {:config {:workspace :main
        ;                               :directory :chronicle
        ;                               :modes {:daily {:path_format ["%Y"
        ;                                                             "%m-%B"
        ;                                                             "%d-%A"
        ;                                                             :daily.norg]}}
        ;                               :daily {:template_path ["%Y"
        ;                                                       "%m-%B"
        ;                                                       "%d-%A"
        ;                                                       :daily.norg]}
        ;                               :weekly {:template_path ["%Y"
        ;                                                        "%m-%B"
        ;                                                        "%W"
        ;                                                        :weekly.norg]}
        ;                               :monthly {:template_path ["%Y"
        ;                                                         "%m-%B"
        ;                                                         :monthly.norg]}
        ;                               :quarterly {:template_path ["%Y"
        ;                                                           "%Q"
        ;                                                           :quarterly.norg]}
        ;                               :yearly {:template_path ["%Y"
        ;                                                        :yearly.norg]}}}
        :core.summary {:config {:strategy :default}}
        :core.tempus {}
        :core.ui.calendar {}
        :core.integrations.image {}
        :core.latex.renderer {}
        :core.keybinds {:config {:default_keybinds true
                                 :neorg_leader :<leader>n
                                 :hook (fn [keybinds]
                                         ;; Wezterm things
                                         (keybinds.remap :norg :i :<M-CR>
                                                         :<S-CR>)
                                         (keybinds.map_event_to_mode :norg
                                                                     {:n [[(neorg_leader :lt)
                                                                           :core.integrations.telescope.find_aof_tasks]
                                                                          [(neorg_leader :lc)
                                                                           :core.integrations.telescope.find_context_tasks]
                                                                          [(neorg_leader :lh)
                                                                           :core.integrations.telescope.find_header_backlinks]
                                                                          [(neorg_leader :lb)
                                                                           :core.integrations.telescope.find_backlinks]
                                                                          [(neorg_leader :in)
                                                                           :core.itero.next-iteration]
                                                                          [(neorg_leader :ip)
                                                                           :core.itero.next-iteration]
                                                                          [:gk
                                                                           :core.manoeuvre.item_up]
                                                                          [:gk
                                                                           :core.manoeuvre.item_down]
                                                                          [:<Tab>
                                                                           :core.integrations.treesitter.next.link]
                                                                          [:<S-Tab>
                                                                           :core.integrations.treesitter.previous.link]
                                                                          ["]]"
                                                                           :core.integrations.treesitter.next.heading]
                                                                          ["[["
                                                                           :core.integrations.treesitter.previous.heading]]}
                                                                     {:noremap true
                                                                      :silent true})
                                         (keybinds.map_to_mode :norg
                                                               {:n [[(neorg_leader :li)
                                                                     "<cmd>Neorg timelog insert *<cr>"]]}
                                                               {:noremap true
                                                                :silent true}))}}
        :core.dirman {:config {:workspaces {:main "~/neorg"
                                            :Math "~/neorg/Math"
                                            :NixOS "~/neorg/nixDocs"
                                            :Chess "~/neorg/Chess"
                                            :Programming "~/neorg/CS"
                                            :Academic_Math "~/neorg/Papers/Math"
                                            :Academic_CS "~/neorg/Papers/CS"
                                            :Linuxopolis "~/neorg/linux"}
                               :default_workspace :main}}})

;; add conditional modules
(tset neorg-modules :core.completion {:config {:engine :nvim-cmp}})

;(nyoom-module-p! quarto (tset neorg-modules :core.integrations.otter {}))

;; add flaged modules
(tset neorg-modules :core.concealer
      {:config {:folds true
                :icon_preset :varied
                :icons {:code_block {:conceal true :padding {:left 1 :right 3}}
                        :todo {:done {:icon ""}
                               :pending {:icon ""}
                               :urgent {:icon ""}}}}})

(do
  (tset neorg-modules :core.integrations.roam
        {:config {:keymaps {:select_prompt :<c-space>
                            :insert_link :<leader>ncl
                            :find_note :<leader>ncf
                            :capture_note :<leader>ncn
                            :capture_index :<leader>nci
                            ; :get_backlinks :<leader>ncb
                            ; :db_sync :<leader>ncd
                            ; :db_sync_wksp :<leader>ncw
                            :capture_cancel :<C-q>
                            :capture_save :<C-w>}
                  :theme :ivy
                  ;:workspaces [:main :NixOS :Programming]
                  :capture_templates [{:name :default
                                       :title "${title}"
                                       :lines [""]}
                                      {:name "Math notes:: Theorem/Lemma"
                                       :title "${title}"
                                       :file "Math/${title}"
                                       :lines ["*.${heading1}::"
                                               "$.${Latex_Symbol}$"]}
                                      {:name "Capture Def"
                                       :title :$title
                                       :lines ["$$ ${def1}" "${def1}::" "$$"]}
                                      {:name "Nix notes"
                                       :file "nixDocs/${title}"
                                       :title "${title}"
                                       :lines ["* ${heading1}::"
                                               "* ${heading2}"]}]
                  :substitution {:title (fn [metadata]
                                          metadata.title)
                                 :date (fn [metadata]
                                         (os.date "%Y-%m-%d"))}}}))

(do
  (tset neorg-modules :core.presenter {:config {:zen_mode :truezen}}))

;(nyoom-module-p! neorg.+export)
(do
  (tset neorg-modules :core.export {})
  (tset neorg-modules :core.export.markdown {:config {:extensions :all}}))

;; fnlfmt: skip
(fn __neorgSetup []
  " Neorg Setup Autocmd!::"
  (let [fidget (require :fidget)
        nio (require :nio)
        progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :neorg}})]
    (progress:report {:message "PackStrapping <Neorg-Deps>"
                      :level vim.log.levels.ERROR
                      :progress 0})
    (packadd! lua-utils)
    (packadd! neorg)
    (packadd! image-nvim)
    (packadd! pathlib)
    (packadd! neorg-exec)
    (packadd! neorg-telescope)
    (packadd! neorg-roam)
    (packadd! neorg-timelog)
    (packadd! neorg-hop-extras)
    (progress:report {:message "Initializing Image-nvim"
                          :level vim.log.levels.ERROR
                          :progress 10})
    ((->> :setup (. (require :image))) {:backend :kitty
                                        :integrations {:markdown {:enabled true
                                                                  :download_remote_images true
                                                                  :filetypes [:markdown
                                                                              :quarto
                                                                              :vimwiki]}
                                                       :neorg {:enabled true
                                                               :download_remote_images true
                                                               :clear_in_insert_mode false
                                                               :only_render_image_at_cursor false
                                                               :filetypes [:norg]}}})
    (progress:report {:message "Initializing Neorg"
                          :level vim.log.levels.ERROR
                          :progress 20})
    ((->> :setup (. (require :neorg))) {:load neorg-modules})
    (progress:report {:message "<Neorg> Setup Complete!"
                      :title :Completed!
                      :progress 99})
    ;(nio.sleep 5)
    (progress:finish)))

(vim.api.nvim_create_autocmd :BufReadPre
                             {:pattern :*.norg
                              :callback #(__neorgSetup)
                              :once true
                              :desc "Neorg Setup"})
