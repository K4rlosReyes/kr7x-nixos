{ config, lib, pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./graphics.nix
  ];
  
  # Common hardware optimizations
  hardware = {
    enableAllFirmware = lib.mkDefault true;
    enableRedistributableFirmware = lib.mkDefault true;
    
    # CPU microcode updates
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
  
  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "powersave";
  };
  
  # Thermal management
  services.thermald.enable = lib.mkDefault true;
}
