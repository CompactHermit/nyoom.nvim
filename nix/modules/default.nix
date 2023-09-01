{
  inputs,
  outputs,
  ...
}: {
  # This feels monkey patched, perhaps add a module checker? Perhaps when alpacka gets, e.g:: query a packerlockfile
  nyoom = import ./nyoom {inherit inputs outputs;};
}
