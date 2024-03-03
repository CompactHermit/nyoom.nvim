{ pkgs, ... }:
let inherit (pkgs.vimUtils) buildVimPlugin;
in {
  mkNeovimPlugin = src: pname: __extraOpts: __opt: {
    plugin = buildVimPlugin ({
      inherit pname src;
      version = src.lastModifiedDate;
    } // __extraOpts);
    optional = __opt;
  };
}
