{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myModules.hardware.graphics;
in {
  options.myModules.hardware.graphics = {
    enable = mkEnableOption "graphics support";
    
    nvidia = mkOption {
      type = types.bool;
      default = false;
      description = "Enable NVIDIA graphics support";
    };
    
    amd = mkOption {
      type = types.bool;
      default = false;
      description = "Enable AMD graphics support";
    };
    
    intel = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Intel graphics support";
    };
  };

  config = mkIf cfg.enable {
    # Enable Graphics
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      
      extraPackages = with pkgs; [
        # Intel packages
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        intel-compute-runtime
        # Vulkan support
        vulkan-loader
        vulkan-validation-layers
        vulkan-tools
      ] ++ optionals cfg.amd [
        amdvlk
        rocmPackages.clr.icd
      ];
    };

    # Video drivers configuration
    services.xserver.videoDrivers = 
      (optional cfg.nvidia "nvidia") ++
      (optional cfg.amd "amdgpu") ++
      (optional cfg.intel "modesetting");

    # NVIDIA configuration
    hardware.nvidia = mkIf cfg.nvidia {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
}
