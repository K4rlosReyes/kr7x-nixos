{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/shared/default.nix
    ../../modules/system/optimization.nix
    ../../modules/development/shells.nix
  ];

  # Host-specific configuration
  networking.hostName = "kr_laptop";
  
  # Enable custom modules with host-specific settings
  myModules = {
    development = {
      enable = true;
      languages = [ "go" "python" "javascript" "nix" ];
      editors = [ "vscode" "neovim" ];
      tools = [ "docker" ];
    };
    
    development.shells = {
      enable = true;
      languages = [ "go" "python" "node" ];
    };
    
    desktop = {
      hyprland.enable = true;
      themes = {
        enable = true;
        theme = "catppuccin";
      };
    };

    hardware.graphics = {
      enable = true;
      intel = true;  # Adjust based on your hardware
      # nvidia = true;  # Enable if you have NVIDIA
      # amd = true;     # Enable if you have AMD
    };

    system = {
      security = {
        enable = true;
        hardening = true;
        firewall = true;
      };
      
      optimization = {
        enable = true;
        profile = "laptop";
      };
    };

    applications = {
      enable = true;
      browsers = [ "brave" ];
      media = [ "vlc" ];
      productivity = [ "obsidian" "thunderbird" ];
    };
  };

  # Laptop-specific configurations
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 50;
    };
  };

  # Additional laptop packages
  environment.systemPackages = with pkgs; [
    powertop
    acpi
    brightnessctl
  ];

  system.stateVersion = "24.11";
}
