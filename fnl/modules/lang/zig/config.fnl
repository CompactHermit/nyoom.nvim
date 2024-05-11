(import-macros {: packadd! : let!} :macros)
(local _opts {})

;; NOTE (Hermit) :: Remove after Adding Lazy! Macro and Proper buffer Autocmds
(fn __zigSetup []
  (packadd! zigTools)
  (let [fidget (autoload :fidget)
        progress `,((. (require :fidget.progress) :handle :create) {:lsp_client {:name :zig}})]
    (progress:report {:message "Setting Up zig"
                      :level vim.log.levels.ERROR
                      :progress 0})
    (let! zigtools_config
          {:expose_commands true
           :formatter {:enable false}
           :checker {:enable true :before_compilation true}
           :integrations {:package_managers {}
                          :zls {:hints true :management {:enable false}}}
           :project {:flags {:build :--prominent-compile-errors :run ""}
                     :build_tasks true}})
    ((->> :setup (. (require :zig-tools))))
    (progress:report {:message "Setup Complete"
                      :title :Completed!
                      :progress 99})))

(do
  (vim.api.nvim_create_autocmd :Filetype
                               {:pattern :zig
                                :callback #(__zigSetup)
                                :once true}))

; --- zig-tools.nvim configuration
; ---@type table
; _G.zigtools_config = {
;                       --- Commands to interact with your project compilation
;                       ---@type boolean
;                       expose_commands = true,
;                       --- Format source code
;                       ---@type table
;                       formatter = {
;                                    --- Enable formatting, create commands
;                                    ---@type boolean
;                                    enable = true,
;                                    --- Events to run formatter, empty to disable
;                                    ---@type table
;                                    events = {},}
;                       ,
;                       --- Check for compilation-time errors
;                       ---@type table
;                       checker = {
;                                  --- Enable checker, create commands
;                                  ---@type boolean
;                                  enable = true,
;                                  --- Run before trying to compile?
;                                  ---@type boolean
;                                  before_compilation = true,
;                                  --- Events to run checker
;                                  ---@type table
;                                  events = {},}
;                       ,
;                       --- Project compilation helpers
;                       ---@type table
;                       project = {
;                                  --- Extract all build tasks from `build.zig` and expose them
;                                  ---@type boolean
;                                  build_tasks = true,
;                                  --- Enable rebuild project on save? (`:ZigLive` command)
;                                  ---@type boolean
;                                  live_reload = true,
;                                  --- Extra flags to be passed to compiler
;                                  ---@type table
;                                  flags = {
;                                           --- `zig build` flags
;                                           ---@type table
;                                           build = {"--prominent-compile-errors"},
;                                           --- `zig run` flags
;                                           ---@type table
;                                           run = {},}
;                                  ,
;                                  --- Automatically compile your project from within Neovim
;                                  auto_compile = {
;                                                  --- Enable automatic compilation
;                                                  ---@type boolean
;                                                  enable = false,
;                                                  --- Automatically run project after compiling it
;                                                  ---@type boolean
;                                                  run = true,}
;                                  ,}
;                       ,
;                       --- zig-tools.nvim integrations
;                       ---@type table
;                       integrations = {
;                                       --- Third-party Zig packages manager integration
;                                       ---@type table
;                                       package_managers = {"zigmod", "gyro"},
;                                       --- Zig Language Server
;                                       ---@type table
;                                       zls = {
;                                              --- Enable inlay hints
;                                              ---@type boolean
;                                       ,}
;   
;
;                       ---@type table
;                       terminal = {
;                                   direction = "vertical",
;                                   auto_scroll = true,
;                                   close_on_exit = false,}
;                       ,}
;
