{ inputs, ... }:
{

  flake.templates =
    let
      inherit (inputs.nixpkgs) lib;
    in
    (lib.attrsets.genAttrs
      (lib.attrNames (lib.filterAttrs (_: v: v != "regular") (builtins.readDir ./.)))
      (name: {
        path = ./${name};
        description = "${name}-Template";
        welcomeText = ''
          Welcome ya bloated fuck, ur building a devshell for ${name}, enjoy it .
        '';
      })
    );
}
