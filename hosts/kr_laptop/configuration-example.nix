# Example updated host configuration to demonstrate the improvements
{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/shared
  ];

  # Enable the new monitoring module
  myModules.system.monitoring = {
    enable = true;
    enableMetrics = true;
    enableNotifications = true;
  };

  # Enhanced development environment
  myModules.development = {
    enable = true;
    languages = [ "nix" "go" "python" "javascript" ];
    editors = [ "neovim" "vscode" ];
    tools = [ "docker" ];
    enableDirenv = true;
    enableGitExtras = true;
  };

  # Better application setup
  myModules.applications = {
    enable = true;
    browsers = [ "brave" "firefox" ];
    media = [ "vlc" "mpv" "spotify" "discord" ];
    productivity = [ "obsidian" "thunderbird" "libreoffice" ];
    gaming = true;
    creativity = [ "gimp" "inkscape" ];
  };

  # Basic security
  myModules.system.security = {
    enable = true;
  };

  # Desktop environment
  myModules.desktop.hyprland = {
    enable = true;
    wallpaper = "/home/carlos/.wallpapers/default.jpg";
  };

  myModules.desktop.themes = {
    enable = true;
    theme = "catppuccin";
  };

  # Hardware configuration
  myModules.hardware.graphics = {
    enable = true;
    intel = true;  # or nvidia = true; amd = true;
  };

  # System configuration
  system.stateVersion = "24.11";
}
