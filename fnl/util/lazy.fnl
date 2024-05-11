;; fennel-ls: macro-file

;; fnlfmt: skip
(comment /*norg*/
  the core implementation of <LazyHermit> Essentially packadd each plugin on the [:Event :Cmd :Keys]
  To Be Used in place of :use-package!)

(lambda __lazyCmd! [identifier ?options]
  "
  LazyCmd:: <> -> <Fn::Callback> -> <LazyLoader::Once_Key!>
    @params identifier :: What to use to packadd! or lazy-add the thing
    @params opts [<<Setup::Setup-Opts>,<Opts>>] Options to use for nvim_api_create_command
  Returns a one-shot cmd which setup's the current plugin.
  E.g::
  ```fennel
    (C=>> {:cmds [:Oil :Workspace :Neorg]
          :event [:BufReadPre]
          :filetype \"*norg\"}
          :module :mod-name
          :opts {:vals :to.pass.to.setup.function}
          :define (fn []
                   (what.to.run.pre.setup!))
  ```
  ")

{:C=>> __lazyCmd!}
