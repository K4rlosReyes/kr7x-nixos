{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.dotfiles.nvim;
  dotfilesCfg = config.dotfiles;
    vim.opt.signcolumn = "yes"
    
    -- Key mappings
    vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
    
    -- Diagnostic keymaps
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
    vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
    
    -- Exit terminal mode
    vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
    
    -- Window navigation
    vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
    vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
    vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
    vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
    
    -- File operations
    vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
    vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
    vim.keymap.set("n", "<leader>x", "<cmd>x<CR>", { desc = "Save and quit" })
    
    -- Better up/down
    vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
    vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
    vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
    vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
    
    -- Move lines
    vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
    vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
    
    -- Center cursor when jumping
    vim.keymap.set("n", "<C-d>", "<C-d>zz")
    vim.keymap.set("n", "<C-u>", "<C-u>zz")
    vim.keymap.set("n", "n", "nzzzv")
    vim.keymap.set("n", "N", "Nzzzv")
    
    -- Autocommands
    vim.api.nvim_create_autocmd("TextYankPost", {
      desc = "Highlight when yanking (copying) text",
      group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
      callback = function()
        vim.highlight.on_yank()
      end,
    })
    
    -- Set up colorscheme
    pcall(function()
      vim.cmd.colorscheme "habamax"
    end)
    
    -- Status line
    vim.opt.laststatus = 2
    vim.opt.statusline = "%f %h%m%r%=%-14.(%l,%c%V%) %P"
    
    -- File explorer
    vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
    
    -- Comments
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
      end,
    })
  '';
  
  vimrcTemplate = ''
    " Neovim configuration (compatibility)
    
    " Basic settings
    set number
    set relativenumber
    set mouse=a
    set clipboard=unnamedplus
    set ignorecase
    set smartcase
    set incsearch
    set hlsearch
    set autoindent
    set smartindent
    set tabstop=4
    set softtabstop=4
    set shiftwidth=4
    set expandtab
    set scrolloff=10
    set signcolumn=yes
    set updatetime=250
    set timeoutlen=300
    set splitright
    set splitbelow
    set termguicolors
    set background=dark
    
    " Key mappings
    let mapleader = " "
    
    " Clear search highlighting
    nnoremap <Esc> :nohlsearch<CR>
    
    " Window navigation
    nnoremap <C-h> <C-w><C-h>
    nnoremap <C-l> <C-w><C-l>
    nnoremap <C-j> <C-w><C-j>
    nnoremap <C-k> <C-w><C-k>
    
    " File operations
    nnoremap <leader>w :w<CR>
    nnoremap <leader>q :q<CR>
    nnoremap <leader>x :x<CR>
    
    " Better movement
    nnoremap j gj
    nnoremap k gk
    vnoremap j gj
    vnoremap k gk
    
    " Move lines
    vnoremap J :m '>+1<CR>gv=gv
    vnoremap K :m '<-2<CR>gv=gv
    
    " Center cursor when jumping
    nnoremap <C-d> <C-d>zz
    nnoremap <C-u> <C-u>zz
    nnoremap n nzzzv
    nnoremap N Nzzzv
    
    " File explorer
    nnoremap <leader>pv :Ex<CR>
    
    " Highlight yanked text
    augroup highlight_yank
        autocmd!
        autocmd TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=700}
    augroup END
    
    " Set colorscheme
    silent! colorscheme habamax
  '';

in {
  options.dotfiles.nvim = {
    enable = mkEnableOption "Neovim dotfiles configuration";
    
    useInitLua = mkOption {
      type = types.bool;
      default = true;
      description = "Use init.lua instead of init.vim";
    };
    
    leader = mkOption {
      type = types.str;
      default = " ";
      description = "Leader key for Neovim";
    };
    
    theme = mkOption {
      type = types.str;
      default = "habamax";
      description = "Default colorscheme";
    };
    
    tabSize = mkOption {
      type = types.int;
      default = 4;
      description = "Tab size for indentation";
    };
    
    enableRelativeNumbers = mkOption {
      type = types.bool;
      default = true;
      description = "Enable relative line numbers";
    };
    
    enableMouse = mkOption {
      type = types.bool;
      default = true;
      description = "Enable mouse support";
    };
  };
  
  config = mkIf cfg.enable {
    dotfiles.enabledPackages = [ "nvim" ];
    
    # Create neovim configuration files
    system.activationScripts.dotfiles-nvim = mkIf dotfilesCfg.createTemplates ''
      echo "Creating Neovim dotfiles templates..."
      
      DOTFILES_DIR="/home/${dotfilesCfg.user}/.dotfiles"
      NVIM_DIR="$DOTFILES_DIR/nvim/.config/nvim"
      
      mkdir -p "$NVIM_DIR/lua"
      
      # Create init.lua or init.vim based on preference
      ${if cfg.useInitLua then ''
        cat > "$NVIM_DIR/init.lua" << 'EOF'
${initLuaTemplate}
EOF
      '' else ''
        cat > "$NVIM_DIR/init.vim" << 'EOF'
${vimrcTemplate}
EOF
      ''}
      
      # Set ownership
      chown -R ${dotfilesCfg.user}:users "$DOTFILES_DIR/nvim"
      
      echo "Neovim dotfiles templates created"
    '';
    
    # Install neovim and related packages
    environment.systemPackages = with pkgs; [
      neovim
      ripgrep
      fd
      tree-sitter
      nodejs  # For LSP servers
      python3  # For Python support
      gcc  # For treesitter compilation
      
      # LSP servers (minimal set - full set managed by development.nix)
      # Only include if development module is not enabled
      lua-language-server  # For Lua
      stylua  # Lua formatter
    ];
    
    # Set neovim as default editor
    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    
    # System-wide neovim configuration
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
      configure = {
        customRC = mkIf (!cfg.useInitLua) ''
          ${vimrcTemplate}
        '';
      };
    };
  };
}
