{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myModules.system.dotfiles;
in {
  options.myModules.system.dotfiles = {
    enable = mkEnableOption "GNU Stow dotfiles management";
    
    repository = mkOption {
      type = types.str;
      default = "/home/carlos/.kr_flake/.dotfiles";
      description = "Path to the dotfiles repository";
    };
    
    packages = mkOption {
      type = types.listOf types.str;
      default = [ "zsh" "git" "hyprland" "kitty" "waybar" "wofi" ];
      description = "List of stow packages to manage";
    };
    
    autoStow = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically stow packages on system activation";
    };
    
    backupExisting = mkOption {
      type = types.bool;
      default = true;
      description = "Backup existing dotfiles before stowing";
    };
    
    gitConfig = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable git configuration for dotfiles repository";
      };
      
      userName = mkOption {
        type = types.str;
        default = "K4rlosReyes";
        description = "Git user name for commits";
      };
      
      userEmail = mkOption {
        type = types.str;
        default = "carlosreyesml18@gmail.com";
        description = "Git user email for commits";
      };
    };
  };

  config = mkIf cfg.enable {
    # Install GNU Stow and related tools
    environment.systemPackages = with pkgs; [
      stow
      git
      
      # Dotfiles management scripts
      (writeShellScriptBin "dotfiles-init" ''
        #!/bin/bash
        set -euo pipefail
        
        DOTFILES_DIR="${cfg.repository}"
        BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
        
        echo "🏠 Initializing dotfiles repository at $DOTFILES_DIR"
        
        # Create dotfiles directory if it doesn't exist
        if [ ! -d "$DOTFILES_DIR" ]; then
          echo "📂 Creating dotfiles directory..."
          mkdir -p "$DOTFILES_DIR"
          cd "$DOTFILES_DIR"
          
          # Initialize git repository
          ${optionalString cfg.gitConfig.enable ''
            git init
            git config user.name "${cfg.gitConfig.userName}"
            git config user.email "${cfg.gitConfig.userEmail}"
            
            # Create initial README
            cat > README.md << 'EOF'
        # Dotfiles

        Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

        ## Usage

        ```bash
        # Stow all packages
        dotfiles-stow-all

        # Stow specific package
        stow zsh

        # Unstow package
        stow -D zsh

        # List available packages
        dotfiles-list

        # Backup current dotfiles
        dotfiles-backup
        ```

        ## Structure

        Each directory represents a "package" that contains configuration files in their expected directory structure relative to $HOME.

        Example:
        ```
        zsh/
          .zshrc
          .zsh/
            aliases.zsh
            functions.zsh
        ```

        ## Packages

        ${concatStringsSep "\n" (map (pkg: "- ${pkg}") cfg.packages)}
        EOF
            
            git add README.md
            git commit -m "Initial commit: Add README"
          ''}
          
          echo "✅ Dotfiles repository initialized!"
        else
          echo "📁 Dotfiles directory already exists at $DOTFILES_DIR"
        fi
        
        # Create package directories
        cd "$DOTFILES_DIR"
        ${concatStringsSep "\n" (map (pkg: ''
          if [ ! -d "${pkg}" ]; then
            echo "📦 Creating package directory: ${pkg}"
            mkdir -p "${pkg}"
          fi
        '') cfg.packages)}
        
        echo "🎉 Dotfiles initialization complete!"
        echo "📍 Repository location: $DOTFILES_DIR"
        echo "🔧 Run 'dotfiles-stow-all' to stow all packages"
      '')
      
      (writeShellScriptBin "dotfiles-stow-all" ''
        #!/bin/bash
        set -euo pipefail
        
        DOTFILES_DIR="${cfg.repository}"
        
        if [ ! -d "$DOTFILES_DIR" ]; then
          echo "❌ Dotfiles directory not found: $DOTFILES_DIR"
          echo "💡 Run 'dotfiles-init' first"
          exit 1
        fi
        
        cd "$DOTFILES_DIR"
        
        ${optionalString cfg.backupExisting ''
          # Backup existing dotfiles
          dotfiles-backup
        ''}
        
        echo "🔗 Stowing all packages..."
        ${concatStringsSep "\n" (map (pkg: ''
          if [ -d "${pkg}" ]; then
            echo "📦 Stowing ${pkg}..."
            stow --target="$HOME" "${pkg}" || echo "⚠️  Warning: Could not stow ${pkg}"
          fi
        '') cfg.packages)}
        
        echo "✅ All packages stowed successfully!"
      '')
      
      (writeShellScriptBin "dotfiles-unstow-all" ''
        #!/bin/bash
        set -euo pipefail
        
        DOTFILES_DIR="${cfg.repository}"
        
        if [ ! -d "$DOTFILES_DIR" ]; then
          echo "❌ Dotfiles directory not found: $DOTFILES_DIR"
          exit 1
        fi
        
        cd "$DOTFILES_DIR"
        
        echo "🔗 Unstowing all packages..."
        ${concatStringsSep "\n" (map (pkg: ''
          if [ -d "${pkg}" ]; then
            echo "📦 Unstowing ${pkg}..."
            stow --target="$HOME" -D "${pkg}" || echo "⚠️  Warning: Could not unstow ${pkg}"
          fi
        '') cfg.packages)}
        
        echo "✅ All packages unstowed successfully!"
      '')
      
      (writeShellScriptBin "dotfiles-backup" ''
        #!/bin/bash
        set -euo pipefail
        
        BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
        DOTFILES_DIR="${cfg.repository}"
        
        echo "💾 Creating backup at $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        
        # Backup files that would conflict with stow
        cd "$DOTFILES_DIR"
        ${concatStringsSep "\n" (map (pkg: ''
          if [ -d "${pkg}" ]; then
            echo "🔍 Checking conflicts for ${pkg}..."
            find "${pkg}" -type f | while read -r file; do
              target_file="$HOME/''${file#${pkg}/}"
              if [ -f "$target_file" ] && [ ! -L "$target_file" ]; then
                echo "💾 Backing up: $target_file"
                target_dir="$BACKUP_DIR/$(dirname "''${file#${pkg}/}")"
                mkdir -p "$target_dir"
                cp "$target_file" "$BACKUP_DIR/''${file#${pkg}/}"
              fi
            done
          fi
        '') cfg.packages)}
        
        if [ "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
          echo "✅ Backup created at: $BACKUP_DIR"
        else
          echo "ℹ️  No files needed backup"
          rmdir "$BACKUP_DIR"
        fi
      '')
      
      (writeShellScriptBin "dotfiles-list" ''
        #!/bin/bash
        
        DOTFILES_DIR="${cfg.repository}"
        
        if [ ! -d "$DOTFILES_DIR" ]; then
          echo "❌ Dotfiles directory not found: $DOTFILES_DIR"
          echo "💡 Run 'dotfiles-init' first"
          exit 1
        fi
        
        cd "$DOTFILES_DIR"
        
        echo "📦 Available packages:"
        for dir in */; do
          if [ -d "$dir" ]; then
            pkg="''${dir%/}"
            echo "  - $pkg"
            
            # Check if stowed
            if stow --target="$HOME" -n "$pkg" 2>/dev/null >/dev/null; then
              echo "    ✅ Currently stowed"
            else
              echo "    ❌ Not stowed"
            fi
          fi
        done
      '')
      
      (writeShellScriptBin "dotfiles-add" ''
        #!/bin/bash
        set -euo pipefail
        
        if [ $# -eq 0 ]; then
          echo "Usage: dotfiles-add <file-path> <package>"
          echo "Example: dotfiles-add ~/.zshrc zsh"
          exit 1
        fi
        
        FILE_PATH="$1"
        PACKAGE="''${2:-$(basename "$FILE_PATH" | sed 's/^\.//')}"
        DOTFILES_DIR="${cfg.repository}"
        
        if [ ! -f "$FILE_PATH" ]; then
          echo "❌ File not found: $FILE_PATH"
          exit 1
        fi
        
        # Resolve absolute path
        FILE_PATH="$(realpath "$FILE_PATH")"
        
        # Calculate relative path from HOME
        REL_PATH="''${FILE_PATH#$HOME/}"
        
        if [ "$REL_PATH" = "$FILE_PATH" ]; then
          echo "❌ File must be in home directory"
          exit 1
        fi
        
        TARGET_DIR="$DOTFILES_DIR/$PACKAGE/$(dirname "$REL_PATH")"
        TARGET_FILE="$DOTFILES_DIR/$PACKAGE/$REL_PATH"
        
        echo "📁 Adding $FILE_PATH to package '$PACKAGE'"
        
        # Create directory structure
        mkdir -p "$TARGET_DIR"
        
        # Move file to dotfiles and create symlink
        mv "$FILE_PATH" "$TARGET_FILE"
        ln -s "$TARGET_FILE" "$FILE_PATH"
        
        echo "✅ File added to dotfiles!"
        echo "📁 Location: $TARGET_FILE"
        
        # Git add if in git repository
        cd "$DOTFILES_DIR"
        if git rev-parse --git-dir > /dev/null 2>&1; then
          git add "$TARGET_FILE"
          echo "📝 File staged for commit"
        fi
      '')
      
      (writeShellScriptBin "dotfiles-sync" ''
        #!/bin/bash
        set -euo pipefail
        
        DOTFILES_DIR="${cfg.repository}"
        
        if [ ! -d "$DOTFILES_DIR" ]; then
          echo "❌ Dotfiles directory not found: $DOTFILES_DIR"
          exit 1
        fi
        
        cd "$DOTFILES_DIR"
        
        if ! git rev-parse --git-dir > /dev/null 2>&1; then
          echo "❌ Not a git repository"
          exit 1
        fi
        
        echo "🔄 Syncing dotfiles..."
        
        # Check for changes
        if [ -n "$(git status --porcelain)" ]; then
          echo "📝 Changes detected, committing..."
          git add .
          git commit -m "Auto-sync: $(date)"
        fi
        
        # Pull and push if remote exists
        if git remote | grep -q origin; then
          echo "⬇️  Pulling from remote..."
          git pull origin main || git pull origin master || true
          
          echo "⬆️  Pushing to remote..."
          git push origin main || git push origin master || true
        fi
        
        echo "✅ Dotfiles synced!"
      '')
    ];

    # Auto-stow on system activation
    system.activationScripts.dotfiles = mkIf cfg.autoStow {
      text = ''
        if [ -d "${cfg.repository}" ]; then
          echo "🔗 Auto-stowing dotfiles..."
          cd "${cfg.repository}"
          ${concatStringsSep "\n" (map (pkg: ''
            if [ -d "${pkg}" ]; then
              ${pkgs.stow}/bin/stow --target="/home/carlos" "${pkg}" 2>/dev/null || true
            fi
          '') cfg.packages)}
        fi
      '';
      deps = [ "users" ];
    };

    # Create dotfiles directory structure
    systemd.tmpfiles.rules = [
      "d ${cfg.repository} 0755 carlos users -"
    ] ++ (map (pkg: "d ${cfg.repository}/${pkg} 0755 carlos users -") cfg.packages);

    # Create example configurations
    environment.etc = mkMerge [
      {
        "dotfiles-templates/zsh/.zshrc".text = ''
          # Zsh configuration managed by dotfiles
          
          # Oh My Zsh configuration
          export ZSH="$HOME/.oh-my-zsh"
          ZSH_THEME="robbyrussell"
          plugins=(git sudo docker history)
          source $ZSH/oh-my-zsh.sh
          
          # Custom aliases
          [ -f ~/.zsh/aliases.zsh ] && source ~/.zsh/aliases.zsh
          
          # Custom functions
          [ -f ~/.zsh/functions.zsh ] && source ~/.zsh/functions.zsh
          
          # Starship prompt
          eval "$(starship init zsh)"
        '';
        
        "dotfiles-templates/zsh/.zsh/aliases.zsh".text = ''
          # Custom aliases
          alias ll='ls -alF'
          alias la='ls -A'
          alias l='ls -CF'
          alias grep='grep --color=auto'
          alias fgrep='fgrep --color=auto'
          alias egrep='egrep --color=auto'
          
          # NixOS specific
          alias nrs='sudo nixos-rebuild switch --flake /home/carlos/.kr_flake'
          alias nrt='sudo nixos-rebuild test --flake /home/carlos/.kr_flake'
          alias nrb='sudo nixos-rebuild boot --flake /home/carlos/.kr_flake'
          alias nfu='nix flake update /home/carlos/.kr_flake'
          
          # Git aliases
          alias gs='git status'
          alias ga='git add'
          alias gc='git commit'
          alias gp='git push'
          alias gl='git log --oneline'
          
          # Dotfiles management
          alias df-init='dotfiles-init'
          alias df-stow='dotfiles-stow-all'
          alias df-unstow='dotfiles-unstow-all'
          alias df-list='dotfiles-list'
          alias df-sync='dotfiles-sync'
        '';
        
        "dotfiles-templates/git/.gitconfig".text = ''
          [user]
              name = ${cfg.gitConfig.userName}
              email = ${cfg.gitConfig.userEmail}
          
          [core]
              editor = nvim
              autocrlf = input
          
          [pull]
              rebase = false
          
          [push]
              default = simple
          
          [alias]
              st = status
              co = checkout
              br = branch
              ci = commit
              unstage = reset HEAD --
              last = log -1 HEAD
              visual = !gitk
              graph = log --graph --oneline --decorate --all
          
          [color]
              ui = auto
        '';
        
        "dotfiles-templates/hyprland/.config/hypr/hyprland.conf".text = ''
          # Hyprland configuration
          # Managed by dotfiles
          
          # Monitor configuration
          monitor=,preferred,auto,auto
          
          # Input configuration
          input {
              kb_layout = us
              kb_variant =
              kb_model =
              kb_options =
              kb_rules =
              
              follow_mouse = 1
              
              touchpad {
                  natural_scroll = no
              }
              
              sensitivity = 0
          }
          
          # General settings
          general {
              gaps_in = 5
              gaps_out = 20
              border_size = 2
              col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
              col.inactive_border = rgba(595959aa)
              
              layout = dwindle
          }
          
          # Window decorations
          decoration {
              rounding = 10
              blur = yes
              blur_size = 3
              blur_passes = 1
              blur_new_optimizations = on
              
              drop_shadow = yes
              shadow_range = 4
              shadow_render_power = 3
              col.shadow = rgba(1a1a1aee)
          }
          
          # Animations
          animations {
              enabled = yes
              
              bezier = myBezier, 0.05, 0.9, 0.1, 1.05
              
              animation = windows, 1, 7, myBezier
              animation = windowsOut, 1, 7, default, popin 80%
              animation = border, 1, 10, default
              animation = borderangle, 1, 8, default
              animation = fade, 1, 7, default
              animation = workspaces, 1, 6, default
          }
          
          # Dwindle layout
          dwindle {
              pseudotile = yes
              preserve_split = yes
          }
          
          # Window rules
          windowrule = float, ^(kitty)$
          
          # Key bindings
          $mainMod = SUPER
          
          bind = $mainMod, Q, exec, kitty
          bind = $mainMod, C, killactive,
          bind = $mainMod, M, exit,
          bind = $mainMod, E, exec, thunar
          bind = $mainMod, V, togglefloating,
          bind = $mainMod, R, exec, wofi --show drun
          bind = $mainMod, P, pseudo,
          bind = $mainMod, J, togglesplit,
          
          # Move focus
          bind = $mainMod, left, movefocus, l
          bind = $mainMod, right, movefocus, r
          bind = $mainMod, up, movefocus, u
          bind = $mainMod, down, movefocus, d
          
          # Switch workspaces
          bind = $mainMod, 1, workspace, 1
          bind = $mainMod, 2, workspace, 2
          bind = $mainMod, 3, workspace, 3
          bind = $mainMod, 4, workspace, 4
          bind = $mainMod, 5, workspace, 5
          bind = $mainMod, 6, workspace, 6
          bind = $mainMod, 7, workspace, 7
          bind = $mainMod, 8, workspace, 8
          bind = $mainMod, 9, workspace, 9
          bind = $mainMod, 0, workspace, 10
          
          # Move window to workspace
          bind = $mainMod SHIFT, 1, movetoworkspace, 1
          bind = $mainMod SHIFT, 2, movetoworkspace, 2
          bind = $mainMod SHIFT, 3, movetoworkspace, 3
          bind = $mainMod SHIFT, 4, movetoworkspace, 4
          bind = $mainMod SHIFT, 5, movetoworkspace, 5
          bind = $mainMod SHIFT, 6, movetoworkspace, 6
          bind = $mainMod SHIFT, 7, movetoworkspace, 7
          bind = $mainMod SHIFT, 8, movetoworkspace, 8
          bind = $mainMod SHIFT, 9, movetoworkspace, 9
          bind = $mainMod SHIFT, 0, movetoworkspace, 10
          
          # Scroll through workspaces
          bind = $mainMod, mouse_down, workspace, e+1
          bind = $mainMod, mouse_up, workspace, e-1
          
          # Move/resize windows
          bindm = $mainMod, mouse:272, movewindow
          bindm = $mainMod, mouse:273, resizewindow
        '';
        
        "dotfiles-templates/kitty/.config/kitty/kitty.conf".text = ''
          # Kitty Terminal Configuration
          # Managed by dotfiles
          
          # Font configuration
          font_family      JetBrains Mono Nerd Font
          bold_font        auto
          italic_font      auto
          bold_italic_font auto
          font_size        12.0
          
          # Cursor
          cursor_shape block
          cursor_blink_interval 0
          
          # Colors (Catppuccin Mocha)
          foreground              #CDD6F4
          background              #1E1E2E
          selection_foreground    #1E1E2E
          selection_background    #F5E0DC
          
          # Black
          color0 #45475A
          color8 #585B70
          
          # Red
          color1 #F38BA8
          color9 #F38BA8
          
          # Green
          color2  #A6E3A1
          color10 #A6E3A1
          
          # Yellow
          color3  #F9E2AF
          color11 #F9E2AF
          
          # Blue
          color4  #89B4FA
          color12 #89B4FA
          
          # Magenta
          color5  #F5C2E7
          color13 #F5C2E7
          
          # Cyan
          color6  #94E2D5
          color14 #94E2D5
          
          # White
          color7  #BAC2DE
          color15 #A6ADC8
          
          # Window
          window_padding_width 10
          window_border_width 1
          draw_minimal_borders yes
          
          # Tab bar
          tab_bar_edge top
          tab_bar_style powerline
          tab_powerline_style slanted
          
          # Performance
          repaint_delay 10
          input_delay 3
          sync_to_monitor yes
          
          # Bell
          enable_audio_bell no
          
          # URLs
          url_color #89B4FA
          url_style curly
          
          # Key mappings
          map ctrl+shift+c copy_to_clipboard
          map ctrl+shift+v paste_from_clipboard
          map ctrl+shift+t new_tab
          map ctrl+shift+w close_tab
          map ctrl+shift+enter new_window
          map ctrl+shift+q close_window
        '';
        
        "dotfiles-templates/waybar/.config/waybar/config".text = ''
          {
              "layer": "top",
              "position": "top",
              "height": 30,
              "spacing": 4,
              
              "modules-left": ["hyprland/workspaces"],
              "modules-center": ["hyprland/window"],
              "modules-right": ["network", "pulseaudio", "battery", "clock", "tray"],
              
              "hyprland/workspaces": {
                  "disable-scroll": true,
                  "all-outputs": true,
                  "format": "{icon}",
                  "format-icons": {
                      "1": "",
                      "2": "",
                      "3": "",
                      "4": "",
                      "5": "",
                      "urgent": "",
                      "focused": "",
                      "default": ""
                  }
              },
              
              "hyprland/window": {
                  "format": "{}",
                  "max-length": 50
              },
              
              "tray": {
                  "spacing": 10
              },
              
              "clock": {
                  "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
                  "format-alt": "{:%Y-%m-%d}"
              },
              
              "battery": {
                  "states": {
                      "warning": 30,
                      "critical": 15
                  },
                  "format": "{capacity}% {icon}",
                  "format-charging": "{capacity}% ",
                  "format-plugged": "{capacity}% ",
                  "format-alt": "{time} {icon}",
                  "format-icons": ["", "", "", "", ""]
              },
              
              "network": {
                  "format-wifi": "{essid} ({signalStrength}%) ",
                  "format-ethernet": "{ipaddr}/{cidr} ",
                  "tooltip-format": "{ifname} via {gwaddr} ",
                  "format-linked": "{ifname} (No IP) ",
                  "format-disconnected": "Disconnected ⚠",
                  "format-alt": "{ifname}: {ipaddr}/{cidr}"
              },
              
              "pulseaudio": {
                  "format": "{volume}% {icon} {format_source}",
                  "format-bluetooth": "{volume}% {icon} {format_source}",
                  "format-bluetooth-muted": " {icon} {format_source}",
                  "format-muted": " {format_source}",
                  "format-source": "{volume}% ",
                  "format-source-muted": "",
                  "format-icons": {
                      "headphone": "",
                      "hands-free": "",
                      "headset": "",
                      "phone": "",
                      "portable": "",
                      "car": "",
                      "default": ["", "", ""]
                  },
                  "on-click": "pavucontrol"
              }
          }
        '';
        
        "dotfiles-templates/waybar/.config/waybar/style.css".text = ''
          * {
              border: none;
              border-radius: 0;
              font-family: "JetBrains Mono Nerd Font";
              font-size: 13px;
              min-height: 0;
          }
          
          window#waybar {
              background-color: rgba(30, 30, 46, 0.9);
              color: #cdd6f4;
              transition-property: background-color;
              transition-duration: .5s;
          }
          
          window#waybar.hidden {
              opacity: 0.2;
          }
          
          #workspaces button {
              padding: 0 5px;
              background-color: transparent;
              color: #cdd6f4;
              border-bottom: 3px solid transparent;
          }
          
          #workspaces button:hover {
              background: rgba(0, 0, 0, 0.2);
          }
          
          #workspaces button.focused {
              background-color: #64748b;
              border-bottom: 3px solid #cdd6f4;
          }
          
          #workspaces button.urgent {
              background-color: #f38ba8;
          }
          
          #mode {
              background-color: #64748b;
              border-bottom: 3px solid #cdd6f4;
          }
          
          #clock,
          #battery,
          #cpu,
          #memory,
          #disk,
          #temperature,
          #backlight,
          #network,
          #pulseaudio,
          #tray,
          #mode,
          #idle_inhibitor,
          #mpd {
              padding: 0 10px;
              color: #cdd6f4;
          }
          
          #window,
          #workspaces {
              margin: 0 4px;
          }
          
          .modules-left > widget:first-child > #workspaces {
              margin-left: 0;
          }
          
          .modules-right > widget:last-child > #workspaces {
              margin-right: 0;
          }
          
          #clock {
              background-color: #74c7ec;
              color: #1e1e2e;
          }
          
          #battery {
              background-color: #a6e3a1;
              color: #1e1e2e;
          }
          
          #battery.charging, #battery.plugged {
              color: #1e1e2e;
              background-color: #a6e3a1;
          }
          
          @keyframes blink {
              to {
                  background-color: #f38ba8;
                  color: #1e1e2e;
              }
          }
          
          #battery.critical:not(.charging) {
              background-color: #f38ba8;
              color: #1e1e2e;
              animation-name: blink;
              animation-duration: 0.5s;
              animation-timing-function: linear;
              animation-iteration-count: infinite;
              animation-direction: alternate;
          }
          
          label:focus {
              background-color: #1e1e2e;
          }
          
          #network {
              background-color: #fab387;
              color: #1e1e2e;
          }
          
          #network.disconnected {
              background-color: #f38ba8;
          }
          
          #pulseaudio {
              background-color: #f9e2af;
              color: #1e1e2e;
          }
          
          #pulseaudio.muted {
              background-color: #585b70;
              color: #cdd6f4;
          }
          
          #tray {
              background-color: #cba6f7;
              color: #1e1e2e;
          }
          
          #tray > .passive {
              -gtk-icon-effect: dim;
          }
          
          #tray > .needs-attention {
              -gtk-icon-effect: highlight;
              background-color: #f38ba8;
          }
        '';
        
        "dotfiles-templates/wofi/.config/wofi/config".text = ''
          width=600
          height=400
          location=center
          show=drun
          prompt=Search...
          filter_rate=100
          allow_markup=true
          no_actions=true
          halign=fill
          orientation=vertical
          content_halign=fill
          insensitive=true
          allow_images=true
          image_size=40
          gtk_dark=true
          hide_scroll=true
        '';
        
        "dotfiles-templates/wofi/.config/wofi/style.css".text = ''
          window {
              margin: 0px;
              border: 1px solid #cba6f7;
              background-color: rgba(30, 30, 46, 0.9);
              border-radius: 10px;
          }
          
          #input {
              margin: 5px;
              border: none;
              color: #cdd6f4;
              background-color: #45475a;
              border-radius: 5px;
              padding: 10px;
              font-size: 14px;
          }
          
          #inner-box {
              margin: 5px;
              border: none;
              background-color: transparent;
          }
          
          #outer-box {
              margin: 5px;
              border: none;
              background-color: transparent;
          }
          
          #scroll {
              margin: 0px;
              border: none;
          }
          
          #text {
              margin: 5px;
              border: none;
              color: #cdd6f4;
          }
          
          #entry {
              margin: 5px;
              border: none;
              border-radius: 5px;
              background-color: transparent;
          }
          
          #entry:selected {
              background-color: #585b70;
          }
          
          #entry:selected #text {
              color: #f5e0dc;
          }
        '';
        
        "dotfiles-templates/nvim/.config/nvim/init.lua".text = ''
          -- Neovim Configuration
          -- Managed by dotfiles
          
          -- Basic settings
          vim.opt.number = true
          vim.opt.relativenumber = true
          vim.opt.tabstop = 2
          vim.opt.shiftwidth = 2
          vim.opt.expandtab = true
          vim.opt.smartindent = true
          vim.opt.wrap = false
          vim.opt.swapfile = false
          vim.opt.backup = false
          vim.opt.undofile = true
          vim.opt.hlsearch = false
          vim.opt.incsearch = true
          vim.opt.termguicolors = true
          vim.opt.scrolloff = 8
          vim.opt.signcolumn = "yes"
          vim.opt.isfname:append("@-@")
          vim.opt.updatetime = 50
          vim.opt.colorcolumn = "80"
          
          -- Leader key
          vim.g.mapleader = " "
          
          -- Key mappings
          vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
          vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
          vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
          vim.keymap.set("n", "J", "mzJ`z")
          vim.keymap.set("n", "<C-d>", "<C-d>zz")
          vim.keymap.set("n", "<C-u>", "<C-u>zz")
          vim.keymap.set("n", "n", "nzzzv")
          vim.keymap.set("n", "N", "Nzzzv")
          
          -- Copy to system clipboard
          vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
          vim.keymap.set("n", "<leader>Y", [["+Y]])
          
          -- Delete without yanking
          vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])
          
          -- Replace word under cursor
          vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
          
          -- Make file executable
          vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
          
          -- Source current file
          vim.keymap.set("n", "<leader><leader>", function()
              vim.cmd("so")
          end)
          
          -- Colorscheme (catppuccin if available, otherwise default)
          vim.cmd.colorscheme("default")
          
          -- Auto commands
          local augroup = vim.api.nvim_create_augroup
          local autocmd = vim.api.nvim_create_autocmd
          
          -- Highlight on yank
          augroup("YankHighlight", { clear = true })
          autocmd("TextYankPost", {
              group = "YankHighlight",
              callback = function()
                  vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
              end,
          })
          
          -- Remove trailing whitespace on save
          augroup("TrimWhitespace", { clear = true })
          autocmd("BufWritePre", {
              group = "TrimWhitespace",
              pattern = "*",
              command = "%s/\\s\\+$//e",
          })
        '';
      }
    ];

    # Enhanced shell aliases for dotfiles management
    programs.zsh.shellAliases = mkIf config.programs.zsh.enable {
      dotfiles-init = "dotfiles-init";
      dotfiles-stow = "dotfiles-stow-all";
      dotfiles-unstow = "dotfiles-unstow-all";
      dotfiles-list = "dotfiles-list";
      dotfiles-sync = "dotfiles-sync";
      dotfiles-add = "dotfiles-add";
      dotfiles-backup = "dotfiles-backup";
      
      # Quick stow commands
      stow-zsh = "cd ${cfg.repository} && stow zsh";
      stow-git = "cd ${cfg.repository} && stow git";
      stow-hyprland = "cd ${cfg.repository} && stow hyprland";
    };
  };
}