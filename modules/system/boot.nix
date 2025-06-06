{ config, lib, pkgs, ... }:

{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "quiet" "splash" ];
  };

  services.fwupd.enable = true;
}
