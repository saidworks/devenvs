# Update the system packages
sudo pacman -Syu

# Install Java version manager = sdkman or jenv
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Install Eclipse
sudo pacman -S eclipse-java

# Install Docker
sudo pacman -S docker
sudo systemctl enable --now docker.service
sudo usermod -aG docker $USER

# Install Dbeaver
sudo pacman -S dbeaver

# Install Postgres SQL with all dependencies
sudo pacman -S postgresql postgresql-libs
sudo -u postgres initdb -D /var/lib/postgres/data
# Edit postgresql.conf here to set listen_addresses and fsync
sudo systemctl enable --now postgresql.service

# Install Node.js and Nvm within WSL
sudo pacman -S nodejs npm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Install Angular CLI within WSL
npm install -g @angular/cli

# Install Golang
sudo pacman -S go

# Install Oh my posh with all dependencies
sudo pacman -S glibc lib32-glibc
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
chmod +x /usr/local/bin/oh-my-posh

# Install Anaconda
wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh
bash Anaconda3-2021.05-Linux-x86_64.sh
rm Anaconda3-2021.05-Linux-x86_64.sh

# Install gui Xfce
sudo pacman -S xfce4 xfce4-goodies

# Configure git with user information
sudo pacman -S git
git config --global user.name "Said Zitouni"
git config --global user.email "zitouni.sd@gmail.com"


# tested everytthing works except postgres and angular