(import-macros {: nyoom!} :macros)

;; fnlfmt: skip
(nyoom! :completion
        cmp                  ; the ultimate code completion backend
        ;;copilot              ; the code completion of the future
        ;;fzf-lua            ; TODO a search engine for love and life
        (telescope) ;;+native)  ; the search engine of the future

        :ui
        (nyoom +modes +icons); what makes Nyoom look the way it does
        dashboard            ; a nifty splash screen for neovim
        ;nyoom-quit         ; WIP: buggy, terrible implementation of doom-quit.
        hydra                ; Discount modality for mythological beast hunters
        indent-guides        ; highlighted indent columns
        modeline             ; snazzy, nano-emacs-inspired modeline
        nvimtree             ; a project drawer, like NERDTree for vim
        neotree              ; tree-like structures for neovim
        tabs                 ; keep tabs on your buffers, literally
        vc-gutter            ; Get your diff out of the gutter
        window-select        ; Visually switch windows
        zen                  ; distraction-free coding or writing TODO +twilight
        noice                ; noice ui
        animate              ; Just use Emacs you bloated fu**

        :editor
        fold                 ; (nigh) universal code folding
        (format +onsave)     ; automated prettiness
        debug             ; stepping through code, to help you add bugs
        multiple-cursors   ;  learn macros you dingus
        ;;parinfer           ; turn lisp into python, sort of
        (hotpot +reflect)    ;NOTE: essential module (for now), don't disable
        scratch              ;emacs-like scratch buffer functionality
        mini                 ;Nice, micro features with 10K LOC you got there
        ;firenvim
        resession            ; Sessionize neovim, bcs you're not schizo enough
        word-wrap            ; language-aware smart soft and hard wrapping
        windows              ; Fancy animations, for that extra bloated Config
        swap                 ; And you're not using macros why?
        (cutlass);+plunder   ; Make yourself better at stealing code from others

        :term
        fshell             ; WIP: the fennel shell that works everywhere *Test Faith.fnl*
        toggleterm           ; persistant/floating terminal wrapper for :term

        :checkers
        diagnostics          ; tasing you for every semicolon you forget
        grammar              ; tasing grammar mistake every you make
        ; spell              ; tasing you for misspelling mispelling

        :tools
        ;docker               ; row row row your boat TODO +netman?
        ; editorconfig       ; let someone else argue about tabs vs spaces
        ; magma              ; tame Jupyter notebooks
        quickfix             ; Monkey Simulator, circa 23 colorized
        overseer             ; Run jobs, for when your too lazy to do your job
        ;mason               ; Nixified Mason Integration. DevShell hotfixing included
        ;quarto               ; Need some diagnostic, ask an otter.
        (browse              ; Im too lazy to open a browser
          +tmp_clone)
        octo                 ; All hail the octussy
        tmux                 ; God, make this shit broken, I fucking swear
        ;hex                  ; Hex Done Right
        zellij               ; What if everything was written in WASM, jk, useless...
        harpoon              ; With the power of the gods!
        oil                  ; Vinegar Was never a good salid dressing
        eval                 ; run code, run (also, repls)modu
        antifennel           ; for all the fennel haters out there. this ones for you
        pastebin             ; interacting with pastebin platforms
        lsp                  ; :vscode
        neotest              ; This won't help you pass your Homotopy Exams
        (neogit              ; a git porclain for neovim
          +diffview)         ; a git diff view for neovim
        ;;galore               ; A notMuch client for neovim
        rgb                  ; creating color strings
        tree-sitter          ; syntax and parsing, sitting in a tree...

        :lang
        cc                   ; C > C++ == 1
        clojure              ; java with a lisp
        ;common-lisp          ; if you've seen one lisp, you've seen them all
        ;; csharp             ; java but with linq
        ;flutter              ; Flap
        ;java                 ; the poster child for carpal tunnel syndrome
        ;julia                ; a better, faster MATLAB
        ;kotlin             ; a better, slicker Java(Script)
        ;; json               ; { "dʒeɪsən":  "Javascript Object Notation" }
        ;latex                ; writing papers in Neovim has never been so fun
        lua                 ; one-based indices? one-based indices
        ;markdown             ; writing docs for people to ignore
        ;; nim                ; python + lisp at the speed of c
        (neorg               ; organize your plain life in plain text, the neovim way
          +pretty
          +present
          +export
          +quicknote
          +nabla
          +roam)              ; Currently bugged
        ; (org +pretty)        ; WIP: organize your plain life in plain text, the emacs way
        nix                  ; I hereby declare "nix geht mehr!"
        ;nickel               ; Dhall, but nixified
        ;; ocaml                ; Nested Let Blocks? Nested Let blocks!!
        ;python               ; beautiful is better than ugly
        ;rust                 ; Fe2O3.unwrap().unwrap().unwrap().unwrap()
        ;typescript           ; Javas Ugly, bloated, linter-tool
        ;typst                ; If latex had one compiler, and less sty bloat
        ;;svelte               ; Cybernetically enchanced JS, now eating your memory at 10x speed
        ;; scala              ; Functional Java, done right
        ;(sh +nu) ;+fish)     ; she sells {ba,z,fi}sh shells on the C xor
        ;;;xml                ; extend my language
        ;;;yaml               ; yet another markup language to enable
        ;go                  ; No Bitches??
        ;lean                 ; Make your category-theory coursework 1000x harder.
        ;;agda                ; TODO:: add cornelis nix bindings
        haskell              ; Functionally Braindead parsers
        zig                  ; C, but slower and fatter

        :app
        ;;himalaya           ; Enable Himalaya Integration
        ;;calendar           ; Watch your missed deadlines in real time
        ;;runner             ; Whether to enable the nyoom wrapper for nix

        :config
        ;;literate           ; FIXME: Disguise your config as poor documentation
        (default             ; Reasonable defaults for reasonable people
          +bindings
          +which-key
          +smartparens
          +flash))
