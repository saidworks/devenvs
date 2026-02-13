#!/usr/bin/env bash
set -uo pipefail

if [[ $EUID -ne 0 ]]; then
   echo -e "\033[1;31mError: This script must be run with sudo.\033[0m"
   exit 1
fi

REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

status() {
    echo -e "\n\033[1;35m[SYSTEM]\033[0m \033[1m$1\033[0m"
}

# 1. PRIVILEGE & LOCKOUT RESET
echo "$REAL_USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99-temp-dev-setup
trap 'rm -f /etc/sudoers.d/99-temp-dev-setup' EXIT
faillock --user "$REAL_USER" --reset

# 2. AGGRESSIVE CONFLICT RESOLUTION
status "Cleaning package conflicts..."
# We remove 'code' to allow 'visual-studio-code-bin'
pacman -Rns --noconfirm code code-features 2>/dev/null || true
# If podman-docker is already there, we don't want to fight it
pacman -Rns --noconfirm docker 2>/dev/null || true

# 3. SYSTEM UPGRADE
status "Syncing and upgrading system..."
pacman -Syu --noconfirm

# 4. INSTALL CORE TOOLS
status "Installing Podman and System Runtimes..."
# REMOVED 'tldr' to avoid the tealdeer conflict; tealdeer is already on CachyOS.
pacman -S --noconfirm --needed \
    podman podman-docker podman-compose \
    base-devel clang cmake ninja llvm \
    postgresql redis mariadb \
    dotnet-sdk dotnet-runtime aspnet-runtime \
    git wget curl httpie fd ripgrep fzf bat jq yq lazygit btop

# 5. MISE RUNTIMES
status "Configuring Mise & Global Runtimes..."
sudo -u "$REAL_USER" bash -c "curl https://mise.run | sh"
mkdir -p "$USER_HOME/.config/fish/conf.d"
echo 'if test -f ~/.local/bin/mise; ~/.local/bin/mise activate fish | source; end' > "$USER_HOME/.config/fish/conf.d/mise.fish"

sudo -u "$REAL_USER" bash -c "
    export PATH=\"$USER_HOME/.local/bin:\$PATH\"
    ~/.local/bin/mise use -g java@temurin-25
    ~/.local/bin/mise use -g node@22
    ~/.local/bin/mise use -g python@3.12
    ~/.local/bin/mise use -g go@latest
    ~/.local/bin/mise use -g bun@latest
    
    # Using Mise to manage global node dependencies (Cleaner than npm -g)
    ~/.local/bin/mise use -g npm:pnpm
    ~/.local/bin/mise use -g npm:typescript
    ~/.local/bin/mise use -g npm:rimraf
"

# 6. AUR SOFTWARE
status "Installing AUR Packages (Using correct names)..."
# Changed podman-desktop-bin back to podman-desktop (standard AUR name)
sudo -u "$REAL_USER" paru -S --noconfirm --needed \
    podman-desktop \
    visual-studio-code-bin bruno-bin \
    android-studio dbeaver postman-bin \
    mongodb-bin mongodb-tools-bin

# 7. DATABASE INIT
status "Initializing PostgreSQL & MariaDB..."
systemctl stop postgresql 2>/dev/null || true
rm -rf /var/lib/postgres/data
mkdir -p /var/lib/postgres/data
chown -R postgres:postgres /var/lib/postgres
sudo -u postgres initdb --locale=C.UTF-8 --encoding=UTF8 -D '/var/lib/postgres/data'

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
fi

# 8. PODMAN DOCKER COMPATIBILITY
status "Configuring User-level Podman Sockets..."
systemctl enable --now podman.socket
echo "set -gx DOCKER_HOST unix://\$XDG_RUNTIME_DIR/podman/podman.sock" > "$USER_HOME/.config/fish/conf.d/podman_compat.fish"
chown "$REAL_USER":"$REAL_USER" "$USER_HOME/.config/fish/conf.d/podman_compat.fish"

# 9. FISH ENHANCEMENTS
status "Applying Predator Shell Aliases..."
cat <<EOF > "$USER_HOME/.config/fish/conf.d/predator_dev.fish"
alias h="http"
alias hs="https"
alias lg="lazygit"
alias gs="git status"
alias docker="podman"
alias docker-compose="podman-compose"
alias l="ls -lah --color=auto"
alias cat="bat"
# Map tldr to tealdeer so you don't notice the difference
alias tldr="tealdeer"
alias b="bun"
alias bx="bunx"
EOF
chown "$REAL_USER":"$REAL_USER" "$USER_HOME/.config/fish/conf.d/predator_dev.fish"

# 10. ENABLE SERVICES (With fix for linked/masked units and empty names)
status "Activating System Services..."
systemctl daemon-reload

# Fix for "Refusing to operate on linked unit file"
# This forces systemd to reset the symlinks for these specific services
for svc in postgresql redis mariadb podman; do
    status "Resetting and starting $svc..."
    systemctl unmask "$svc" 2>/dev/null || true
    systemctl reenable --now "$svc" 2>/dev/null || true
done

# Safe MongoDB enablement
MONGO_FOUND=$(systemctl list-unit-files | grep -E "^mongo(d|db).service" | head -n1 | awk '{print $1}')
if [ -n "$MONGO_FOUND" ]; then
    systemctl unmask "$MONGO_FOUND" 2>/dev/null || true
    systemctl enable --now "$MONGO_FOUND"
else
    status "MongoDB service not found yet. Run 'paru -S mongodb-bin' manually later."
fi

status "DEV ENVIRONMENT READY! PLEASE REBOOT."
