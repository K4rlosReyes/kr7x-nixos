{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myModules.system.maintenance;
in {
  options.myModules.system.maintenance = {
    enable = mkEnableOption "simple system maintenance";
  };

  config = mkIf cfg.enable {
    # Simple maintenance utilities
    environment.systemPackages = with pkgs; [
      # Basic system info
      (writeShellScriptBin "system-info" ''
        #!/bin/bash
        echo "System: $(hostname) - $(nixos-version)"
        echo "Uptime: $(uptime -p)"
        echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
        echo "Memory: $(free -h | grep '^Mem:' | awk '{print $3 "/" $2}')"
        echo "Storage: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')"
        echo "Nix Store: $(du -sh /nix/store 2>/dev/null || echo "N/A")"
      '')
      
      # Quick rebuild
      (writeShellScriptBin "rebuild" ''
        #!/bin/bash
        cd /home/carlos/.kr_flake || exit 1
        sudo nixos-rebuild switch --flake .#kr_laptop
      '')
      
      # Simple cleanup
      (writeShellScriptBin "cleanup" ''
        #!/bin/bash
        echo "Cleaning up Nix store..."
        nix-collect-garbage -d
        sudo nix-collect-garbage -d
        nix store optimise
        echo "Done!"
      '')
    ];

    # Weekly automatic cleanup
    systemd.services.nix-cleanup = {
      description = "Clean up Nix store";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        ${pkgs.nix}/bin/nix-collect-garbage --delete-older-than 14d
        ${pkgs.nix}/bin/nix store optimise
      '';
    };

    systemd.timers.nix-cleanup = {
      description = "Clean up Nix store weekly";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
    };
  };
}
