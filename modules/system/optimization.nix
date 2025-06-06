{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myModules.system.optimization;
in {
  options.myModules.system.optimization = {
    enable = mkEnableOption "system performance optimizations";
    
    profile = mkOption {
      type = types.enum [ "desktop" "laptop" "server" ];
      default = "desktop";
      description = "Optimization profile to use";
    };
  };

  config = mkIf cfg.enable {
    # Kernel parameters for performance
    boot.kernel.sysctl = {
      # Virtual memory tweaks
      "vm.swappiness" = if cfg.profile == "laptop" then 10 else 5;
      "vm.vfs_cache_pressure" = 50;
      "vm.dirty_ratio" = 15;
      "vm.dirty_background_ratio" = 10;
      
      # Network performance
      "net.core.rmem_default" = 31457280;
      "net.core.rmem_max" = 134217728;
      "net.core.wmem_default" = 31457280;
      "net.core.wmem_max" = 134217728;
      "net.core.netdev_max_backlog" = 5000;
      
      # File system
      "fs.file-max" = 2097152;
      "fs.inotify.max_user_watches" = 524288;
    };

    # Power management for laptops
    services.auto-cpufreq = mkIf (cfg.profile == "laptop") {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };

    # Gaming optimizations for desktop
    programs.gamemode = mkIf (cfg.profile == "desktop") {
      enable = true;
      settings = {
        general = {
          renice = 10;
        };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
        };
      };
    };

    # Zram for better memory management
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = if cfg.profile == "laptop" then 25 else 50;
    };

    # Optimize storage
    services.fstrim.enable = true;
    
    # Better scheduler for SSDs
    services.udev.extraRules = ''
      ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
      ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
    '';
  };
}
