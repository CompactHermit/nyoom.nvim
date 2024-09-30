(import-macros {: packadd!
                : set!
                : map!
                : nyoom-module-ensure!
                : autocmd!
                : augroup!} :macros)

; (local {: openAllFolds : closeAllFolds} (autoload :ufo))

(local _opts {:provider_selector (fn provider_selector [_bufnr
                                                        _filetype
                                                        _buftype]
                                   [:treesitter])
              :fold_virt_text_handler (fn [virt-text
                                           lnum
                                           end-lnum
                                           width
                                           truncate]
                                        (local new-virt-text {})
                                        (var suffix
                                             ;;.........................................  %
                                             (: "  %d " :format
                                                (- end-lnum lnum)))
                                        (local suf-width
                                               (vim.fn.strdisplaywidth suffix))
                                        (local target-width (- width suf-width))
                                        (var cur-width 0)
                                        (each [_ chunk (ipairs virt-text)]
                                          (var chunk-text (. chunk 1))
                                          (var chunk-width
                                               (vim.fn.strdisplaywidth chunk-text))
                                          (if (> target-width
                                                 (+ cur-width chunk-width))
                                              (table.insert new-virt-text chunk)
                                              (do
                                                (set chunk-text
                                                     (truncate chunk-text
                                                               (- target-width
                                                                  cur-width)))
                                                (local hl-group (. chunk 2))
                                                (table.insert new-virt-text
                                                              [chunk-text
                                                               hl-group])
                                                (set chunk-width
                                                     (vim.fn.strdisplaywidth chunk-text))
                                                (when (< (+ cur-width
                                                            chunk-width)
                                                         target-width)
                                                  (set suffix
                                                       (.. suffix
                                                           (: " " :rep
                                                              (- (- target-width
                                                                    cur-width)
                                                                 chunk-width)))))
                                                (lua :break)))
                                          (set cur-width
                                               (+ cur-width chunk-width)))
                                        (table.insert new-virt-text
                                                      [suffix :MoreMsg])
                                        new-virt-text)})

;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds
;(vim.api.nvim_exec_autocmd)
(let [fidget (autoload :fidget)
      {: closeAllFolds : openAllFolds} (autoload :ufo)
      progress `,((. (autoload :fidget.progress) :handle :create) {:lsp_client {:name :fold}})]
  (progress:report {:message "Setting Up fold"
                    :level vim.log.levels.ERROR
                    :progress 0})
  ((->> :setup (. (autoload :ufo))) _opts)
  ;(map! [n] :zR `(openAllFolds) {:desc "Open all folds"})
  ;(map! [n] :zM `(closeAllFolds) {:desc "Close all folds"})
  (progress:report {:message "Setup Complete" :title :Completed! :progress 100})
  (progress:finish))

(set! foldcolumn :1)
(set! foldlevel 99)
(set! foldlevelstart 99)
(set! foldenable true)

; (do
;   (vim.api.nvim_create_augroup :ufo_disable_augroup {:clear true})
;   (autocmd! :BufEnter :*.norg `((->> :detach (. (autoload :ufo))))
;             {:group :ufo_disable_augroup}))
