#TODO: CLEAN THIS UP YOU CANIVING PRIMATE

#List Defaults::
default:
    @just --choose

#Nice Litte JJ Hotkey
js:
    jj squash

# Clean Caches + Sources
clean:
   # @echo "Cleaning TestDir"
   @echo "Cleaning Cargo.locks"
   #TODO:: Add dep removal, or maybe nvfetcher has a util for that?
   rm -rf ./deps/plugins/_sources/neorg-se-*
   rm -rf ./deps/plugins/_sources/norg-fmt-*
   rm -rf ./deps/plugins/_sources/harper-ls-*
   rm -rf ./deps/plugins/_sources/tree-sitter-*
   rm -rf ./deps/parsers/_sources/treesitter-grammar-*
   @echo "Adding git"
   git add .

compile:
   @echo "Cleaning tmpdir"
   rm -rf /tmp/nyoom
   NYOOM_CLI=true nvim --headless -c "doautocmd VimEnter" +qa

# Build pkg + Update Bin
profile-update:
    nix profile upgrade nvim --verbose --show-trace -Lv

_1buildFennel:
    nvim --headless +"Fnlfile deps/parsers/autogen-parser.fnl"

_2zon2nix:
    zon2nix ./deps/plugins/_sources/zf-*/build.zig.zon > ./deps/plugins/_sources/zig_deps/zfDeps.zig

_Fetcher:
    cd deps/parsers/ && nvfetcher -t
    cd deps/plugins/ && nvfetcher -t

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

#Run Nyoom-Test Suite
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
