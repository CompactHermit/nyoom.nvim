(import-macros {: nyoom-module-p!} :macros)
;; TODO:: Rewrite with -> Macro
(local ht_attach (. (require :haskell-tools) :start_or_attach))
(local ht (require :haskell-tools))
(local cmp-lsp (require :cmp_nvim_lsp))


;; Custom Formatter for haskell
(fn on_attach [client bufnr]
  (local dap (require :dap))
  (set dap.adapters.haskell
       {:type :executable
        :command :haskell-debug-adapter
        :args [:--hackage-version=0.0.33.0]})
  (set dap.configurations.haskell
       [{:type :haskell
         :request :launch
         :name :Debug
         :workspace "${workspaceFolder}"
         :startup "${file}"
         :stopOnEntry true
         :logFile (.. (vim.fn.stdpath :data) :/haskell-dap.log)
         :logLevel :WARNING
         :ghciEnv (vim.empty_dict)
         :ghciPrompt "λ: "
         :ghciInitialPrompt "λ: "
         :ghciCmd "stack ghci --test --no-load --no-build --main-is TARGET --ghci-options -fprint-evld-with-show"}])
  (ht.dap.discover_configurations bufnr))


;; TODO:: Add to utils/lsp.fnl folder
(local capabilities (-> (vim.lsp.protocol.make_client_capabilities)
                        cmp-lsp.default_capabilities))

(tset capabilities :textDocument :foldingRange
      {:dynamicRegistration false :linefoldingOnly true})


(nyoom-module-p! haskell
                 (do
                   (ht.start_or_attach {:hls {: capabilities
                                              :settings {:haskell {:formattingProvider :fourmolu
                                                                   :plugin {:rename {:config {:diff true}}}}}
                                              :cmd [:haskell-language-server :--lsp]
                                              : on_attach}
                                        :tools {:repl {:handler :toggleterm :auto_focus true}
                                                :dap {:cmd [:haskell-debug-adapter]}}})))


