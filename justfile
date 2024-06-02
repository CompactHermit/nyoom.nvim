#List Defaults::
default:
    @just --list


clean:
   rm -rf /tmp/nyoom
   NYOOM_CLI=true nvim --headless -c "qa!"


profile-update:
    nix profile upgrade nvim --verbose --show-trace -Lv

update:
   nix flake update -Lvv --show-trace


startuptime:
   hyperfine --warmup 3 "nvim -c qa!"


configeval:
    hyperfine --warmup 10 "nix eval .#Dhaos.outPath --no-eval-cache"


test:
    busted

#CleanUp Dir
alias c := clean

# Update flake-inputs, will be npins later
alias u := update

# Eval Speed Check
alias e := configeval

#Run startup Tests
alias s := startuptime

#Run Macro Tests
alias b := test

#update bin
alias n := profile-update
