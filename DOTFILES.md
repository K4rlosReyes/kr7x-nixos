# GNU Stow Dotfiles Management

This repository uses GNU Stow for managing dotfiles alongside the NixOS configuration. The approach separates concerns: NixOS handles system-level package installation and configuration, while GNU Stow manages user-level dotfiles with real configuration files in their native formats.

## Features

- 🔧 **Native configuration files** in their proper formats (Lua for Neovim, shell scripts for Zsh, etc.)
- 💾 **Backup existing configurations** before stowing
- 📦 **Modular organization** with separate directories for each application
- 🔄 **Git integration** for version control and syncing
- 🛠️ **Management script** for easy dotfiles operations
- 🏗️ **Separation of concerns** - NixOS for system, Stow for user configs

## Directory Structure

```
.dotfiles/
├── manage-dotfiles.sh    # Management script
├── git/
│   ├── .gitconfig
│   └── .gitignore_global
├── hyprland/
│   └── .config/hypr/
│       └── hyprland.conf
├── kitty/
│   └── .config/kitty/
│       └── kitty.conf
├── nvim/
│   └── .config/nvim/
│       └── init.lua
├── waybar/
│   └── .config/waybar/
│       ├── config
│       └── style.css
├── wofi/
│   └── .config/wofi/
│       ├── config
│       └── style.css
└── zsh/
    ├── .zshrc
    └── .zprofile
```

Each application has its own directory with the actual configuration files.

## Quick Start

1. **Run the setup script**:
   ```bash
   cd ~/.kr_flake
   ./setup-dotfiles.sh
   ```

2. **Or manually navigate to the dotfiles directory**:
   ```bash
   cd ~/.kr_flake/.dotfiles
   ```

3. **Use the management script** to stow configurations:
   ```bash
   ./manage-dotfiles.sh stow zsh
   # or stow all at once (be careful of conflicts)
   ./setup-dotfiles.sh
   ```

4. **Check which packages are stowed**:
   ```bash
   ./manage-dotfiles.sh list
   ```

5. **Check status**:
   ```bash
   ./manage-dotfiles.sh status
   ```

4. **Start customizing your configurations**:
   ```bash
   # Edit configurations directly in their native formats
   nvim ~/.kr_flake/.dotfiles/nvim/.config/nvim/init.lua
   nvim ~/.kr_flake/.dotfiles/zsh/.zshrc
   ```

## Management Script

The `manage-dotfiles.sh` script provides easy management of your dotfiles:

```bash
# Stow all packages
./manage-dotfiles.sh stow-all

# Stow specific packages
./manage-dotfiles.sh stow nvim zsh

# Unstow all packages  
./manage-dotfiles.sh unstow-all

# List package status
./manage-dotfiles.sh list

# Backup existing configs
./manage-dotfiles.sh backup

# Git operations
./manage-dotfiles.sh git-sync
```
  
  git = {
    enable = true;
    userName = "K4rlosReyes";
    userEmail = "carlosreyesml18@gmail.com";
    enableDelta = true;
  };
  
## Package Structure

Each package is a directory that mirrors the structure relative to your home directory:

```
~/.kr_flake/.dotfiles/
├── zsh/
│   ├── .zshrc              # Main zsh configuration
│   └── .zprofile          # Zsh profile (exports)
├── git/
│   ├── .gitconfig         # Git configuration
│   └── .gitignore_global  # Global gitignore
├── hyprland/
│   └── .config/
│       └── hypr/
│           └── hyprland.conf    # Hyprland window manager config
├── kitty/
│   └── .config/
│       └── kitty/
│           └── kitty.conf       # Kitty terminal config
├── nvim/
│   └── .config/
│       └── nvim/
│           └── init.lua         # Neovim configuration in Lua
├── waybar/
│   └── .config/
│       └── waybar/
│           ├── config           # Waybar configuration
│           └── style.css        # Waybar styling
└── wofi/
    └── .config/
        └── wofi/
            ├── config           # Wofi launcher config
            └── style.css        # Wofi styling
```

## How It Works

1. **NixOS modules** (in `modules/desktop/`, etc.) handle:
   - Package installation
   - System-level configuration
   - Service enablement

2. **GNU Stow** handles:
   - User-level configuration files
   - Symlink management
   - Per-application dotfiles

3. **Real configuration files** in native formats:
   - Neovim uses `init.lua` (Lua)
   - Zsh uses `.zshrc` (shell script)
   - Hyprland uses `hyprland.conf` (native format)
│   └── .config/
│       └── kitty/
│           └── kitty.conf
└── nvim/
    └── .config/
        └── nvim/
            ├── init.lua
            └── lua/
                └── config/
```

## Available Commands

The modular dotfiles system provides convenient shell aliases and management scripts:

### Quick Aliases
- `dots` - Main dotfiles management command
- `dotfiles` - Navigate to dotfiles directory
- `dots-backup` - Backup existing configurations
- `dots-status` - Show git status of dotfiles
- `dots-sync` - Commit and push changes

### Management Commands
```bash
# Stow individual packages
dots stow zsh
dots stow git
dots stow hyprland

# Unstow packages
dots unstow zsh

# Restow (useful after updates)
dots restow zsh

# Backup existing configs before stowing
dots backup

# Check status and sync
dots status
dots sync
```

### Per-Application Management

Each application module creates its own directory structure when enabled:

```
~/.dotfiles/
├── zsh/           # Zsh configurations
│   ├── .zshrc
│   └── .zprofile
├── git/           # Git configurations  
│   ├── .gitconfig
│   └── .gitignore_global
├── hyprland/      # Hyprland window manager
│   └── .config/hypr/hyprland.conf
├── kitty/         # Kitty terminal
│   └── .config/kitty/kitty.conf
├── waybar/        # Waybar status bar
│   └── .config/waybar/
│       ├── config
│       └── style.css
├── wofi/          # Wofi launcher
│   └── .config/wofi/
│       ├── config
│       └── style.css
└── nvim/          # Neovim editor
    └── .config/nvim/
        └── init.lua
```

## Workflow Examples

### Setting Up the Dotfiles

```bash
# Navigate to dotfiles directory
cd ~/.kr_flake/.dotfiles

# Initialize git repository (if not already done)
git init
git add .
git commit -m "Initial dotfiles setup"

# Stow all configurations
./manage-dotfiles.sh stow-all
```

### Making Changes to Configurations

```bash
# Edit configurations directly in their native formats
nvim ~/.kr_flake/.dotfiles/nvim/.config/nvim/init.lua
nvim ~/.kr_flake/.dotfiles/zsh/.zshrc

# Sync changes with git
cd ~/.kr_flake/.dotfiles
./manage-dotfiles.sh git-sync
```

### Setting Up on a New Machine

```bash
# Clone your dotfiles repository
git clone https://github.com/yourusername/dotfiles.git ~/.kr_flake/.dotfiles

# Stow all packages
cd ~/.kr_flake/.dotfiles
./manage-dotfiles.sh stow-all
```

## Integration with NixOS

### Separation of Concerns

- **NixOS modules** (in `modules/desktop/`, `modules/programs/`, etc.) handle:
  - Package installation via `environment.systemPackages`
  - System services and configuration
  - Hardware-specific settings

- **GNU Stow dotfiles** handle:
  - User-level configuration files
  - Application-specific settings
  - Personal preferences and customizations

### Example: Hyprland Configuration

1. **NixOS module** (`modules/desktop/hyprland.nix`):
   - Installs Hyprland package
   - Enables the window manager service
   - Sets up system-level dependencies

2. **Dotfiles** (`.dotfiles/hyprland/.config/hypr/hyprland.conf`):
   - Personal Hyprland configuration
   - Keybindings and window rules
   - Appearance and behavior settings

## Advanced Usage

### Adding New Application Configurations

1. **Create the package directory structure**:
   ```bash
   mkdir -p ~/.kr_flake/.dotfiles/newapp/.config/newapp
   ```

2. **Add your configuration files**:
   ```bash
   cp ~/.config/newapp/config ~/.kr_flake/.dotfiles/newapp/.config/newapp/
   ```

3. **Stow the new package**:
   ```bash
   cd ~/.kr_flake/.dotfiles
   ./manage-dotfiles.sh stow newapp
   ```

### Managing Package Subsets

```bash
# Stow specific packages only
./manage-dotfiles.sh stow nvim zsh git

# Unstow specific packages
./manage-dotfiles.sh unstow hyprland waybar

# Check what's currently stowed
./manage-dotfiles.sh list
```

### Backup and Recovery

```bash
# Create backup before major changes
./manage-dotfiles.sh backup

# Backups are stored in ~/.dotfiles-backup-YYYY-MM-DD-HHMMSS
```

## Troubleshooting

### Stow Conflicts

If GNU Stow reports conflicts:
1. Backup existing files: `./manage-dotfiles.sh backup`
2. Remove conflicting files from your home directory
3. Try stowing again: `./manage-dotfiles.sh stow-all`

### File Permissions

If you encounter permission issues:
```bash
# Fix ownership of dotfiles
sudo chown -R $USER:users ~/.kr_flake/.dotfiles

# Make management script executable
chmod +x ~/.kr_flake/.dotfiles/manage-dotfiles.sh
```

### Git Repository Issues

```bash
# Initialize git if needed
cd ~/.kr_flake/.dotfiles
git init
git add .
git commit -m "Initial commit"

# Add remote repository
git remote add origin https://github.com/yourusername/dotfiles.git
git push -u origin main
```

## Tips and Best Practices

1. **Keep it simple** - Use native configuration file formats
2. **Separate concerns** - Let NixOS handle system, Stow handle user configs
3. **Version control** - Commit changes regularly
4. **Test first** - Use backups before major changes
5. **Modular approach** - Keep each application's config separate
6. **Documentation** - Comment your configuration files

## Security Considerations

- Store dotfiles in private repositories if they contain sensitive information
- Be careful with shell history and environment variables
- Review configurations before stowing system-wide
- Consider using `git-crypt` for encrypting sensitive files

## Further Reading

- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html)
- [Dotfiles Community](https://dotfiles.github.io/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
