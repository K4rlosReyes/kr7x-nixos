{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ 
        "git" 
        "sudo" 
        "docker" 
        "history" 
        "direnv"
        "kubectl"
        "terraform"
        "systemd"
        "fzf"
      ];
      theme = "agnoster";  # Better theme with git info
    };
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    
    # Additional zsh configuration
    shellInit = ''
      # Better history
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_SPACE
      setopt HIST_VERIFY
      setopt SHARE_HISTORY
      
      # Better completion
      setopt AUTO_LIST
      setopt AUTO_MENU
      setopt COMPLETE_IN_WORD
      
      # Useful aliases
      alias ll='eza -la --icons'
      alias la='eza -la --icons'
      alias lt='eza --tree --icons'
      alias cat='bat'
      alias find='fd'
      alias grep='rg'
      alias top='btop'
      alias ps='procs'
      
      # NixOS specific aliases
      alias nrs='sudo nixos-rebuild switch --flake /home/carlos/.kr_flake'
      alias nrt='sudo nixos-rebuild test --flake /home/carlos/.kr_flake'
      alias nfu='nix flake update /home/carlos/.kr_flake'
      alias ncg='nix-collect-garbage -d && sudo nix-collect-garbage -d'
      alias nso='nix store optimise'
      
      # Git aliases
      alias gs='git status'
      alias ga='git add'
      alias gc='git commit'
      alias gp='git push'
      alias gl='git pull'
      alias gd='git diff'
      alias lg='lazygit'
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      format = "$all$character";
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = " ";
      };
      nix_shell = {
        format = "[$symbol$state]($style) ";
        symbol = " ";
      };
    };
  };

  # Enable fzf for better fuzzy finding
  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };

  environment.systemPackages = with pkgs; [
    zsh
    oh-my-zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    starship
    fzf
    eza      # Better ls
    bat      # Better cat
    fd       # Better find
    ripgrep  # Better grep
    btop     # Better top
    procs    # Better ps
    du-dust  # Better du
    duf      # Better df
    mcfly    # Better history search
  ];
}
