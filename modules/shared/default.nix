{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # System modules
    ../system/nix.nix
    ../system/boot.nix
    ../system/networking.nix
    ../system/locale.nix
    ../system/users.nix
    ../system/security.nix
    
    # Hardware modules  
    ../hardware/audio.nix
    ../hardware/bluetooth.nix
    ../hardware/graphics.nix
    
    # Desktop environment
    ../desktop/hyprland.nix
    ../desktop/fonts.nix
    ../desktop/themes.nix
    
    # Programs
    ../programs/development.nix
    ../programs/shell.nix
    ../programs/applications.nix
    
    # Services
    ../services/file-management.nix
    ../services/printing.nix
    ../services/docker.nix
  ];

  # Common system configuration
  system = {
    stateVersion = "24.11";
    autoUpgrade = {
      enable = true;
      allowReboot = false;
      dates = "weekly";
    };
  };

  # Enable common services
  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    
    # System monitoring
    atd.enable = true;
    cron.enable = true;
  };

  # System-wide packages that should be available everywhere
  environment.systemPackages = with pkgs; [
    # Essential CLI tools
    curl
    wget
    tree
    htop
    btop
    neofetch
    unzip
    zip
    
    # File management
    fd
    ripgrep
    fzf
    bat
    eza
    
    # System utilities
    pciutils
    usbutils
    lshw
    dmidecode
    
    # Dotfiles management
    stow
    git
  ];

  # Fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
    ];
    
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "Fira Code" ];
      };
    };
  };
}
