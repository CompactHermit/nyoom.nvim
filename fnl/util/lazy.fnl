;; fennel-ls: macro-file

;; fnlfmt: skip
(comment 
  the core implementation of <LazyHermit> Essentially packadd each plugin on the [:Event :Cmd :Keys]
  To Be Used in place of :use-package!)

(lambda __lazyCmd! [_strings ?opts]
  "
  LazyCmd:: <Cmd> -> <Table::opts> -> <LazyLoader::Once_Key!>
    @params _strings <Strings | <Strings>> Takes either a string or a list of strings
    @params opts [<<Setup::Setup-Opts>,<Opts>>] Options to use for nvim_api_create_command
  Returns a one-shot cmd which setup's the current plugin.
  E.g::
  ```fennel
    (C=>> [:Oil :Workspace :Neorg] {:setup (plugin.setup})
  ```
  "
  (assert-compile (or (sym? _strings) (sequence? _strings))
                  "expected symbol or table for _strings" _strings)
  (assert-compile (when (not= ?opts nil) (sym? ?opts))
                  "expected table for ?opts" ?opts))

(lambda __lazyEvent! [])

{:C=>> __lazyCmd! :E=>> __lazyEvent!}
