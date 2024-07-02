(comment "FFI-Spec::
         Testing FFI for certain luajit Packages, especially rust-specific one with unstable ABI's --Im Looking at you mlua
         ")

(let [ffi (require :ffi)]
  (print :hello))
