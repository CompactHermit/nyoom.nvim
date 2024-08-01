(import-macros {: map! : let!} :macros)

;; TODO:: (Hermit) Async Termsend, using nio
(fn __generate-repl []
  "
    __generate-repl:: [] -> ToggleTerm::Shell
    Returns a repl for nix, loading the cwd's flake
  "
  (let [tterm (autoload :toggleterm)
        {: Terminal} (require :toggleterm.terminal)
        __nixTerminalHandler (Terminal:new {:cmd (string.format "nix repl --debug --show-trace -Lv --expr '__getFlake \"%s\"' -I nixpkgs=flake:nixpkgs"
                                                                (vim.uv.cwd))
                                            :dir (vim.uv.cwd)
                                            :close_on_exit false
                                            :auto_scroll true})]
    (: __nixTerminalHandler :toggle)
    (: __nixTerminalHandler :send
       "pkgs = debug.flake.allSystems.x86_64-linux.allModuleArgs.pkgs")
    (: __nixTerminalHandler :send "lib = pkgs.lib")))

;(nio.scheduler)

; (tterm.exec "")))

; (let! direnv_auto 1)
; (let! direnv_silent_load 0)
((->> :setup (. (autoload :direnv))) {:autoload_direnv false
                                      :keybindings {:allow :<M-d>a
                                                    :deny :<M-d>d
                                                    :reload :<M-d>r}})

(map! [n] :<space>cr `(__generate-repl) {:desc "<Nix>::[R]epl"})
