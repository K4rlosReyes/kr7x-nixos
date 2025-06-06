{ config, lib, pkgs, ... }:

with lib;

{
  networking = {
    networkmanager.enable = true;
    nameservers = [ "1.1.1.1" "9.9.9.9" ];
    firewall = {
      enable = true;
      allowPing = mkDefault true;
    };
  };
}
