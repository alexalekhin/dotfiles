#!/usr/bin/env bash
# ============================================================
#  Ubuntu First Install — Dotfiles Bootstrap
#  Usage: chmod +x bootstrap.sh && ./bootstrap.sh
# ============================================================
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles_cfg}"
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

log() { echo -e "\n\033[1;32m==>\033[0m $1"; }

# ------------------------------------------------------------
# 0. Apt update + upgrade
# ------------------------------------------------------------
log "0. Apt update + upgrade"
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
    curl wget git build-essential software-properties-common \
    apt-transport-https ca-certificates gnupg lsb-release unzip \
    file

# ------------------------------------------------------------
# 1. Prepare shell
# ------------------------------------------------------------

# 1.1 Install zsh + set zsh default
log "1.1 Install zsh + set zsh default"
sudo apt install -y zsh
chsh -s "$(command -v zsh)" "$USER"   # применится после перелогина

# 1.2 Install oh-my-zsh
log "1.2 Install oh-my-zsh"
RUNZSH=no KEEP_ZSHRC=yes sh -c \
  "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 1.3 Install oh-my-zsh plugins
log "1.3 Install oh-my-zsh plugins"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null || true
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null || true
git clone --depth=1 https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions" 2>/dev/null || true
git clone --depth=1 https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab" 2>/dev/null || true

# 1.4 Install prompt + etc
log "1.4 Install prompt + etc"
sudo apt install -y fzf

# ------------------------------------------------------------
# 2. Prepare terminal
# ------------------------------------------------------------

# 2.1 Install gnome-extensions
log "2.1 Install gnome-extensions"
sudo apt install -y gnome-shell-extensions gnome-shell-extension-manager gnome-browser-connector pipx
pipx ensurepath
pipx install gnome-extensions-cli --system-site-packages --force
GEXT="$HOME/.local/bin/gext"

QUAKE_UUID="quake-terminal@diegodario88.github.io"
"$GEXT" -F install "$QUAKE_UUID"

EXT_DIR="$HOME/.local/share/gnome-shell/extensions/$QUAKE_UUID"
if [ -d "$EXT_DIR" ]; then
    glib-compile-schemas "$EXT_DIR/schemas" 2>/dev/null || true

    gsettings set org.gnome.shell disable-user-extensions false
    ENABLED="$(gsettings get org.gnome.shell enabled-extensions)"
    case "$ENABLED" in
        *"$QUAKE_UUID"*) ;;
        "@as []"|"[]") gsettings set org.gnome.shell enabled-extensions "['$QUAKE_UUID']" ;;
        *) gsettings set org.gnome.shell enabled-extensions "${ENABLED%]*}, '$QUAKE_UUID']" ;;
    esac

    QUAKE_SCHEMA="org.gnome.shell.extensions.quake-terminal"
    SHORTCUT_KEY="$(gsettings --schemadir "$EXT_DIR/schemas" list-keys "$QUAKE_SCHEMA" | grep -iE 'shortcut|keybind' | head -n1)"
    [ -n "$SHORTCUT_KEY" ] && gsettings --schemadir "$EXT_DIR/schemas" set "$QUAKE_SCHEMA" "$SHORTCUT_KEY" "['F12']"

    TERM_KEY="$(gsettings --schemadir "$EXT_DIR/schemas" list-keys "$QUAKE_SCHEMA" | grep -iE '^terminal-id$|app-id' | head -n1)"
    [ -n "$TERM_KEY" ] && gsettings --schemadir "$EXT_DIR/schemas" set "$QUAKE_SCHEMA" "$TERM_KEY" "kitty.desktop"
else
    echo "Quake Terminal не установился — проверь вручную: $GEXT -F install $QUAKE_UUID"
fi

# 2.2 Install Kitty
log "2.2 Install Kitty"
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"
ln -sf "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/bin/kitty"
ln -sf "$HOME/.local/kitty.app/bin/kitten" "$HOME/.local/bin/kitten"
cp "$HOME/.local/kitty.app/share/applications/kitty.desktop" "$HOME/.local/share/applications/"
cp "$HOME/.local/kitty.app/share/applications/kitty-open.desktop" "$HOME/.local/share/applications/"
sed -i "s|Icon=kitty|Icon=$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" "$HOME/.local/share/applications/kitty"*.desktop
sed -i "s|Exec=kitty|Exec=$HOME/.local/kitty.app/bin/kitty|g" "$HOME/.local/share/applications/kitty"*.desktop

# 2.3 Install nerd font
log "2.3 Install nerd font"
mkdir -p "$HOME/.local/share/fonts"
tmpdir="$(mktemp -d)"
curl -fLo "$tmpdir/JetBrainsMono.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -oq "$tmpdir/JetBrainsMono.zip" -d "$HOME/.local/share/fonts"
rm -rf "$tmpdir"
fc-cache -f

# 2.4 Set required symlinks
log "2.4 Set required symlinks"
mkdir -p "$HOME/.config"
[ -f "$DOTFILES/.zshrc" ]      && ln -sf "$DOTFILES/.zshrc" "$HOME/.zshrc"
[ -f "$DOTFILES/.zshenv" ]     && ln -sf "$DOTFILES/.zshenv" "$HOME/.zshenv"
[ -d "$DOTFILES/kitty" ]       && ln -sf "$DOTFILES/kitty" "$HOME/.config/kitty"
[ -d "$DOTFILES/nvim" ]        && ln -sf "$DOTFILES/nvim" "$HOME/.config/nvim"
# [ -d "$DOTFILES/yazi" ]        && ln -sf "$DOTFILES/yazi" "$HOME/.config/yazi"

# ------------------------------------------------------------
# 3. Prepare utilities
# ------------------------------------------------------------

# 3.1 Prepare Rust/cargo
log "3.1 Prepare Rust/cargo"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

# shellcheck disable=SC1091
source "$HOME/.cargo/env"

curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

# 3.2 Install yazi and dependencies
log "3.2 Install yazi and dependencies"
sudo apt install -y pkg-config
sudo apt install -y ffmpeg poppler-utils unar file jq
sudo apt install -y 7zip
cargo binstall -y ripgrep fd-find bat zoxide
cargo binstall -y resvg
rm -rf /tmp/cargo-install* /tmp/yazi-build-*
cargo install --force yazi-build

# 3.3 Install neovim
log "3.3 Install neovim"
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt update
sudo apt install -y neovim

# 3.4 Install vlc
log "3.4 Install vlc"
sudo apt install -y vlc

# 3.5 Install eza + replace ls with eza
log "3.5 Install eza + replace ls with eza"
sudo mkdir -p /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/gierens.gpg ]; then
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
fi
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
    | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza
# алиасы (пропиши в .zshrc дотфайлов):
#   alias ls='eza --icons --group-directories-first'
#   alias ll='eza -l --icons --group-directories-first'
#   alias la='eza -la --icons --group-directories-first'
#   alias tree='eza --tree --icons'

# ------------------------------------------------------------
# 4. Prepare core GUI utilities
# ------------------------------------------------------------

# 4.1 Install Zen browser
log "4.1 Install Zen browser"
curl -fsSL https://updates.zen-browser.app/appimage.sh -o /tmp/zen-install.sh
bash /tmp/zen-install.sh
rm -f /tmp/zen-install.sh

# 4.2 Install Obsidian (AppImage)
log "4.2 Install Obsidian"
# Ubuntu 24.04+ uses libfuse2t64 (libfuse2 for 22.04)
sudo apt install -y libfuse2t64 2>/dev/null || sudo apt install -y libfuse2

mkdir -p "$HOME/Applications" "$HOME/.local/share/applications" "$HOME/.local/share/icons"
OBSIDIAN_URL="$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest \
    | grep "browser_download_url.*\.AppImage" \
    | grep -v "arm64" \
    | cut -d '"' -f 4)"
curl -fL --progress-bar "$OBSIDIAN_URL" -o "$HOME/Applications/Obsidian.AppImage"
chmod u+x "$HOME/Applications/Obsidian.AppImage"

# set icon
( cd "$HOME/Applications" \
    && ./Obsidian.AppImage --appimage-extract 'usr/share/icons/hicolor/512x512/apps/obsidian.png' >/dev/null 2>&1 \
    && cp squashfs-root/usr/share/icons/hicolor/512x512/apps/obsidian.png "$HOME/.local/share/icons/obsidian.png" \
    && rm -rf squashfs-root ) || true

cat > "$HOME/.local/share/applications/obsidian.desktop" <<EOF
[Desktop Entry]
Name=Obsidian
Exec=$HOME/Applications/Obsidian.AppImage %u
Terminal=false
Type=Application
Icon=$HOME/.local/share/icons/obsidian.png
Categories=Office;Utility;
MimeType=x-scheme-handler/obsidian;
EOF

# 4.3 Install brave
log "4.3 Install brave"
curl -fsS https://dl.brave.com/install.sh | sh

# 4.4 Install telegram
log "4.4 Install telegram"
sudo apt install -y telegram-desktop

# ------------------------------------------------------------
# 5. Prepare Dev tools
# ------------------------------------------------------------

# 5.1 Install android studio
log "5.1 Install android studio"
sudo snap install android-studio --classic

# 5.2 Setup claude + claude code
log "5.2 Setup claude + claude code"
curl -fsSL https://claude.ai/install.sh | bash

log "Готово. Перелогинься (или перезагрузись), чтобы применились: zsh как shell по умолчанию, шрифты, PATH от cargo/npm."
