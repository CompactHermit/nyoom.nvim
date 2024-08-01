 --[[ "Module Unit-testing
         Follows the same design philosophy as neorg's module unit-tests.
         Essentially, only unit test `#(trigger_load :module)` and `require :module...config`
         For more complex modules, like hydra/cmp/neorg, we just unit test + Perf.
         " ]] return nil