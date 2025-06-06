{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myModules.system.maintenance;
in {
  options.myModules.system.maintenance = {
    enable = mkEnableOption "system maintenance and backup";
    
    autoCleanup = mkOption {
      type = types.bool;
      default = true;
      description = "Enable automatic system cleanup";
    };
    
    backupConfig = mkOption {
      type = types.bool;
      default = true;
      description = "Enable configuration backup";
    };
  };

  config = mkIf cfg.enable {
    # System maintenance script
    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "system-maintenance" ''
        #!/bin/bash
        echo "🔧 Starting comprehensive system maintenance..."
        
        # Check system health first
        echo "🏥 Checking system health..."
        system-info
        
        # Update system
        echo "📦 Updating flake inputs..."
        cd /home/carlos/.kr_flake || exit 1
        nix flake update
        
        # Show what will be updated
        echo "🔍 Checking what will change..."
        nixos-rebuild build --flake .#kr_laptop
        nix store diff-closures /run/current-system ./result
        
        # Ask for confirmation
        read -p "Continue with rebuild? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "❌ Maintenance cancelled"
            exit 1
        fi
        
        # Rebuild system
        echo "🏗️  Rebuilding system..."
        sudo nixos-rebuild switch --flake .#kr_laptop
        
        # Clean up
        echo "🧹 Cleaning up..."
        nix-collect-garbage -d
        sudo nix-collect-garbage -d
        
        # Optimize store
        echo "⚡ Optimizing Nix store..."
        nix store optimise
        
        # Update locate database
        echo "🗂️  Updating locate database..."
        sudo updatedb
        
        echo "✅ System maintenance completed!"
        echo "📊 Final system status:"
        system-info
      '')
      
      (writeShellScriptBin "backup-config" ''
        #!/bin/bash
        BACKUP_DIR="$HOME/nixos-backups/$(date +%Y-%m-%d-%H%M%S)"
        
        echo "💾 Creating configuration backup at $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        
        # Backup flake configuration
        cp -r /home/carlos/.kr_flake/* "$BACKUP_DIR/"
        
        # Backup current generation
        nix-env --list-generations > "$BACKUP_DIR/user-generations.txt"
        sudo nix-env --list-generations --profile /nix/var/nix/profiles/system > "$BACKUP_DIR/system-generations.txt"
        
        # Hardware info
        lshw -json > "$BACKUP_DIR/hardware-info.json" 2>/dev/null || echo "lshw not available"
        
        # System info
        uname -a > "$BACKUP_DIR/system-info.txt"
        nixos-version > "$BACKUP_DIR/nixos-version.txt"
        
        # Installed packages
        nix-env -q > "$BACKUP_DIR/user-packages.txt"
        
        # Create archive
        cd "$HOME/nixos-backups" || exit 1
        tar -czf "$(basename "$BACKUP_DIR").tar.gz" "$(basename "$BACKUP_DIR")"
        rm -rf "$BACKUP_DIR"
        
        echo "✅ Backup completed at $HOME/nixos-backups/$(basename "$BACKUP_DIR").tar.gz"
      '')
      
      (writeShellScriptBin "system-info" ''
        #!/bin/bash
        echo "🖥️  System Information"
        echo "===================="
        echo "Hostname: $(hostname)"
        echo "Kernel: $(uname -r)"
        echo "NixOS: $(nixos-version)"
        echo "Uptime: $(uptime -p)"
        echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
        echo
        
        echo "💾 Storage Usage"
        echo "==============="
        df -h / /boot /home 2>/dev/null || df -h /
        echo
        
        echo "🧠 Memory Usage"
        echo "=============="
        free -h
        echo
        
        echo "🗂️  Nix Store"
        echo "============"
        du -sh /nix/store 2>/dev/null || echo "Cannot access /nix/store"
        echo "User generations: $(nix-env --list-generations | wc -l)"
        echo "System generations: $(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | wc -l)"
        echo
        
        echo "🔋 Power (if available)"
        echo "======================"
        if command -v acpi &> /dev/null; then
          acpi -b
        else
          echo "Not a laptop or acpi not available"
        fi
        echo
        
        echo "🌡️  Temperature (if available)"
        echo "============================="
        if command -v sensors &> /dev/null; then
          sensors | grep -E "(Core|temp)" | head -5
        else
          echo "lm-sensors not available"
        fi
      '')

      # Quick rebuild script
      (writeShellScriptBin "quick-rebuild" ''
        #!/bin/bash
        echo "⚡ Quick system rebuild..."
        cd /home/carlos/.kr_flake || exit 1
        sudo nixos-rebuild switch --flake .#kr_laptop --fast
        echo "✅ Quick rebuild completed!"
      '')

      # Development environment setup
      (writeShellScriptBin "dev-setup" ''
        #!/bin/bash
        PROJECT_NAME="$1"
        PROJECT_TYPE="$2"
        
        if [ -z "$PROJECT_NAME" ] || [ -z "$PROJECT_TYPE" ]; then
          echo "Usage: dev-setup <project-name> <project-type>"
          echo "Types: go, python, javascript, rust, nix"
          exit 1
        fi
        
        mkdir -p "$HOME/dev/$PROJECT_NAME"
        cd "$HOME/dev/$PROJECT_NAME" || exit 1
        
        case "$PROJECT_TYPE" in
          "go")
            echo "Setting up Go project..."
            go mod init "$PROJECT_NAME"
            cat > .envrc << EOF
use flake
EOF
            cat > flake.nix << EOF
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.system;
  in {
    devShells.system.default = pkgs.mkShell {
      buildInputs = with pkgs; [ go gopls go-tools ];
    };
  };
}
EOF
            ;;
          "python")
            echo "Setting up Python project..."
            cat > .envrc << EOF
use flake
EOF
            cat > flake.nix << EOF
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.system;
  in {
    devShells.system.default = pkgs.mkShell {
      buildInputs = with pkgs; [ python3 python3Packages.pip python3Packages.virtualenv ];
    };
  };
}
EOF
            ;;
          *)
            echo "Unknown project type: $PROJECT_TYPE"
            exit 1
            ;;
        esac
        
        direnv allow
        echo "✅ Development environment set up for $PROJECT_NAME ($PROJECT_TYPE)"
      '')
    ];

    # Automatic cleanup systemd service
    systemd.services.nix-cleanup = mkIf cfg.autoCleanup {
      description = "Clean up Nix store";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        ${pkgs.nix}/bin/nix-collect-garbage --delete-older-than 7d
        ${pkgs.nix}/bin/nix store optimise
      '';
    };

    systemd.timers.nix-cleanup = mkIf cfg.autoCleanup {
      description = "Clean up Nix store weekly";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
    };

    # Configuration backup service
    systemd.services.config-backup = mkIf cfg.backupConfig {
      description = "Backup NixOS configuration";
      serviceConfig = {
        Type = "oneshot";
        User = "carlos";
      };
      script = ''
        BACKUP_DIR="/home/carlos/nixos-backups/auto-$(date +%Y-%m-%d)"
        mkdir -p "$BACKUP_DIR"
        cp -r /etc/nixos/* "$BACKUP_DIR/"
        
        # Keep only last 10 backups
        cd /home/carlos/nixos-backups
        ls -t | tail -n +11 | xargs -r rm -rf
      '';
    };

    systemd.timers.config-backup = mkIf cfg.backupConfig {
      description = "Backup configuration daily";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
  };
}
