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
        set -euo pipefail
        
        echo "=== System Information ==="
        echo "Hostname: $(hostname)"
        echo "NixOS Version: $(nixos-version 2>/dev/null || echo "Unknown")"
        echo "Kernel: $(uname -r)"
        echo "Architecture: $(uname -m)"
        echo ""
        
        echo "=== System Status ==="
        echo "Uptime: $(uptime -p 2>/dev/null || uptime | sed 's/.*up //' | sed 's/,.*load.*//')"
        echo "Load Average: $(uptime | awk -F'load average:' '{print $2}' | sed 's/^ *//')"
        echo ""
        
        echo "=== Memory Usage ==="
        free -h | grep -E '^(Mem|Swap):'
        echo ""
        
        echo "=== Disk Usage ==="
        df -h / | tail -1 | awk '{print "Root: " $3 "/" $2 " (" $5 " used)"}'
        df -h /home 2>/dev/null | tail -1 | awk '{print "Home: " $3 "/" $2 " (" $5 " used)"}' || echo "Home: Same as root"
        echo ""
        
        echo "=== Nix Store ==="
        if [ -d /nix/store ]; then
          STORE_SIZE=$(du -sh /nix/store 2>/dev/null | awk '{print $1}' || echo "Unknown")
          STORE_COUNT=$(find /nix/store -maxdepth 1 -type d 2>/dev/null | wc -l || echo "Unknown")
          echo "Size: $STORE_SIZE"
          echo "Packages: $((STORE_COUNT - 1))"
        else
          echo "Nix store not found"
        fi
        echo ""
        
        echo "=== System Health ==="
        FAILED_SERVICES=$(systemctl --failed --no-legend 2>/dev/null | wc -l)
        if [ "$FAILED_SERVICES" -eq 0 ]; then
          echo "Services: All running normally ✓"
        else
          echo "Services: $FAILED_SERVICES failed services ⚠️"
          echo "Run 'systemctl --failed' for details"
        fi
        
        # Check if monitoring is enabled
        if systemctl is-active --quiet system-health-check.timer 2>/dev/null; then
          echo "Monitoring: Active ✓"
        else
          echo "Monitoring: Inactive"
        fi
        
        # Check last generation
        CURRENT_GEN=$(nixos-rebuild list-generations 2>/dev/null | tail -1 | awk '{print $1}' || echo "Unknown")
        echo "Current Generation: $CURRENT_GEN"
      '')
      
      # Quick rebuild
      (writeShellScriptBin "rebuild" ''
        #!/bin/bash
        set -euo pipefail
        
        # Default values
        FLAKE_DIR="/home/carlos/.kr_flake"
        HOST_NAME="kr_laptop"
        
        # Parse arguments
        OPERATION="switch"
        while [[ $# -gt 0 ]]; do
          case $1 in
            --test)
              OPERATION="test"
              shift
              ;;
            --boot)
              OPERATION="boot"
              shift
              ;;
            --rollback)
              echo "Rolling back to previous generation..."
              sudo nixos-rebuild switch --rollback
              exit 0
              ;;
            --dry-run)
              OPERATION="dry-run"
              shift
              ;;
            -h|--help)
              echo "Usage: rebuild [--test|--boot|--rollback|--dry-run]"
              echo "  --test     Build and test but don't activate"
              echo "  --boot     Build and activate on next boot"
              echo "  --rollback Rollback to previous generation"
              echo "  --dry-run  Show what would be built"
              exit 0
              ;;
            *)
              echo "Unknown option: $1"
              echo "Use --help for usage information"
              exit 1
              ;;
          esac
        done
        
        echo "=== NixOS Rebuild ($OPERATION) ==="
        
        # Check if flake directory exists
        if [ ! -d "$FLAKE_DIR" ]; then
          echo "Error: Flake directory $FLAKE_DIR not found"
          exit 1
        fi
        
        # Change to flake directory
        cd "$FLAKE_DIR" || exit 1
        
        # Check for uncommitted changes
        if [ -d ".git" ] && ! git diff --quiet 2>/dev/null; then
          echo "Warning: Git tree has uncommitted changes"
        fi
        
        # Run the rebuild
        echo "Building configuration..."
        sudo nixos-rebuild "$OPERATION" --flake ".#$HOST_NAME"
        
        if [ "$OPERATION" = "switch" ]; then
          echo "✓ System rebuilt and activated successfully"
        elif [ "$OPERATION" = "test" ]; then
          echo "✓ System built and tested successfully"
        elif [ "$OPERATION" = "boot" ]; then
          echo "✓ System built, will activate on next boot"
        elif [ "$OPERATION" = "dry-run" ]; then
          echo "✓ Dry run completed"
        fi
      '')
      
      # Simple cleanup
      (writeShellScriptBin "cleanup" ''
        #!/bin/bash
        set -euo pipefail
        
        # Parse arguments
        KEEP_DAYS="7"
        FORCE=false
        
        while [[ $# -gt 0 ]]; do
          case $1 in
            --keep-days)
              KEEP_DAYS="$2"
              shift 2
              ;;
            --force)
              FORCE=true
              shift
              ;;
            -h|--help)
              echo "Usage: cleanup [--keep-days N] [--force]"
              echo "  --keep-days N  Keep generations newer than N days (default: 7)"
              echo "  --force        Don't prompt for confirmation"
              exit 0
              ;;
            *)
              echo "Unknown option: $1"
              echo "Use --help for usage information"
              exit 1
              ;;
          esac
        done
        
        echo "=== System Cleanup ==="
        
        # Show current usage
        echo "Current Nix store size:"
        du -sh /nix/store 2>/dev/null || echo "Unable to determine size"
        echo ""
        
        # Show generations that will be removed
        echo "Generations older than $KEEP_DAYS days:"
        sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | \
          awk -v days="$KEEP_DAYS" '
          {
            cmd = "date -d \"" days " days ago\" +%s"
            cmd | getline cutoff
            close(cmd)
            
            if (NF >= 3) {
              cmd2 = "date -d \"" $2 " " $3 "\" +%s 2>/dev/null"
              if ((cmd2 | getline gen_time) > 0 && gen_time < cutoff) {
                print $0
              }
              close(cmd2)
            }
          }'
        echo ""
        
        if [ "$FORCE" = false ]; then
          echo "This will:"
          echo "  - Remove old generations (keeping last $KEEP_DAYS days)"
          echo "  - Collect garbage from Nix store"
          echo "  - Optimize store (deduplicate files)"
          echo ""
          read -p "Continue? (y/N) " -n 1 -r
          echo
          if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Cleanup cancelled"
            exit 0
          fi
        fi
        
        echo "Removing old generations..."
        sudo nix-collect-garbage --delete-older-than "''${KEEP_DAYS}d"
        
        echo "Collecting user garbage..."
        nix-collect-garbage -d
        
        echo "Optimizing store..."
        nix store optimise
        
        echo ""
        echo "New Nix store size:"
        du -sh /nix/store 2>/dev/null || echo "Unable to determine size"
        
        echo "✓ Cleanup completed successfully"
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
