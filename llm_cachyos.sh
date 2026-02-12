#!/usr/bin/env bash
# ==============================================================================
# PREDATOR LOCAL LLM SETUP (LLAMA.CPP + NATIVE LIBRECHAT + GOOGLE SEARCH)
# ==============================================================================
set -uo pipefail
REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
status() { echo -e "\n\e[1;35m[AI] $1\e
status "Downloading DeepSeek-Coder-V2-Lite"
mkdir -p "$USER_HOME/ai_models"
sudo -u "$REAL_USER" wget -O "$USER_HOME/ai_models/coder-lite-q4.gguf" \
    https://huggingface.co/bartowski/DeepSeek-Coder-V2-Lite-Instruct-GGUF/resolve/main/DeepSeek-Coder-V2-Lite-Instruct-Q4_K_M.gguf

# 3. Claude Code Terminal Agent
status "Installing Anthropic Claude Code"
sudo -u "$REAL_USER" npm install -g @anthropic-ai/claude-code
# Point Claude Code to local llama-server (Port 8000)
echo 'set -gx ANTHROPIC_BASE_URL "http://localhost:8000"' >> "$USER_HOME/.config/fish/conf.d/ai_vars.fish"
echo 'set -gx ANTHROPIC_AUTH_TOKEN "local"' >> "$USER_HOME/.config/fish/conf.d/ai_vars.fish"

# 4. Native LibreChat Setup (Web Interface with Web Search)
status "Installing LibreChat Natively"
cd "$USER_HOME"
sudo -u "$REAL_USER" git clone https://github.com/danny-avila/LibreChat.git
cd LibreChat
sudo -u "$REAL_USER" npm install
sudo -u "$REAL_USER" cp.env.example.env

# Configure.env for Native Mongo & Google Search API
sudo -u "$REAL_USER" sed -i 's|MONGO_URI=.*|MONGO_URI=mongodb://127.0.0.1:27017/LibreChat|'.env
sudo -u "$REAL_USER" tee -a.env <<EOF
# Local Llama-Server Endpoint
OLLAMA_BASE_URL=http://127.0.0.1:8000
# Google Search API Setup
GOOGLE_SEARCH_API_KEY=YOUR_API_KEY_HERE
GOOGLE_CSE_ID=YOUR_SEARCH_ENGINE_ID_HERE
EOF

# Build LibreChat Frontend
sudo -u "$REAL_USER" npm run build

status "AI Environment Ready!"
echo "1. Start Llama-Server: llama-server -m ~/ai_models/coder-lite-q4.gguf --port 8000 --n-gpu-layers 99"
echo "2. Start LibreChat: cd ~/LibreChat && npm run start"
echo "3. Run 'claude' in terminal to use the agentic assistant."