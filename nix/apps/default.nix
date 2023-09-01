{lib, ...}: {
  perSystem = {config, ...}: {
    apps = {
      nix.program = lib.getExe config.packages.nix;
      default = config.apps.nix;
    };
  };
}
