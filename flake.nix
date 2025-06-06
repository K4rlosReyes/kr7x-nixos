{
  description = "KR7X's system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    
    # Hardware support
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    
    # Community packages
    nur.url = "github:nix-community/NUR";
    
    # Hyprland (latest)
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, nixos-hardware, nur, hyprland, ... }@inputs: {
    nixosConfigurations = {
      # Desktop system
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/desktop/configuration.nix
        ];
      };
      
      # Laptop system
      kr_laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/kr_laptop/configuration.nix
        ];
      };
    };
  };
}
