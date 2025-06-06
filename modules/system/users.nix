{ config, lib, pkgs, ... }:

{
  users.users.carlos = {
    isNormalUser = true;
    description = "Carlos";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "input" "docker" "storage" ];
    shell = pkgs.zsh;
    packages = with pkgs; [];
  };
}
