(import-macros {: nyoom-module-p!} :macros)
(local lsp (autoload :lspconfig))
(local lsp-servers {})

;; TODO:: add more doc specs

;;; Improve UI

(set vim.lsp.handlers.textDocument/signatureHelp
     (vim.lsp.with vim.lsp.handlers.signature_help {:border :solid}))

(set vim.lsp.handlers.textDocument/hover
     (vim.lsp.with vim.lsp.handlers.hover {:border :solid}))


(fn format! [bufnr ?async?]
  (vim.lsp.buf.format {: bufnr
                       :filter #(not (contains? [:jsonls :tsserver] $.name))
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
    (when (client.supports_method "textDocument/formatting")
      (augroup! format-before-saving
        (clear! {:buffer bufnr})
        (autocmd! BufWritePre <buffer> #(format! bufnr) {:buffer bufnr})))))

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

(nyoom-module-p! cc (tset lsp-servers :clangd {:cmd [:clangd]}))

(nyoom-module-p! csharp (tset lsp-servers :omnisharp {:cmd [:omnisharp]}))

(nyoom-module-p! clojure (tset lsp-servers :clojure_lsp {}))

(nyoom-module-p! java (tset lsp-servers :jdtls {}))

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

(nyoom-module-p! typescript (tset lsp-servers :biome {:settings {:filetypes [:javascript :typescript :javascriptreact :typescript.tsx :typescriptreact :json]}}))

(nyoom-module-p! kotlin (tset lsp-servers :kotlin_langage_server {}))

(nyoom-module-p! latex (tset lsp-servers :texlab {}))

(nyoom-module-p! lua
                 (tset lsp-servers :lua_ls
                       {:settings {:Lua {:diagnostics {:globals [:vim]}
                                         :workspace {:library (vim.api.nvim_list_runtime_paths)
                                                     :maxPreload 100000}}}}))

(nyoom-module-p! markdown (tset lsp-servers :marksman {}))

;; TODO:: add custom lsp defs, such as a cursom callback feature for on-save
;; require'lspconfig'.svelte.setup {
;;                                 on_attach = function(client)
;;                                 vim.api.nvim_create_autocmd("BufWritePost", {
;;                                                             pattern = { "*.js", "*.ts" },
;;                                                             callback = function(ctx)
;;                                                             client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file})
;;                                                             end,})
;;                                 end}

(nyoom-module-p! svelte (tset lsp-servers :svelte {:config
                                                    {:filetypes [:svelte :typescript :javascript :css :html]}}))

(nyoom-module-p! nim (tset lsp-servers :nimls {}))

;; I'm fucking in love
(nyoom-module-p! nix (tset lsp-servers :nil_ls
                           {:settings {:nix {:flake
                                             {:autoArchive true}}}}))
(nyoom-module-p! nickel (tset lsp-servers :nickel_ls
                              {:settings {:filetypes [:ncl :nickel]
                                          :root_dir [:flake.nix :.git]}}))

(nyoom-module-p! python
                 (tset lsp-servers :pyright
                       {:root_dir (lsp.util.root_pattern [:.flake8])
                        :settings {:python {:analysis {:autoImportCompletions true
                                                       :useLibraryCodeForTypes true
                                                       :disableOrganizeImports false}}}}))

(nyoom-module-p! typst
                 (tset lsp-servers :typst_lsp {}))
(nyoom-module-p! yaml
                 (tset lsp-servers :yamlls
                       {:settings {:yaml {
                                          :schemaStore {:enable false
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

{: on-attach}
