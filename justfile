#TODO: CLEAN THIS UP YOU CANIVING PRIMATE

#List Defaults::
default:
    @just --list

# Clean Caches + Sources
clean:
   @echo "Cleaning tmpdir"
   rm -rf /tmp/nyoom
   @echo "Cleaning TestDir"
   rm -rf ./lua/spec
   @echo "Cleaning Cargo.locks"
   rm -rf ./deps/plugins/_sources/neorg-se-*
   rm -rf ./deps/plugins/_sources/norg-fmt-*
   NYOOM_CLI=true nvim --headless -c "doautocmd VimEnter" +qa

# Build pkg + Update Bin
profile-update:
    nix profile upgrade nvim --verbose --show-trace -Lv

_1buildFennel:
    nvim --headless +"Fnlfile deps/parsers/autogen-parser.fnl"

_Fetcher:
    cd deps/parsers/ && nvfetcher -t -j 8 -l ./changelog.txt
    cd deps/plugins/ && nvfetcher -t -j 8 -l ./changelog.txt

_fup:
    nix flake update -Lv

# Update Deps
update: _1buildFennel _Fetcher _fup

# Startuptime Speedtest
startuptime:
   hyperfine --warmup 10 "nvim -c qa!"

#Check EvalTime
configeval:
    hyperfine --warmup 10 "nix eval .#faker.outPath --no-eval-cache"

#Rust Test Suite
test:
    nvim --headless "Fnlfile ./fnl/spec/init.fnl" +qa!
    nix flake check -Lvv

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
