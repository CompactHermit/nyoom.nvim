(import-macros {: map! : packadd!} :macros)

(fn __generate-repl []
  "
    __generate-repl:: [] -> ToggleTerm::Shell
    Returns a repl for nix, loading the cwd's flake
  "
  (if (not= (pcall require :toggleterm) true) (vim.api.nvim_exec_autocmds :User {:pattern :toggleterm.setup}))
  (let [tterm (autoload :toggleterm)
        {: Terminal} (require :toggleterm.terminal)
        __nixTerminalHandler (Terminal:new {:cmd (string.format "nix repl --debug --show-trace -Lv --expr '__getFlake \"%s\"' -I nixpkgs=flake:nixpkgs"
                                                                (vim.uv.cwd))
                                            :dir (vim.uv.cwd)
                                            :close_on_exit false
                                            :auto_scroll true})]
    (: __nixTerminalHandler :toggle)
    (: __nixTerminalHandler :send
       "pkgs = debug.flake.allSystems.x86_64-linux.allModuleArgs.pkgs")))

; (tterm.exec "")))

(map! [n] :<space>cr `(__generate-repl) {:desc "<Nix>::[R]epl"})
