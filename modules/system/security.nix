{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myModules.system.security;
in {
  options.myModules.system.security = {
    enable = mkEnableOption "enhanced security configuration";
    
    hardening = mkOption {
      type = types.bool;
      default = true;
      description = "Enable security hardening";
    };
    
    firewall = mkOption {
      type = types.bool;
      default = true;
      description = "Enable and configure firewall";
    };
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
      
      # AppArmor for additional security
      apparmor = mkIf cfg.hardening {
        enable = true;
        killUnconfinedConfinables = true;
      };
      
      # Audit system
      auditd.enable = mkIf cfg.hardening true;
      audit = mkIf cfg.hardening {
        enable = true;
        rules = [
          "-w /etc/passwd -p wa -k identity"
          "-w /etc/group -p wa -k identity"
          "-w /etc/shadow -p wa -k identity"
          "-w /etc/sudoers -p wa -k identity"
        ];
      };
    };

    # Firewall configuration
    networking.firewall = mkIf cfg.firewall {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      allowPing = false;
      logReversePathDrops = true;
      
      # Block common attack ports
      extraCommands = ''
        # Block common malware ports
        iptables -A nixos-fw -p tcp --dport 135 -j DROP
        iptables -A nixos-fw -p tcp --dport 139 -j DROP
        iptables -A nixos-fw -p tcp --dport 445 -j DROP
        iptables -A nixos-fw -p tcp --dport 1433 -j DROP
        iptables -A nixos-fw -p tcp --dport 3389 -j DROP
        
        # Rate limit SSH connections
        iptables -A nixos-fw -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set
        iptables -A nixos-fw -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
      '';
    };

    # Kernel hardening
    boot.kernel.sysctl = mkIf cfg.hardening {
      # Disable magic SysRq key
      "kernel.sysrq" = 0;
      
      # Prevent core dumps
      "fs.suid_dumpable" = 0;
      
      # Hide kernel pointers
      "kernel.kptr_restrict" = 2;
      
      # Restrict dmesg
      "kernel.dmesg_restrict" = 1;
      
      # Ignore ICMP redirects
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      
      # Ignore send redirects
      "net.ipv4.conf.all.send_redirects" = 0;
      
      # Disable source packet routing
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      
      # Log Martians
      "net.ipv4.conf.all.log_martians" = 1;
      
      # Ignore ping requests
      "net.ipv4.icmp_echo_ignore_all" = 1;
      
      # Enable TCP SYN cookies
      "net.ipv4.tcp_syncookies" = 1;
      
      # Disable IPv6 if not needed
      "net.ipv6.conf.all.disable_ipv6" = 1;
      "net.ipv6.conf.default.disable_ipv6" = 1;
    };

    # Additional security packages
    environment.systemPackages = mkIf cfg.hardening (with pkgs; [
      fail2ban
      clamav
      chkrootkit
      rkhunter        # Rootkit scanner
      lynis           # Security auditing
      aide            # File integrity checker
    ]);

    # Fail2ban with better configuration
    services.fail2ban = mkIf cfg.hardening {
      enable = true;
      maxretry = 3;
      bantime = "1h";
      ignoreIP = [
        "127.0.0.1/8"
        "192.168.0.0/16"
        "10.0.0.0/8"
      ];
      jails = {
        ssh = ''
          enabled = true
          port = ssh
          filter = sshd
          logpath = /var/log/auth.log
          maxretry = 3
          bantime = 3600
        '';
      };
    };

    # ClamAV antivirus
    services.clamav = mkIf cfg.hardening {
      daemon.enable = true;
      updater.enable = true;
    };

    # Automatic security updates (optional)
    system.autoUpgrade = mkIf cfg.hardening {
      enable = false;  # Set to true if you want automatic updates
      flake = "/home/carlos/.kr_flake";
      flags = [
        "--update-input"
        "nixpkgs"
        "--commit-lock-file"
      ];
      dates = "04:00";
      randomizedDelaySec = "45min";
    };
  };
}

