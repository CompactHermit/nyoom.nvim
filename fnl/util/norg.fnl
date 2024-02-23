(import-macros {: autocmd! : augroup! : local-command!} :macros)

(local {: execute_queries : get_ts_utils}
       ((. (autoload :neorg.core) :get_module) :core.integrations.treesitter))

(local node ((. (get_ts_utils) :get_node_at_cursor) :win? true))

(local query
       (get_ts_utils.ts_parse_query :norg
                                    "(ranged_verbatim_tag name:
                                           (tag_name) @_name (#any-of? @_name \"code\" \"embed\")) @tag"))

(fn get_codeblock []
  "
  get_codeblock:: _ -> Bool
      A brutish way to get norg-codeblocks. Essentially just uses a long query on the
  "
  (let [node (vim.treesitter.node)]))

(augroup! OtterActivate
          (autocmd! :FileType [:*.md "*." :*.org]
                    (fn [info]
                      (vim.schedule (fn []
                                      "
                                      OtterScheduleCallBack::_-> (otterAttach)
                                          A callback which runs the languages from a norg code-block,using otter 
                                          When the buffer is invalid or nonreadale, it uses the lua return hatch
                                      "
                                      (let [buf info.buf
                                            ot (autoload :otter)]
                                        (when (or (or (not (vim.api.nvim_buf_is_valid buf)))
                                                  (not (. vim.bo buf :ma)))
                                          (lua "return "))
                                        (ot.activate [:python :bash :lua] true
                                                     false)
                                        (doto buf
                                          (vim.api.nvim_buf_create_user_command :OtterRename
                                                                                (ot.ask_rename)
                                                                                {})
                                          (vim.api.nvim_buf_create_user_command :OtterHover
                                                                                (ot.ask_hover)
                                                                                {})
                                          (vim.api.nvim_buf_create_user_command :OtterReferences
                                                                                (ot.ask_references)
                                                                                {})
                                          (vim.api.nvim_buf_create_user_command :OtterTypeDefinition
                                                                                (ot.ask_definition)
                                                                                {})
                                          (vim.api.nvim_buf_create_user_command :OtterDocumentSymbols
                                                                                (ot.ask_document_symbols)
                                                                                {}))))))
                    {:desc "Otter For FT with TS injections"}))

;       vim.keymap.set('n', '<leader>r', action_fallback('rename'),          { buffer = buf})
;       vim.keymap.set('n', 'k',         action_fallback('hover'),           { buffer = buf})
;       vim.keymap.set('n', 'g/',        action_fallback('references'),      { buffer = buf})
;       vim.keymap.set('n', 'gd',        action_fallback('type_definition'), { buffer = buf})
;       vim.keymap.set('n', 'gd',        action_fallback('definition'),      { buffer = buf})
;       vim.keymap.set('n', 'gq);',       action_fallback('format'),         { buffer = buf })
