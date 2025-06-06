{ config, lib, pkgs, ... }:

{
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.udisks2.enable = true;
  services.devmon.enable = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
      thunar-media-tags-plugin
    ];
  };

  environment.systemPackages = with pkgs; [
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    xfce.thunar-media-tags-plugin
    ffmpegthumbnailer
    xfce.tumbler
    gvfs
    libgsf
    poppler
    glib
    file-roller
    libnotify
    exfat
    ntfs3g
    usbutils
    udisks2
    papirus-icon-theme
    gtk3
  ];
}
