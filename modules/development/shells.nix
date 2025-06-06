{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myModules.development.shells;
in {
  options.myModules.development.shells = {
    enable = mkEnableOption "development shells with direnv";
    
    languages = mkOption {
      type = types.listOf (types.enum [ "go" "python" "rust" "node" "nix" ]);
      default = [];
      description = "Languages to create development shells for";
    };
  };

  config = mkIf cfg.enable {
    # Enable direnv for automatic shell loading
    programs.direnv = {
      enable = true;
      silent = false;
      loadInNixShell = true;
      direnvrcExtra = ''
        : ''${XDG_CACHE_HOME:=$HOME/.cache}
        declare -A direnv_layout_dirs
        direnv_layout_dir() {
          echo "''${direnv_layout_dirs[$PWD]:=$(
            echo -n "$XDG_CACHE_HOME"/direnv/layouts/
            echo -n "$PWD" | shasum | cut -d ' ' -f 1
          )}"
        }
      '';
    };

    environment.systemPackages = with pkgs; [
      # Development tools
      direnv
      nix-direnv
    ];

    # Configure nix-direnv
    nix.settings = {
      keep-derivations = true;
      keep-outputs = true;
    };

    environment.pathsToLink = [
      "/share/nix-direnv"
    ];

    # Create template development shells
    environment.etc = mkMerge [
      (mkIf (elem "go" cfg.languages) {
        "dev-templates/go/.envrc".text = ''
          use flake
        '';
        "dev-templates/go/flake.nix".text = ''
          {
            description = "Go development environment";
            inputs = {
              nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
              flake-utils.url = "github:numtide/flake-utils";
            };
            outputs = { self, nixpkgs, flake-utils }:
              flake-utils.lib.eachDefaultSystem (system:
                let pkgs = nixpkgs.legacyPackages.''${system}; in {
                  devShells.default = pkgs.mkShell {
                    buildInputs = with pkgs; [
                      go
                      gopls
                      gotools
                      go-tools
                      delve
                    ];
                    shellHook = '''
                      echo "Go development environment loaded"
                      go version
                    ''';
                  };
                });
          }
        '';
      })

      (mkIf (elem "python" cfg.languages) {
        "dev-templates/python/.envrc".text = ''
          use flake
        '';
        "dev-templates/python/flake.nix".text = ''
          {
            description = "Python development environment";
            inputs = {
              nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
              flake-utils.url = "github:numtide/flake-utils";
            };
            outputs = { self, nixpkgs, flake-utils }:
              flake-utils.lib.eachDefaultSystem (system:
                let pkgs = nixpkgs.legacyPackages.''${system}; in {
                  devShells.default = pkgs.mkShell {
                    buildInputs = with pkgs; [
                      python3
                      python3Packages.pip
                      python3Packages.virtualenv
                      python3Packages.black
                      python3Packages.flake8
                      python3Packages.pytest
                    ];
                    shellHook = '''
                      echo "Python development environment loaded"
                      python --version
                    ''';
                  };
                });
          }
        '';
      })
    ];
  };
}
