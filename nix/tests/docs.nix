{ ... }: {
  perSystem = { pkgs, ... }: {
    checks.docgen = pkgs.writeShellApplication {
      name = "docgen";
      runtimeInputs = with pkgs; [ ];
      text = ''
        mkdir -p doc
      '';
    };
  };
}
