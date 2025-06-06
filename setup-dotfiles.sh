#!/usr/bin/env bash
# Dotfiles Setup and Management Script
# K4rlosReyes NixOS Configuration

set -euo pipefail

DOTFILES_DIR="/home/carlos/.kr_flake/.dotfiles"
USER_EMAIL="carlosreyesml18@gmail.com"

echo "🏠 GNU Stow Dotfiles Setup"
echo "=========================="
echo "📍 Dotfiles location: $DOTFILES_DIR"
echo ""

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "❌ Dotfiles directory not found: $DOTFILES_DIR"
  echo "💡 This script expects dotfiles to be in your flake directory"
  exit 1
fi

cd "$DOTFILES_DIR"

# Step 1: Initialize git repository if not already done
echo "📂 Step 1: Checking git repository..."
if [ ! -d ".git" ]; then
  echo "📝 Initializing git repository..."
  git init
  git config user.name "K4rlosReyes"
  git config user.email "$USER_EMAIL"
  
  # Create .gitignore
  cat > .gitignore << 'EOF'
# Backup files
*.bak
*.backup
*~

# OS files
.DS_Store
Thumbs.db

# Temporary files
*.tmp
*.temp
EOF
  
  echo "✅ Git repository initialized"
else
  echo "✅ Git repository already exists"
fi

# Step 2: Check existing configurations
echo ""
echo "📋 Step 2: Checking current configurations..."

packages=(zsh git hyprland kitty waybar wofi nvim thunar gtk)
for package in "${packages[@]}"; do
  if [ -d "$package" ]; then
    echo "✅ $package - configuration exists"
  else
    echo "❌ $package - missing configuration"
  fi
done

# Step 3: Show current status
echo ""
echo "📋 Step 3: Checking current status..."
./manage-dotfiles.sh status

# Step 4: Stow configurations
echo ""
echo "🔗 Step 4: Stowing configurations..."
echo "Available packages to stow:"
./manage-dotfiles.sh list

echo ""
read -p "Do you want to stow all available packages? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  for package in "${packages[@]}"; do
    if [ -d "$package" ]; then
      echo "🔗 Stowing $package..."
      ./manage-dotfiles.sh stow "$package" || echo "⚠️ Warning: Could not stow $package"
    fi
  done
else
  echo "💡 Run './manage-dotfiles.sh stow <package>' to stow individual packages"
fi

# Step 5: Git commit
echo ""
echo "📝 Step 5: Committing changes..."
if [ -n "$(git status --porcelain)" ]; then
  git add .
  git commit -m "Dotfiles setup: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "✅ Changes committed to git"
else
  echo "ℹ️ No changes to commit"
fi

echo ""
echo "🎉 Dotfiles setup complete!"
echo ""
echo "📍 Dotfiles location: $DOTFILES_DIR"
echo "🔧 Available commands:"
echo "  - ./manage-dotfiles.sh list      # List all packages and their status"
echo "  - ./manage-dotfiles.sh stow <pkg> # Stow a specific package"
echo "  - ./manage-dotfiles.sh unstow <pkg> # Unstow a specific package"
echo "  - ./manage-dotfiles.sh status    # Show git and stow status"
echo ""
echo "🚀 Next steps:"
echo "  1. Customize your configurations in $DOTFILES_DIR"
echo "  2. Add a git remote: cd $DOTFILES_DIR && git remote add origin <your-repo>"
echo "  3. Push to remote: cd $DOTFILES_DIR && git push -u origin main"
echo "  4. On other machines: git clone <your-repo> ~/.kr_flake/.dotfiles"
echo ""
echo "💡 Pro tips:"
echo "  - Edit configs directly in $DOTFILES_DIR - they're symlinked to your home"
echo "  - Use 'git' commands in $DOTFILES_DIR to version control your dotfiles"
echo "  - Run './manage-dotfiles.sh status' to see what needs to be committed"
