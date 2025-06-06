{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myModules.applications;
in {
  options.myModules.applications = {
    enable = mkEnableOption "user applications";
    
    browsers = mkOption {
      type = types.listOf (types.enum [ "brave" "firefox" "chromium" ]);
      default = [];
      description = "Browsers to install";
    };
    
    media = mkOption {
      type = types.listOf (types.enum [ "vlc" "mpv" "spotify" "discord" ]);
      default = [];
      description = "Media and communication applications";
    };
    
    productivity = mkOption {
      type = types.listOf (types.enum [ "obsidian" "thunderbird" "libreoffice" "notion" ]);
      default = [];
      description = "Productivity applications";
    };

    gaming = mkOption {
      type = types.bool;
      default = false;
      description = "Enable gaming support";
    };

    creativity = mkOption {
      type = types.listOf (types.enum [ "gimp" "inkscape" "blender" "krita" ]);
      default = [];
      description = "Creative applications";
    };
  };

  config = mkIf cfg.enable {
    # Gaming support
    programs.steam = mkIf cfg.gaming {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    programs.gamemode.enable = cfg.gaming;

    # Flatpak support for additional applications
    services.flatpak.enable = true;

    environment.systemPackages = with pkgs; [
      # System utilities
      wget
      curl
      htop
      btop
      unzip
      zip
      p7zip
      gnutar
      xz
      gnupg
      pinentry-curses
      lm_sensors
      acpi
      parted
      gparted
      pavucontrol
      traceroute
      openconnect
      
      # Network tools
      nmap
      wireshark
      mtr
      iperf3
      
      # Archive and file tools
      atool
      unrar
      cabextract
      
      # Text editors and viewers
      micro
      nano
      less
      
      # PDF and document viewers
      evince
      
    ] ++ optionals (elem "brave" cfg.browsers) [
      brave
    ] ++ optionals (elem "firefox" cfg.browsers) [
      firefox
    ] ++ optionals (elem "chromium" cfg.browsers) [
      chromium
    ] ++ optionals (elem "vlc" cfg.media) [
      vlc
    ] ++ optionals (elem "mpv" cfg.media) [
      mpv
    ] ++ optionals (elem "spotify" cfg.media) [
      spotify
    ] ++ optionals (elem "discord" cfg.media) [
      discord
    ] ++ optionals (elem "obsidian" cfg.productivity) [
      obsidian
    ] ++ optionals (elem "thunderbird" cfg.productivity) [
      thunderbird
    ] ++ optionals (elem "libreoffice" cfg.productivity) [
      libreoffice
    ] ++ optionals (elem "gimp" cfg.creativity) [
      gimp
    ] ++ optionals (elem "inkscape" cfg.creativity) [
      inkscape
    ] ++ optionals (elem "blender" cfg.creativity) [
      blender
    ] ++ optionals (elem "krita" cfg.creativity) [
      krita
    ] ++ optionals cfg.gaming [
      # Gaming applications
      lutris
      heroic
      bottles
      mangohud
      gamescope
      
      # Game development
      godot_4
    ];

    # Fonts for better application support
    fonts.packages = with pkgs; [
      # Microsoft fonts for compatibility
      corefonts
      vistafonts
      
      # Additional fonts
      source-code-pro
      source-sans-pro
      source-serif-pro
    ];

    # Application-specific configurations
    # Note: thunar and file-roller are configured in file-management.nix
    
    # Better file associations
    xdg.mime.defaultApplications = {
      "application/pdf" = "evince.desktop";
      "text/plain" = "nvim.desktop";
      "text/html" = if (elem "brave" cfg.browsers) then "brave-browser.desktop" 
                   else if (elem "firefox" cfg.browsers) then "firefox.desktop"
                   else "chromium-browser.desktop";
      "x-scheme-handler/http" = if (elem "brave" cfg.browsers) then "brave-browser.desktop" 
                               else if (elem "firefox" cfg.browsers) then "firefox.desktop"
                               else "chromium-browser.desktop";
      "x-scheme-handler/https" = if (elem "brave" cfg.browsers) then "brave-browser.desktop" 
                                else if (elem "firefox" cfg.browsers) then "firefox.desktop"
                                else "chromium-browser.desktop";
      "image/jpeg" = "loupe.desktop";
      "image/png" = "loupe.desktop";
      "video/mp4" = if (elem "vlc" cfg.media) then "vlc.desktop" else "mpv.desktop";
      "audio/mpeg" = if (elem "vlc" cfg.media) then "vlc.desktop" else "mpv.desktop";
    };
  };
}
