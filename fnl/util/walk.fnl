(fn rwalk [dir tbl]
 " Recursvily walks through a path and returns all files
 "
 (coroutine.wrap
  (fn []
     (let [handle (vim.uv.fs_scandir dir)]
      (var (n t)  nil)
      (var path nil)
      (while handle
       (set (n t) (vim.uv.fs_scandir_next handle))
       (set path (vim.fs.joinpath dir n))
       (if (and (~= t :file) (~= nil n))
        ;(print (string.format "%s := %s := %s" n t path))
        (table.insert tbl path))
       (set t (or t (. (vim.uv.fs_stat path) :type)))
       (if (= n nil) (lua "return nil")
        (= t :directory)
        (each [cpath c ctype (rwalk path)]
         (coroutine.resume cpath c ctype))))
      (coroutine.yield path n t)))))
(lambda seek! [dir ?type ?nix]
 " seek:: dir -> Maybe(path) -> Maybe(nix) -> IO::Source<Path>
 Recursively sources the either the <plugins/after> files in a module.
 ")
{: seek! : rwalk}
