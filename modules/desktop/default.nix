{ config, lib, pkgs, ... }:

{
  imports = [
    ./fonts.nix
    ./hyprland.nix
    ./themes.nix
  ];
  
  # Common desktop settings
  services.xserver.enable = lib.mkDefault true;
  
  # XDG portal configuration
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
    config.common.default = "*";
  };
  
  # Common desktop packages
  environment.systemPackages = with pkgs; [
    # System monitoring
    gnome.gnome-system-monitor
    # Image viewer
    loupe
    # Video player
    totem
  ];
}
