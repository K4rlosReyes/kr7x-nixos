{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myModules.desktop.hyprland;
in {
  options.myModules.desktop.hyprland = {
    enable = mkEnableOption "Hyprland desktop environment";
    
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra Hyprland configuration";
    };
    
    wallpaper = mkOption {
      type = types.str;
      default = "";
      description = "Path to wallpaper image";
    };
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    services.displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        theme = "sddm-astronaut-theme";
        settings = {
          Theme = {
            Current = "sddm-astronaut-theme";
            CursorTheme = "catppuccin-cursors";
          };
        };
      };
    };

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # Enhanced environment variables for Wayland
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
      
      # Qt/GTK Wayland support
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      GDK_BACKEND = "wayland,x11";
      
      # Firefox Wayland
      MOZ_ENABLE_WAYLAND = "1";
      
      # Electron apps
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      
      # Java applications
      _JAVA_AWT_WM_NONREPARENTING = "1";
      
      # Cursor theme
      XCURSOR_THEME = "catppuccin-cursors";
      XCURSOR_SIZE = "24";
    };

    environment.systemPackages = with pkgs; [
      # Core Hyprland utilities
      kitty
      waybar
      wofi
      rofi-wayland
      wl-clipboard
      wl-clip-persist
      
      # Screenshot and screen recording
      grim
      slurp
      swappy
      wf-recorder
      
      # Wallpaper and theming
      hyprpaper
      swww
      
      # Screen locking and idle
      hyprlock
      hypridle
      
      # System control
      brightnessctl
      playerctl
      pamixer
      
      # Notifications
      dunst
      libnotify
      
      # Desktop portal
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
      
      # Network management
      networkmanagerapplet
      
      # Theme components
      sddm-astronaut
      catppuccin-cursors
      
      # Additional utilities
      wlr-randr          # Display configuration
      wlogout            # Logout menu
    ];

    # Security for Hyprland
    security.pam.services.hyprlock = {
      text = ''
        auth include login
      '';
    };
  };
}
