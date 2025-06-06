{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myModules.system.monitoring;
in {
  options.myModules.system.monitoring = {
    enable = mkEnableOption "system monitoring and performance tracking";
    
    enableMetrics = mkOption {
      type = types.bool;
      default = true;
      description = "Enable system metrics collection";
    };
    
    enableNotifications = mkOption {
      type = types.bool;
      default = true;
      description = "Enable system notifications for issues";
    };
  };

  config = mkIf cfg.enable {
    # System monitoring tools
    environment.systemPackages = with pkgs; [
      # Performance monitoring
      htop
      btop
      iotop
      nethogs
      bandwhich
      
      # System information
      neofetch
      inxi
      hw-probe
      
      # Log analysis
      lnav
      multitail
      
      # Network monitoring
      iftop
      vnstat
      nload
      
      # Disk monitoring
      ncdu
      duf
      smartmontools
    ];

    # Enable smart monitoring for disks
    services.smartd = {
      enable = true;
      autodetect = true;
      notifications = {
        mail = mkIf cfg.enableNotifications {
          enable = true;
          sender = "smartd@$(hostname)";
          recipient = "root";
        };
        wall.enable = cfg.enableNotifications;
      };
    };

    # System journal configuration
    services.journald.extraConfig = ''
      SystemMaxUse=1G
      SystemMaxFiles=10
      SystemMaxFileSize=100M
      MaxRetentionSec=1month
    '';

    # Log rotation
    services.logrotate = {
      enable = true;
      settings = {
        header = {
          dateext = true;
          compress = true;
          rotate = 52;
          weekly = true;
        };
      };
    };

    # Network statistics
    services.vnstat.enable = true;

    # System performance tuning
    boot.kernel.sysctl = {
      # Network performance
      "net.core.default_qdisc" = mkDefault "fq";
      "net.ipv4.tcp_congestion_control" = mkDefault "bbr";
      
      # Virtual memory
      "vm.swappiness" = mkDefault 10;
      "vm.dirty_ratio" = mkDefault 15;
      "vm.dirty_background_ratio" = mkDefault 5;
      
      # File system performance
      "fs.file-max" = mkDefault 2097152;
      "fs.inotify.max_user_watches" = mkDefault 524288;
    };

    # Systemd service for system health check
    systemd.services.system-health-check = mkIf cfg.enableNotifications {
      description = "System Health Check";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        #!/bin/bash
        
        # Check disk space
        DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
        if [ "$DISK_USAGE" -gt 85 ]; then
          echo "WARNING: Root filesystem is $DISK_USAGE% full" | systemd-cat -t system-health -p warning
        fi
        
        # Check load average
        LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
        CPU_CORES=$(nproc)
        if (( $(echo "$LOAD_AVG > $CPU_CORES * 2" | bc -l) )); then
          echo "WARNING: High load average: $LOAD_AVG" | systemd-cat -t system-health -p warning
        fi
        
        # Check memory usage
        MEM_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
        if [ "$MEM_USAGE" -gt 85 ]; then
          echo "WARNING: Memory usage is $MEM_USAGE%" | systemd-cat -t system-health -p warning
        fi
        
        # Check failed systemd services
        FAILED_SERVICES=$(systemctl --failed --no-legend | wc -l)
        if [ "$FAILED_SERVICES" -gt 0 ]; then
          echo "WARNING: $FAILED_SERVICES failed systemd services" | systemd-cat -t system-health -p warning
        fi
      '';
    };

    systemd.timers.system-health-check = mkIf cfg.enableNotifications {
      description = "Run system health check";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*:0/30";  # Every 30 minutes
        Persistent = true;
      };
    };
  };
}
