(import-macros {: lazyp} :macros)

(comment "
         dag-Specs::
         Since each plugin has colinear deps (as in, each dep is simply packadded, and are the same irrespective of /when/ they are loaded), we can abuse fennel macros to create a `minimal` load-tree. This is resolved via this dag.
         ")
