(comment "
         AutoGenerate's parser table using nvim-treesitter's internal table of TS Parsers.
         We add on extra parsers not part of the List, as well as extend them.
         ")

;;TODO:: (Hermit) Just use pathlib and a metatable. Pretty sure pathlib exposes a handler for nio to read.

; [treesitter-grammar-norg]
; src.git = "https://github.com/boltlessengineer/tree-sitter-norg3-pr1/"
; fetch.git = "https://github.com/boltlessengineer/tree-sitter-norg3-pr1/"
; src.branch = "null_detached_modifier"

;; WE Lazyload TS, so we hack it this way
; (local {: trigger_load} (autoload :lz.n))
; (trigger_load :nvim-treesitter)

;; fnlfmt: skip
(let [nio (autoload :nio)
      on_exit (nio.wrap #(vim.cmd :qa) 0)]
  (nio.run (fn []
             (nio.scheduler)
             (nio.wrap #(vim.cmd "packadd :nvim-treesitter") 0)
             (nio.scheduler)
             ;; Oddly enough, this fails to find the file handle? Maybe if the same file handle is consumed and improperly closes, uv fails to GC?
             (let [file (nio.file.open (.. (vim.fn.expand "%:p:h")
                                           ;"/home/CompactHermit/.config/nvim/deps/parsers/"
                                           :/deps/parsers/nvfetcher.toml)
                                       :w)
                   ;;TS specificx
                   nvim-ts-tbl ["#THIS FILE IS AUTOGEN USING `autogen-parsers.fnl`:: DONNOT MODIFY THIS"
                                "[nvim-treesitter]"
                                "fetch.git = \"https://github.com/nvim-treesitter/nvim-treesitter\""
                                "src.git = \"https://github.com/nvim-treesitter/nvim-treesitter\" \n"]
                                ; "src.branch = \"update-lockfile-pr\"\n"]
                   parsers (. (require :nvim-treesitter.parsers) :list)
                   keys []
                   needsNPM {:tsx true :typescript true :qmljs true}]
               (doto parsers
                 (tset :vhs
                       {:install_info {:url "https://github.com/charmbracelet/tree-sitter-vhs"
                                       :files [:src/parsers.c]
                                       :branch :alt}})
                 (tset :spade
                       {:install_info {:url "https://gitlab.com/spade-lang/tree-sitter-spade"
                                       :files [:src/parsers.c]}})
                 (tset :nu
                       {:install_info {:url "https://github.com/nushell/tree-sitter-nu"
                                       :files [:src/parsers.c :src/scanner.c]}})
                 (tset :blade
                       {:install_info {:url "https://github.com/EmranMR/tree-sitter-blade"
                                       :files [:src/parsers.c]}})
                 (tset :cabal
                       {:install_info {:url "https://github.com/sisypheus-dev/tree-sitter-cabal"
                                       :files [:src/parsers.c]}})
                 (tset :norg-meta
                       {:install_info {:url "https://github.com/nvim-neorg/tree-sitter-norg-meta"
                                       :files [:src/parsers.c]}}))
               (nio.scheduler)
               ;; TODO:: Just VIM.iter over this, and flatten
               (each [v _ (pairs parsers)]
                 (table.insert keys v))
               (table.sort keys)
               (file.write (table.concat nvim-ts-tbl "\n"))
               (: (vim.iter keys) :each
                  #(let [info (. parsers $1 :install_info)]
                     (file.write (.. "[treesitter-grammar-" $1 "]" "\n"))
                     (file.write (.. "fetch.git = \"" info.url "\"" "\n"))
                     (file.write (.. "src.git = \"" info.url "\"" "\n"))
                     (if (not= (. needsNPM $1) nil)
                         (file.write (.. "extract = [\"package.json\", \"package-lock.json\"]"
                                         "\n")))
                     ; In Case we ha$1e seperate branches
                     (if info.branch
                         (file.write (.. "src.branch = \"" info.branch "\""
                                         "\n")))
                     ;; Adding Passthrough for Locations/Generate from grammar, needed for nix;
                     (when (or info.location
                               info.requires_generate_from_grammar)
                       (file.write (.. "[treesitter-grammar-" $1 ".passthru]\n"))
                       ;; TODO:: Unshittify this logic
                       (if info.requires_generate_from_grammar
                           (file.write (.. "generate = \"true\"\n")))
                       (if info.location
                           (file.write (.. "location = \"" info.location "\""
                                           "\n"))))
                     (file.write "\n")))
               (file.close))
             (nio.scheduler)
             (on_exit))))
