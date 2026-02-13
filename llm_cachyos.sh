#!/usr/bin/env bash
# ==============================================================================
# PREDATOR LOCAL LLM SETUP (CACHYOS / FISH / BUN / MONGO)
# ==============================================================================
set -uo pipefail

REAL_USER="${SUDO_USER:-$USER}"
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
MODEL_DIR="$USER_HOME/ai_models"

status() { 
    echo -e "\n\033[1;32m[AI]\033[0m $1" 
}

# 1. System Dependencies & AUR Helper
status "Installing CachyOS dependencies..."
sudo pacman -S --noconfirm base-devel git wget bun cmake python-pip

# Ensure an AUR helper (yay) is installed
if ! command -v yay &> /dev/null; then
    status "AUR helper not found. Installing yay..."
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin && makepkg -si --noconfirm
    cd - && rm -rf /tmp/yay-bin
fi

# 2. MongoDB Installation (AUR)
status "Installing MongoDB from AUR..."
sudo -u "$REAL_USER" yay -S --noconfirm mongodb-bin

status "Verifying and Starting MongoDB Service..."
sudo systemctl daemon-reload
sudo systemctl enable --now mongodb

if systemctl is-active --quiet mongodb; then
    echo "✅ MongoDB is running."
else
    echo "❌ MongoDB failed to start."
    exit 1
fi

# 3. Build Llama.cpp
status "Building Llama.cpp..."
cd "$USER_HOME"
if [ ! -d "llama.cpp" ]; then
    sudo -u "$REAL_USER" git clone https://github.com/ggerganov/llama.cpp
fi
cd llama.cpp
sudo -u "$REAL_USER" cmake -B build -DGGML_NATIVE=ON
sudo -u "$REAL_USER" cmake --build build --config Release -j "$(nproc)"
sudo ln -sf "$USER_HOME/llama.cpp/build/bin/llama-server" /usr/local/bin/llama-server

# 4. Model Download (HF-CLI)
sudo curl -LsSf https://hf.co/cli/install.sh | bash


status "Starting download to $MODEL_DIR..."
hf download bartowski/DeepSeek-Coder-V2-Lite-Instruct-GGUF \
    DeepSeek-Coder-V2-Lite-Instruct-Q4_K_M.gguf \
    --local-dir "$MODEL_DIR" --local-dir-use-symlinks False

# 5. Claude Code Agent & Fish Config
status "Installing Claude Code..."
sudo bun install -g @anthropic-ai/claude-code

status "Configuring Fish shell variables..."
FISH_CONF_DIR="$USER_HOME/.config/fish"
FISH_CONF="$FISH_CONF_DIR/config.fish"
sudo -u "$REAL_USER" mkdir -p "$FISH_CONF_DIR"
sudo -u "$REAL_USER" touch "$FISH_CONF"

# Safe append for environment variables
if ! grep -q "ANTHROPIC_BASE_URL" "$FISH_CONF"; then
    echo 'set -gx ANTHROPIC_BASE_URL "http://localhost:8000/v1"' | sudo -u "$REAL_USER" tee -a "$FISH_CONF"
fi
if ! grep -q "ANTHROPIC_API_KEY" "$FISH_CONF"; then
    echo 'set -gx ANTHROPIC_API_KEY "local"' | sudo -u "$REAL_USER" tee -a "$FISH_CONF"
fi

# 6. LibreChat Build
status "Building LibreChat..."
cd "$USER_HOME"
if [ ! -d "LibreChat" ]; then
    sudo -u "$REAL_USER" git clone https://github.com/danny-avila/LibreChat.git
fi
cd LibreChat
sudo -u "$REAL_USER" bun install
status "Linking internal packages..."
sudo -u "$REAL_USER" bun run build:packages
status "Final frontend build..."
sudo -u "$REAL_USER" bun run frontend
sudo -u "$REAL_USER" cp -n .env.example .env
sudo -u "$REAL_USER" sed -i 's/SEARCH=.*/SEARCH=false/' .env

status "PREDATOR SETUP COMPLETE"