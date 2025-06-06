{ config, lib, pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      ubuntu_font_family
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "Ubuntu" "Noto Serif" ];
        sansSerif = [ "Ubuntu" "Noto Sans" ];
        monospace = [ "JetBrains Mono" "Fira Code" ];
      };
    };
  };
}
