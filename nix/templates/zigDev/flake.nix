{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    pch = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zls = {
      #ZLS 0.12.0-dev.484+ac60c30
      url = "github:zigtools/zls/ac60c30661cb4c371106c330d4a851fbd61c4d9e";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zig = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mach = {
      url = "github:Cloudef/mach-flake/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ parts, ... }:
    parts.lib.mkFlake { inherit inputs; } {
      debug = true;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      imports = with inputs; [
        pch.flakeModule
        treefmt.flakeModule
        parts.flakeModules.easyOverlay
      ];
      perSystem =
        {
          pkgs,
          lib,
          config,
          system,
          ...
        }:
        let
          _machEnv = inputs.mach.mach-env.${system} { };
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            overlays = with inputs; [ zig.overlays.default ];
            system = system;
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt-rfc-style.enable = true;
              zig = {
                enable = true;
                package = builtins.head (builtins.attrValues { inherit (pkgs.zigpkgs) master-2024-03-08; });
              };
            };
          };

          pre-commit = {
            settings = {
              settings = {
                treefmt.package = config.treefmt.build.wrapper;
              };
              hooks = {
                treefmt.enable = true;
              };
            };
          };

          devShells.default = _machEnv.mkShell {
            name = "Zig::Vulkan";
            packages = builtins.attrValues {
              inherit (pkgs)
                vim
                gdb
                glfw
                pkg-config
                shaderc
                vulkan-headers
                vulkan-tools
                ;
              inherit (pkgs.zigpkgs) master-2024-03-08;
              ##inherit (inputs.zls.packages."${system}") default;
              zls = inputs.zls.packages."${system}".default.overrideAttrs (_: {
                nativeBuildInputs = [ pkgs.zigpkgs.master-2024-03-08 ];
              });
            };
            inputsFrom = with config; [
              treefmt.build.devShell
              pre-commit.devShell
            ];
            shellHook =
              let
                zls-json = pkgs.writeText "zls.build.json" ''

                '';
              in
              # bash
              ''
                cp --remove-destination  ${zls-json}/zls.build.json ./.
              '';
          };
        };
    };
}
