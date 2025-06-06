#!/usr/bin/env bash
# Dotfiles management script using GNU Stow
# K4rlosReyes dotfiles

set -e

DOTFILES_DIR="/home/carlos/.kr_flake/.dotfiles"
TARGET_DIR="/home/carlos"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Available packages
PACKAGES=(
    "zsh"
    "git"
    "nvim"
    "kitty"
    "hyprland"
    "waybar"
    "wofi"
    "thunar"
    "gtk"
)

print_usage() {
    echo "Usage: $0 {stow|unstow|restow|list|status|init}"
    echo ""
    echo "Commands:"
    echo "  stow [package]     - Stow a specific package or all packages"
    echo "  unstow [package]   - Unstow a specific package or all packages"
    echo "  restow [package]   - Restow a specific package or all packages"
    echo "  list              - List available packages"
    echo "  status            - Show git status and stow conflicts"
    echo "  init              - Initialize dotfiles repository"
    echo ""
    echo "Available packages: ${PACKAGES[*]}"
}

check_dependencies() {
    if ! command -v stow &> /dev/null; then
        echo -e "${RED}Error: GNU Stow is not installed${NC}"
        exit 1
    fi
    
    if ! command -v git &> /dev/null; then
        echo -e "${RED}Error: Git is not installed${NC}"
        exit 1
    fi
}

backup_existing() {
    local package="$1"
    local backup_dir="/home/carlos/.config-backup-$(date +%Y%m%d-%H%M%S)"
    
    echo -e "${YELLOW}Checking for existing configs to backup...${NC}"
    
    case "$package" in
        "zsh")
            if [[ -f "$HOME/.zshrc" || -f "$HOME/.zprofile" ]]; then
                mkdir -p "$backup_dir"
                [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$backup_dir/"
                [[ -f "$HOME/.zprofile" ]] && cp "$HOME/.zprofile" "$backup_dir/"
                echo -e "${GREEN}Backed up existing zsh configs to $backup_dir${NC}"
            fi
            ;;
        "git")
            if [[ -f "$HOME/.gitconfig" || -f "$HOME/.gitignore_global" ]]; then
                mkdir -p "$backup_dir"
                [[ -f "$HOME/.gitconfig" ]] && cp "$HOME/.gitconfig" "$backup_dir/"
                [[ -f "$HOME/.gitignore_global" ]] && cp "$HOME/.gitignore_global" "$backup_dir/"
                echo -e "${GREEN}Backed up existing git configs to $backup_dir${NC}"
            fi
            ;;
        *)
            if [[ -d "$HOME/.config/$package" ]]; then
                mkdir -p "$backup_dir"
                cp -r "$HOME/.config/$package" "$backup_dir/"
                echo -e "${GREEN}Backed up existing $package config to $backup_dir${NC}"
            fi
            ;;
    esac
}

stow_package() {
    local package="$1"
    
    if [[ ! -d "$DOTFILES_DIR/$package" ]]; then
        echo -e "${RED}Error: Package '$package' not found in $DOTFILES_DIR${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Stowing $package...${NC}"
    
    # Backup existing configs
    backup_existing "$package"
    
    # Stow the package
    cd "$DOTFILES_DIR"
    if stow -t "$TARGET_DIR" "$package" 2>/dev/null; then
        echo -e "${GREEN}✓ Successfully stowed $package${NC}"
    else
        echo -e "${YELLOW}⚠ Warning: $package may have conflicts or is already stowed${NC}"
        # Try to restow instead
        stow -R -t "$TARGET_DIR" "$package" 2>/dev/null || true
    fi
}

unstow_package() {
    local package="$1"
    
    if [[ ! -d "$DOTFILES_DIR/$package" ]]; then
        echo -e "${RED}Error: Package '$package' not found in $DOTFILES_DIR${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Unstowing $package...${NC}"
    cd "$DOTFILES_DIR"
    if stow -D -t "$TARGET_DIR" "$package" 2>/dev/null; then
        echo -e "${GREEN}✓ Successfully unstowed $package${NC}"
    else
        echo -e "${YELLOW}⚠ Warning: $package may not be stowed${NC}"
    fi
}

restow_package() {
    local package="$1"
    
    if [[ ! -d "$DOTFILES_DIR/$package" ]]; then
        echo -e "${RED}Error: Package '$package' not found in $DOTFILES_DIR${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Restowing $package...${NC}"
    cd "$DOTFILES_DIR"
    if stow -R -t "$TARGET_DIR" "$package" 2>/dev/null; then
        echo -e "${GREEN}✓ Successfully restowed $package${NC}"
    else
        echo -e "${RED}✗ Failed to restow $package${NC}"
        return 1
    fi
}

list_packages() {
    echo -e "${BLUE}Available packages:${NC}"
    for package in "${PACKAGES[@]}"; do
        if [[ -d "$DOTFILES_DIR/$package" ]]; then
            echo -e "  ${GREEN}✓${NC} $package"
        else
            echo -e "  ${RED}✗${NC} $package (not found)"
        fi
    done
}

show_status() {
    echo -e "${BLUE}Dotfiles status:${NC}"
    echo ""
    
    # Git status
    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        echo -e "${BLUE}Git status:${NC}"
        cd "$DOTFILES_DIR"
        git status --short
        echo ""
    fi
    
    # Check stow status
    echo -e "${BLUE}Stow status:${NC}"
    for package in "${PACKAGES[@]}"; do
        if [[ -d "$DOTFILES_DIR/$package" ]]; then
            echo -n "  $package: "
            cd "$DOTFILES_DIR"
            if stow -n -t "$TARGET_DIR" "$package" 2>/dev/null; then
                echo -e "${GREEN}ready to stow${NC}"
            else
                echo -e "${YELLOW}conflicts or already stowed${NC}"
            fi
        fi
    done
}

init_dotfiles() {
    echo -e "${BLUE}Initializing dotfiles repository...${NC}"
    
    cd "$DOTFILES_DIR"
    
    # Initialize git if not already done
    if [[ ! -d ".git" ]]; then
        git init
        git config user.name "K4rlosReyes"
        git config user.email "carlosreyesml18@gmail.com"
        
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
        
        git add .
        git commit -m "Initial dotfiles commit"
        echo -e "${GREEN}✓ Initialized git repository${NC}"
    else
        echo -e "${YELLOW}Git repository already exists${NC}"
    fi
    
    # Set ownership
    chown -R carlos:users "$DOTFILES_DIR"
    echo -e "${GREEN}✓ Set proper ownership${NC}"
}

main() {
    check_dependencies
    
    case "${1:-}" in
        "stow")
            if [[ -n "${2:-}" ]]; then
                stow_package "$2"
            else
                for package in "${PACKAGES[@]}"; do
                    if [[ -d "$DOTFILES_DIR/$package" ]]; then
                        stow_package "$package"
                    fi
                done
            fi
            ;;
        "unstow")
            if [[ -n "${2:-}" ]]; then
                unstow_package "$2"
            else
                for package in "${PACKAGES[@]}"; do
                    if [[ -d "$DOTFILES_DIR/$package" ]]; then
                        unstow_package "$package"
                    fi
                done
            fi
            ;;
        "restow")
            if [[ -n "${2:-}" ]]; then
                restow_package "$2"
            else
                for package in "${PACKAGES[@]}"; do
                    if [[ -d "$DOTFILES_DIR/$package" ]]; then
                        restow_package "$package"
                    fi
                done
            fi
            ;;
        "list")
            list_packages
            ;;
        "status")
            show_status
            ;;
        "init")
            init_dotfiles
            ;;
        *)
            print_usage
            exit 1
            ;;
    esac
}

main "$@"
