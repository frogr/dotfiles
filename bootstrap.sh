#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Dotfiles bootstrap starting..."

# --- Homebrew ---
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "==> Installing Homebrew packages..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# --- Oh My Zsh ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "==> Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# --- Powerlevel10k ---
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo "==> Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# --- Zsh plugins ---
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "==> Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "==> Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# --- NVM ---
if [ ! -d "$HOME/.nvm" ]; then
  echo "==> Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# --- Rust/Cargo ---
if ! command -v rustup &>/dev/null; then
  echo "==> Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# --- Symlink zsh configs ---
echo "==> Symlinking zsh configs..."
ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"
ln -sf "$DOTFILES_DIR/zsh/.zshenv" "$HOME/.zshenv"

# --- Symlink git config ---
echo "==> Symlinking git config..."
ln -sf "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

# --- VSCode settings ---
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
if [ -d "$VSCODE_USER_DIR" ] || [ -d "/Applications/Visual Studio Code.app" ]; then
  echo "==> Symlinking VSCode settings..."
  mkdir -p "$VSCODE_USER_DIR"
  ln -sf "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_USER_DIR/settings.json"
fi

# --- VSCode extensions ---
if command -v code &>/dev/null; then
  echo "==> Installing VSCode extensions..."
  while IFS= read -r ext; do
    code --install-extension "$ext" --force 2>/dev/null || true
  done < "$DOTFILES_DIR/vscode/extensions.txt"
fi

# --- iTerm2 preferences ---
if [ -f "$DOTFILES_DIR/iterm2/com.googlecode.iterm2.plist" ]; then
  echo "==> Importing iTerm2 preferences..."
  cp "$DOTFILES_DIR/iterm2/com.googlecode.iterm2.plist" "$HOME/Library/Preferences/com.googlecode.iterm2.plist"
  defaults read com.googlecode.iterm2 &>/dev/null
fi

echo ""
echo "==> Bootstrap complete!"
echo ""
echo "NOTE: A few things to do manually:"
echo "  1. Update your git email in ~/.gitconfig if needed for work"
echo "  2. Set up your GPG key (or generate a new one with: gpg --full-generate-key)"
echo "  3. Install Node via nvm: nvm install --lts"
echo "  4. Install Ruby via rbenv: rbenv install <version>"
echo "  5. Run 'p10k configure' to set up your prompt"
echo "  6. Restart your terminal"
