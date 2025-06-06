{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myModules.desktop.themes;
in {
  options.myModules.desktop.themes = {
    enable = mkEnableOption "desktop themes and styling";
    
    theme = mkOption {
      type = types.enum [ "catppuccin" "gruvbox" "nord" "dracula" ];
      default = "catppuccin";
      description = "Theme to use";
    };
  };

  config = mkIf cfg.enable {
    # Qt theming
    qt = {
      enable = true;
      platformTheme = "gtk2";
      style = "gtk2";
    };

    # GTK theming
    programs.dconf.enable = true;
    
    environment.systemPackages = with pkgs; [
      # Themes
      catppuccin-gtk
      papirus-icon-theme
      
      # Theme tools
      lxappearance
      libsForQt5.qt5ct
      
      # Additional Nerd Fonts (base fonts in fonts.nix)
      nerd-fonts.hack
    ];

    # Default applications
    xdg.mime.defaultApplications = {
      "text/html" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
      "x-scheme-handler/about" = "brave-browser.desktop";
      "x-scheme-handler/unknown" = "brave-browser.desktop";
    };
  };
}
