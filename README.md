# 🚀 KR7X's NixOS Configuration

A modern, modular NixOS configuration built with flakes, featuring a clean development environment, essential security, and quality-of-life improvements.

## ✨ Features

### 🏗️ **Modular Architecture**
- **Flake-based** configuration for reproducible builds
- **Modular design** with organized component separation  
- **Host-specific** configurations for different machines
- **Shared modules** for common functionality

### 🖥️ **Desktop Environment**
- **Hyprland** - Modern Wayland compositor
- **Custom theming** with Catppuccin colors
- **Font management** with Nerd Fonts support
- **Application launcher** and desktop utilities

### 💻 **Development Environment**
- **Multi-language support**: Go, Python, JavaScript, Nix
- **Modern tooling**: uv (Python), Neovim, VS Code, Docker
- **Enhanced shell** with Zsh, Starship prompt, modern CLI tools
- **Git integration** with delta, lazygit, and GitHub CLI

### 🔒 **Security**
- **Basic firewall** configuration with essential protections
- **Sudo security** with wheel group protection
- **Kernel security** with essential sysctl settings
- **System protection** policies without bloat

### ⚙️ **System Management**
- **Simple maintenance** with weekly cleanup
- **System monitoring** and optimization tools
- **Essential management utilities** (`system-info`, `rebuild`, `cleanup`)
- **Hardware support** via nixos-hardware

## 📁 Structure

```
.
├── flake.nix                    # Main flake configuration
├── hosts/
│   └── kr_laptop/              # Host-specific configs
│       ├── configuration.nix
│       └── hardware-configuration.nix
└── modules/
    ├── desktop/                # Desktop environment & UI
    │   ├── hyprland.nix       # Wayland compositor
    │   ├── themes.nix         # Color schemes & fonts
    │   └── fonts.nix          # Font configuration
    ├── programs/               
    │   ├── development.nix    # Dev tools & languages
    │   ├── shell.nix          # Shell & CLI tools
    │   └── applications.nix   # Desktop applications
    ├── system/
    │   ├── security.nix       # Basic security configuration
    │   ├── monitoring.nix     # System monitoring
    │   ├── maintenance.nix    # Simple maintenance tools
    │   └── optimization.nix   # Performance tuning
    ├── services/              # System services
    └── shared/                # Common configurations
```

## 🚀 Quick Start

### Prerequisites
- NixOS installed with flakes enabled
- Git configured

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/nixos-config.git ~/.kr_flake
   cd ~/.kr_flake
   ```

2. **Customize for your system**
   - Copy `hosts/kr_laptop/configuration-example.nix` to your own host config
   - Update hardware configuration: `nixos-generate-config --dir hosts/your-host/`
   - Modify `flake.nix` to include your host

3. **Build and switch**
   ```bash
   sudo nixos-rebuild switch --flake .#your-host
   ```

## 🔧 Management Commands

The configuration includes helpful management utilities:

```bash
system-info    # Display system status and information
rebuild        # Rebuild and switch to new configuration  
cleanup        # Clean up Nix store and optimize storage
```

## 📦 Key Components

### Development Tools
- **Languages**: Go, Python (with uv), JavaScript/Node.js, Nix
- **Editors**: Neovim (fully configured), VS Code with extensions  
- **CLI Tools**: bat, eza, fd, ripgrep, delta, lazygit, gh
- **Containers**: Docker with proper setup

### Desktop Applications
- **Browser**: Firefox
- **Terminal**: Alacritty
- **File Manager**: Thunar with plugins
- **Media**: MPV, GIMP, office tools
- **Communication**: Discord, messaging apps

### System Features
- **Shell**: Zsh with Oh My Zsh, autosuggestions, syntax highlighting
- **Prompt**: Starship with custom configuration
- **Fonts**: Complete Nerd Fonts collection
- **Theme**: Consistent Catppuccin theming across applications

## 🛡️ Security Features

- **Essential Firewall**: Clean configuration with necessary protections
- **Sudo Security**: Wheel group restrictions and secure defaults
- **Kernel Hardening**: Key sysctl settings for system protection
- **System Policies**: Basic security without unnecessary complexity

## 🎨 Customization

### Enabling/Disabling Modules

The configuration uses a modular approach. Enable or disable features in your host configuration:

```nix
myModules = {
  development = {
    enable = true;
    languages = [ "python" "go" "nix" ];
    editors = [ "neovim" ];
  };
  
  system = {
    security.enable = true;
    monitoring.enable = true;
    maintenance.enable = true;
  };
  
  desktop = {
    enable = true;
    hyprland.enable = true;
  };
};
```

### Adding New Hosts

1. Create a new directory in `hosts/`
2. Add `configuration.nix` and `hardware-configuration.nix`
3. Update `flake.nix` with the new host entry
4. Build with `nixos-rebuild switch --flake .#new-host`

## 🤝 Contributing

Contributions are welcome! This configuration is designed to be:
- **Modular** - Easy to add/remove components
- **Documented** - Clear code with explanations  
- **Flexible** - Adaptable to different use cases
- **Modern** - Using current best practices

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Test changes in a VM or non-production system
4. Submit a pull request with clear description

## 📚 Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes Guide](https://nixos.wiki/wiki/Flakes)  
- [Home Manager](https://github.com/nix-community/home-manager)
- [NixOS Hardware](https://github.com/NixOS/nixos-hardware)

## 📄 License

This configuration is available under the MIT License. Feel free to use, modify, and share!

## 🙏 Acknowledgments

- The NixOS community for excellent documentation and packages
- Contributors to nixos-hardware for device-specific configurations
- The Hyprland project for an amazing Wayland compositor
- All the open source projects that make this configuration possible

---

**Note**: This is a personal configuration optimized for development workstations. Review and customize the security settings, package selections, and configurations before using in production environments.
