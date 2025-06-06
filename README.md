# 🚀 KR7X's NixOS Configuration

A clean, modular NixOS configuration built with flakes, featuring a streamlined development environment with essential security and practical quality-of-life improvements. Designed for simplicity and maintainability without unnecessary bloat.

> **🎯 Focus**: This configuration prioritizes **practical development** over comprehensive features. It includes everything you need for Go, Python, JavaScript, and Nix development while maintaining system security and performance.

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
- **Multi-language support**: Go, Python (with uv), JavaScript/TypeScript, Nix
- **Modern tooling**: uv for Python package management, Neovim with LSP, VS Code
- **Enhanced shell** with Zsh, Starship prompt, modern CLI tools (bat, eza, fd, ripgrep)
- **Git workflow** with delta, lazygit, GitHub CLI, and proper configuration
- **Container support** with Docker and development utilities

### 🔒 **Security**
- **Streamlined security** with essential protections only
- **Basic firewall** with clean, minimal rules
- **Sudo hardening** with wheel group restrictions
- **Essential kernel settings** for system protection
- **No bloat** - AppArmor, Fail2ban, and complex auditing removed for simplicity

### ⚙️ **System Management**
- **Simple maintenance** with automated weekly cleanup
- **System monitoring** with health checks and performance tuning
- **Essential utilities** (`system-info`, `rebuild`, `cleanup`)
- **Hardware support** via nixos-hardware and optimized settings
- **Automated updates** with rollback capabilities

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
   git clone https://github.com/K4rlosReyes/kr7x-nixos.git ~/.kr_flake
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
- **Languages**: Go, Python (with uv package manager), JavaScript/TypeScript, Nix
- **Editors**: Neovim (LSP configured for all languages), VS Code with language extensions
- **CLI Tools**: bat (cat replacement), eza (ls replacement), fd (find), ripgrep (grep), delta (git diff)
- **Git Workflow**: lazygit, GitHub CLI (gh), proper Git configuration with aliases
- **Python**: uv for fast package management, pytest, mypy, ipython, jupyterlab
- **Containers**: Docker with proper daemon setup and user permissions

### Desktop Applications
- **Browser**: Firefox with privacy enhancements
- **Terminal**: Alacritty with proper font rendering
- **File Manager**: Thunar with archive support and plugins
- **Development**: VS Code, Neovim, Git tools
- **Media**: MPV media player, basic office tools
- **Communication**: Discord, email, messaging applications

### System Features
- **Shell**: Zsh with Oh My Zsh, autosuggestions, syntax highlighting
- **Prompt**: Starship with custom prompt showing git status, Python env, etc.
- **Fonts**: Nerd Fonts collection for proper icon rendering
- **Theme**: Consistent theming with good contrast and readability
- **Python Aliases**: Modern uv-based workflow (uvi, uvs, uvx commands)
- **Performance**: Optimized settings for development workloads

## 🛡️ Security Philosophy

This configuration follows a **"security without bloat"** approach:

- **Essential Protection**: Basic firewall, sudo hardening, key kernel settings
- **No Over-Engineering**: Removed complex systems like AppArmor, Fail2ban, ClamAV
- **Practical Security**: Focus on protections that matter for development workstations
- **Maintainable**: Simple configurations that are easy to understand and modify
- **Performance**: Security measures that don't impact development workflow

## 🎨 Customization

### Enabling/Disabling Modules

The configuration uses a modular approach. Enable or disable features in your host configuration:

```nix
myModules = {
  development = {
    enable = true;
    languages = [ "python" "go" "javascript" "nix" ];
    editors = [ "neovim" ];
    python = {
      enable = true;
      packageManager = "uv";  # Fast Python package management
    };
  };
  
  system = {
    security.enable = true;          # Basic security without bloat
    monitoring.enable = true;        # System health monitoring
    maintenance.enable = true;       # Automated maintenance
  };
  
  desktop = {
    enable = true;
    hyprland.enable = true;         # Wayland compositor
    applications.enable = true;      # Essential desktop apps
  };
};
```

### Adding New Hosts

1. Create a new directory in `hosts/`
2. Add `configuration.nix` and `hardware-configuration.nix`
3. Update `flake.nix` with the new host entry
4. Build with `nixos-rebuild switch --flake .#new-host`

## 🔄 Recent Changes & Philosophy

This configuration has been recently **streamlined and simplified**:

### What Was Removed (Bloat Reduction)
- **Rust support** - Removed language tooling, packages, and VS Code extensions
- **Complex security** - Removed AppArmor, Fail2ban, ClamAV, extensive audit systems
- **Over-engineered maintenance** - Simplified from complex backup/migration scripts
- **Redundant configurations** - Fixed duplicate packages and conflicting settings

### What Was Enhanced
- **Python development** - Full uv integration with modern workflow aliases
- **Essential security** - Kept only practical protections that matter
- **System monitoring** - Clean health checks and performance optimization
- **Modular design** - Better separation of concerns and easier customization

### Design Philosophy
- **Practical over Perfect** - Focus on daily development needs
- **Simple over Complex** - Avoid unnecessary abstraction and bloat
- **Maintainable over Feature-Rich** - Easier to understand and modify
- **Performance over Completeness** - Fast rebuilds and responsive system

## 🤝 Contributing

Contributions are welcome! This configuration prioritizes:
- **Simplicity** - Easy to understand and modify
- **Modularity** - Clean separation of components
- **Documentation** - Clear code with explanations  
- **Practicality** - Real-world development focused
- **Performance** - Fast rebuilds and system responsiveness

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Test changes in a VM or non-production system
4. Ensure changes follow the simplicity philosophy
5. Update documentation as needed
6. Submit a pull request with clear description

## 💡 Tips & Best Practices

### First-Time Setup
1. **Start Small** - Enable only essential modules initially
2. **Test Incrementally** - Add features one at a time
3. **Backup First** - Always have a rollback plan ready
4. **Read the Code** - Understand what each module does

### Development Workflow
```bash
# Quick rebuild and switch
rebuild

# Check system health
system-info

# Clean up after major changes
cleanup

# Check for issues before committing changes
nix flake check
```

### Customization Examples
```bash
# Enable Python development with specific tools
myModules.development.python = {
  enable = true;
  packages = [ "pytest" "mypy" "black" ];
};

# Add custom security settings
myModules.system.security = {
  enable = true;
  firewall.allowedTCPPorts = [ 8080 3000 ];
};

# Customize desktop applications
myModules.desktop.applications = {
  enable = true;
  categories = [ "development" "media" "office" ];
};
```

## 📚 Resources & Documentation

### Essential NixOS Resources
- [NixOS Manual](https://nixos.org/manual/nixos/stable/) - Official documentation
- [Nix Flakes Guide](https://nixos.wiki/wiki/Flakes) - Modern Nix configuration  
- [NixOS Options Search](https://search.nixos.org/options) - Find configuration options
- [Nix Packages Search](https://search.nixos.org/packages) - Browse available packages

### Development & Tools
- [Home Manager](https://github.com/nix-community/home-manager) - User environment management
- [NixOS Hardware](https://github.com/NixOS/nixos-hardware) - Hardware-specific configurations
- [DevShells](https://nixos.wiki/wiki/Development_environment_with_nix-shell) - Development environments

### This Configuration
- **CLEANUP_SUMMARY.md** - Detailed log of recent simplification changes
- **DOTFILES.md** - Dotfiles integration and management guide
- Module comments - Each module is documented with usage examples

## 🔧 Troubleshooting

### Common Issues

**Build Failures:**
```bash
# Check for syntax errors
nix flake check

# Update flake inputs
nix flake update

# Clear cache if corrupted
sudo rm -rf /nix/var/nix/profiles/system-*-link
```

**System Issues:**
```bash
# Check system status
system-info

# View recent logs
journalctl -xe

# Rollback to previous generation
sudo nixos-rebuild switch --rollback
```

**Development Environment:**
```bash
# Rebuild neovim configuration
nvim --headless +qa

# Fix Python uv installation
uv self update

# Check Docker permissions
sudo usermod -aG docker $USER
```

## 📄 License

This configuration is available under the MIT License. Feel free to use, modify, and share!

## 🙏 Acknowledgments

- The NixOS community for excellent documentation and packages
- Contributors to nixos-hardware for device-specific configurations
- The Hyprland project for an amazing Wayland compositor
- All the open source projects that make this configuration possible

---

**Note**: This is a personal configuration optimized for development workstations. Review and customize the security settings, package selections, and configurations before using in production environments.
