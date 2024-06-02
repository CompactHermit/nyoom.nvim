(import-macros {: nyoom-module-p! : autocmd! : augroup! : packadd!} :macros)
(local lsp (autoload :lspconfig))
(local lspUtil (autoload :util.lsp))
(local lsp-servers {})
;;; Improve UI

(set vim.lsp.util.stylize_markdown
     (fn [bufnr contents opts]
       (set-forcibly! contents
                      (vim.lsp.util._normalize_markdown contents
                                                        {:width (vim.lsp.util._make_floating_popup_size contents
                                                                                                        opts)}))
       (tset (. vim.bo bufnr) :filetype :markdown)
       (vim.treesitter.start bufnr)
       (vim.api.nvim_buf_set_lines bufnr 0 (- 1) false contents)
       contents))

(set vim.lsp.handlers.textDocument/signatureHelp
     (vim.lsp.with vim.lsp.handlers.signature_help {:border :solid}))

;; NOTE: GodBless Ben, saviour of empty refs
(tset vim.lsp.handlers :textDocument/definition
      (fn [_ result ctx]
        (when (or (not result) (vim.tbl_isempty result))
          (vim.notify "[lsp]: Could not find definition" vim.log.levels.INFO)
          (lua "return "))
        (local client (vim.lsp.get_client_by_id ctx.client_id))
        (if (vim.islist result)
            (let [results (vim.lsp.util.locations_to_items result
                                                           client.offset_encoding)
                  (lnum filename) (values (. (. results 1) :lnum)
                                          (. (. results 1) :filename))]
              (each [_ val (pairs results)]
                (when (or (not= val.lnum lnum) (not= val.filename filename))
                  ((. (require :telescope.builtin) :lsp_definitions))))
              (vim.lsp.util.jump_to_location (. result 1)
                                             client.offset_encoding false))
            (vim.lsp.util.jump_to_location result client.offset_encoding false))))

(tset vim.lsp.handlers :textDocument/hover
      (vim.lsp.with vim.lsp.handlers.hover {:border :solid}))

(fn format! [bufnr ?async?]
  (vim.lsp.buf.format {: bufnr
                       :filter #(not (vim.tbl_contains [:jsonls :tsserver]
                                                       $.name))
                       :async ?async?}))

(fn on-attach [client bufnr]
  (import-macros {: buf-map! : autocmd! : augroup! : clear!} :macros)
  (local {: contains?} (autoload :core.lib))
  ;; Keybindings
  (nyoom-module-p! defaults.+bindings
                   (do
                     (local {:hover open-doc-float!
                             :declaration goto-declaration!
                             :definition goto-definition!
                             :type_definition goto-type-definition!
                             :references goto-references!}
                            vim.lsp.buf)
                     (buf-map! [n] :K open-doc-float!)
                     (buf-map! [n] :<leader>gD go)
                     (buf-map! [n] :gD goto-declaration!)
                     (buf-map! [n] :<leader>gd goto-definition!)
                     (buf-map! [n] :gd goto-definition!)
                     (buf-map! [n] :<leader>gt goto-type-definition!)
                     (buf-map! [n] :gt goto-type-definition!)
                     (buf-map! [n] :<leader>gr goto-references!)
                     (buf-map! [n] :gr goto-references!)))
  ;; Enable lsp formatting if available
  (nyoom-module-p! format.+onsave
                   (when (client.supports_method :textDocument/formatting)
                     (augroup! format-before-saving (clear! {:buffer bufnr})
                               (autocmd! BufWritePre <buffer>
                                         #(format! bufnr true) {:buffer bufnr})))))

;; LSP Documents Types::

(local capabilities (vim.lsp.protocol.make_client_capabilities))
(set capabilities.textDocument.completion.completionItem
     {:documentationFormat [:markdown :plaintext]
      :snippetSupport true
      :preselectSupport true
      :insertReplaceSupport true
      :labelDetailsSupport true
      :deprecatedSupport true
      :commitCharactersSupport true
      :tagSupport {:valueSet {1 1}}
      :resolveSupport {:properties [:documentation
                                    :detail
                                    :additionalTextEdits]}})

;;; Setup servers::

(local defaults {:on_attach on-attach
                 : capabilities
                 :flags {:debounce_text_changes 150}})

;; conditional servers::

(nyoom-module-p! cc
                 (do
                   (local clangd_commands
                          [(or vim.env.CLANGD_PATH :clangd)
                           :--background-index
                           :--clang-tidy
                           :--completion-style=detailed
                           :--header-insertion=never
                           :--header-insertion-decorators
                           :--all-scopes-completion
                           :--enable-config
                           :--pch-storage=disk
                           :--log=info])
                   (match vim.env.GCC_PATH
                     (where __val (not= __val nil)) (table.insert clangd_commands
                                                                  (: "--query-driver=%s"
                                                                     :format
                                                                     __val))
                     _ nil)
                   (tset lsp-servers :clangd {:cmd clangd_commands})))

(nyoom-module-p! clojure (tset lsp-servers :clojure_lsp {}))

(nyoom-module-p! java (do
                        (tset lsp-servers :kotlin_language_server {})
                        (tset lsp-servers :jdtls {})))

(nyoom-module-p! sh (tset lsp-servers :bashls {}))

(nyoom-module-p! julia (tset lsp-servers :julials {}))

(nyoom-module-p! json
                 (tset lsp-servers :jsonls
                       {:format {:enabled false}
                        :schemas [{:description "ESLint config"
                                   :fileMatch [:.eslintrc.json :.eslintrc]
                                   :url "http://json.schemastore.org/eslintrc"}
                                  {:description "Package config"
                                   :fileMatch [:package.json]
                                   :url "https://json.schemastore.org/package"}
                                  {:description "Packer config"
                                   :fileMatch [:packer.json]
                                   :url "https://json.schemastore.org/packer"}]}))

; (nyoom-module-p! typescript (tset lsp-servers :biome {:settings {:filetypes [:javascript :typescript :javascriptreact :typescript.tsx :typescriptreact :json]}}))

(nyoom-module-p! latex (tset lsp-servers :texlab {}))

; (tset lsp-servers :fennel_ls {:root_dir #(. (vim.fs.find [:fnl :.git]
;                                                          {:upward true
;                                                           :type :directory
;                                                           :path $})
;                                             1)
;                               :settings {:fennel-ls {:extra-globals :vim}}
;                               :macro-path :fnl/**/*macros.fnl
;                               :checks {}})

(nyoom-module-p! lua
                 (do
                   (packadd! lazydev)
                   (packadd! luvit)
                   ;; HACK: Temp fix for packir, when we finalize a better RTP-setup we'll just search from there
                   (let [tbl (: (vim.iter {:start [:nvim-nio
                                                   :nui
                                                   :rustaceanvim]
                                           :opt [:neorg
                                                 :image-nvim
                                                 :luvit-meta
                                                 :dap
                                                 :rustaceanvim]})
                                :fold []
                                (fn [acc k v]
                                  (each [_ plug (ipairs v)]
                                    (let [path (string.format "%s/pack/myNeovimPackages/%s/%s"
                                                              vim.g.PACKDIR k
                                                              plug)]
                                      (match plug
                                        (where _nioP (= _nioP :nui)) (table.insert acc
                                                                                   {: path
                                                                                    :words [:nui]})
                                        (where _nioP (= _nioP :nvim-nio)) (table.insert acc
                                                                                        {: path
                                                                                         :words [:nio]})
                                        (where _luvitP (= _luvitP :luvit-meta)) (table.insert acc
                                                                                              {: path
                                                                                               :words ["vim%.uv"]})
                                        _ (table.insert acc path))))
                                  acc))]
                     ((->> :setup (. (require :lazydev))) {:library tbl
                                                           :enabled true})
                     ; (fn [root] ;   "Dont Load When ./luarcs.json is present. Typically if we've already set it with a nix-shell"
                     ;   (not (= (vim.uv.fs_stat (.. root "/.luarc.json")) nil))))
                     (tset lsp-servers :lua_ls
                           {:settings {:Lua {:IntelliSense {:traceLocalSet true}
                                             :codeLens {:enable true}
                                             :hint {:enable true}
                                             :format {:enable false}
                                             :diagnostics {:globals {:vim :P
                                                                     :describe :it
                                                                     :before_each :after_each
                                                                     :packer_plugins :pending}}
                                             :telemetry {:enable false}
                                             :completion {:callSnippet :Replace}
                                             :workspace {:library (vim.api.nvim_list_runtime_paths)
                                                         :maxPreload 1000
                                                         :ignoreDir [:.direnv]}}}}))))

;; Stop Lua-ls from shitting itself

;(nyoom-module-p! markdown (tset lsp-servers :marksman {}))

(nyoom-module-p! svelte
                 (tset lsp-servers :svelte
                       {:config {:filetypes [:svelte
                                             :typescript
                                             :javascript
                                             :css
                                             :html]}}))

(nyoom-module-p! nim (tset lsp-servers :nimls {}))

;; I'm fucking in love
(nyoom-module-p! nix
                 (tset lsp-servers :nil_ls
                       {:settings {:nix {:flake {:autoArchive true}}}}))

(nyoom-module-p! nickel
                 (tset lsp-servers :nickel_ls
                       {:settings {:filetypes [:ncl :nickel]
                                   :root_dir [:flake.nix :.git]}}))

(nyoom-module-p! python (doto lsp-servers
                          (tset :ruff_lsp {:single_file_support true})
                          (tset :basedpyright {})))

(nyoom-module-p! typst
                 (tset lsp-servers :tinymist
                       {:single_file_support true
                        :settings {:exportPdf :onType
                                   :outputPath :$root/target/$dir/name
                                   :fontPaths (or vim.env.TYPST_FONTS nil)}}))

(nyoom-module-p! yaml
                 (tset lsp-servers :yamlls
                       {:settings {:yaml {:schemaStore {:enable false
                                                        :url "https://www.schemastore.org/api/json/catalog.json"}
                                          :schemas {:/path/to/your/custom/strict/schema.json "yet-another.{yml,yaml}"
                                                    "http://json.schemastore.org/prettierrc" ".prettierrc.{yml,yaml}"}
                                          :validate true}}}))

(nyoom-module-p! zig (tset lsp-servers :zls {}))

;; Load lsp
(local {: deep-merge} (autoload :core.lib))
(let [servers lsp-servers]
  (each [server server_config (pairs servers)]
    ((. (. lsp server) :setup) (deep-merge defaults server_config))))

;; Autocmds FOR Inlay hints
(augroup! UserLspConfig
          (autocmd! LspAttach "*"
                    (fn [args]
                      (packadd! :lspsaga)
                      ((->> :setup (. (require :lspsaga))) {:lightbulb {:enable false}})
                      (local client
                             (vim.lsp.get_client_by_id args.data.client_id))
                      (when client.server_capabilities.inlayHintProvider
                        (vim.lsp.inlay_hint.enable)))))

{: on-attach}
