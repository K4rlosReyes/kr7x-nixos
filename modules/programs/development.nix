{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myModules.development;
in {
  options.myModules.development = {
    enable = mkEnableOption "development environment";
    
    languages = mkOption {
      type = types.listOf (types.enum [ "go" "python" "javascript" "rust" "nix" "c" ]);
      default = [];
      description = "Programming languages to support";
    };
    
    editors = mkOption {
      type = types.listOf (types.enum [ "vscode" "neovim" ]);
      default = [ "neovim" ];
      description = "Code editors to include";
    };
    
    tools = mkOption {
      type = types.listOf (types.enum [ "docker" "k8s" "terraform" "ansible" ]);
      default = [];
      description = "Development tools to include";
    };

    # New options for better development workflow
    enableDirenv = mkOption {
      type = types.bool;
      default = true;
      description = "Enable direnv for project-specific environments";
    };

    enableGitExtras = mkOption {
      type = types.bool;
      default = true;
      description = "Enable additional git tools and configuration";
    };
  };

  config = mkIf cfg.enable {
    # Enable direnv
    programs.direnv = mkIf cfg.enableDirenv {
      enable = true;
      nix-direnv.enable = true;
    };

    environment.systemPackages = with pkgs; [
      # Basic development tools
      git
      neovim
      gcc
      gnumake
      cmake
      jq
      
      # Enhanced development tools
      fd              # Better find
      ripgrep         # Better grep
      bat             # Better cat
      eza             # Better ls
      delta           # Better git diff
      lazygit         # Git TUI
      gh              # GitHub CLI
      tree            # Directory tree
      tokei           # Code statistics
      hyperfine       # Benchmarking
      
      # Network tools
      nmap
      wireshark
      mtr
      
      # System tools
      lsof
      strace
      gdb
      valgrind
      
    ] ++ optionals cfg.enableGitExtras [
      git-absorb      # Automatic fixup commits
      git-extras      # Additional git commands
      gitui           # Git TUI alternative
      gitmux          # Git status in tmux
      
    ] ++ optionals (elem "go" cfg.languages) [
      go
      gopls           # Go LSP
      golangci-lint   # Go linter
      delve           # Go debugger
      
    ] ++ optionals (elem "python" cfg.languages) [
      python3
      python3Packages.pip
      python3Packages.virtualenv
      uv              # Fast Python package manager (replaces Poetry)
      ruff            # Python linter/formatter (faster than flake8/pylint)
      python3Packages.pytest     # Testing framework
      python3Packages.mypy       # Type checker
      python3Packages.ipython    # Enhanced Python REPL
      python3Packages.jupyterlab # Jupyter notebooks
      
    ] ++ optionals (elem "javascript" cfg.languages) [
      nodejs
      nodePackages.npm
      nodePackages.pnpm
      nodePackages.yarn
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodePackages.prettier
      nodePackages.eslint
      
    ] ++ optionals (elem "rust" cfg.languages) [
      rustc
      cargo
      rust-analyzer   # Rust LSP
      rustfmt         # Rust formatter
      clippy          # Rust linter
      
    ] ++ optionals (elem "nix" cfg.languages) [
      nil             # Nix LSP
      nixd            # Alternative Nix LSP
      nixfmt-rfc-style # Nix formatter
      statix          # Nix linter
      
    ] ++ optionals (elem "vscode" cfg.editors) [
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          # Language support
          golang.go
          ms-python.python
          rust-lang.rust-analyzer
          bradlc.vscode-tailwindcss
          
          # Nix support
          bbenoist.nix
          
          # Git
          mhutchie.git-graph
          eamodio.gitlens
          
          # Productivity
          vscodevim.vim
          github.copilot
          github.copilot-chat
          
          # Themes
          catppuccin.catppuccin-vsc
          
          # Utils
          ms-vscode.cmake-tools
          tamasfe.even-better-toml
          redhat.vscode-yaml
          ms-vscode.hexeditor
        ];
      })
    ];

    # Git global configuration
    programs.git = mkIf cfg.enableGitExtras {
      enable = true;
      config = {
        init.defaultBranch = "main";
        core = {
          editor = "nvim";
          pager = "delta";
        };
        delta = {
          navigate = true;
          light = false;
        };
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
        pull.rebase = true;
        push.autoSetupRemote = true;
        rebase.autoStash = true;
      };
    };
  };
}
