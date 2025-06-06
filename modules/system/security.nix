{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myModules.system.security;
in {
  options.myModules.system.security = {
    enable = mkEnableOption "basic security configuration";
  };

  config = mkIf cfg.enable {
    security = {
      sudo = {
        wheelNeedsPassword = true;
        execWheelOnly = true;
      };
      
      polkit.enable = true;
      rtkit.enable = true;
      protectKernelImage = true;
    };

    # Basic firewall configuration
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      allowPing = false;
      logReversePathDrops = true;
    };

    # Basic kernel security settings
    boot.kernel.sysctl = {
      # Disable magic SysRq key
      "kernel.sysrq" = 0;
      
      # Ignore ICMP redirects
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      
      # Disable source packet routing
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      
      # Enable TCP SYN cookies
      "net.ipv4.tcp_syncookies" = 1;
    };
  };
}

