#!/bin/bash

# Update the system packages
sudo apt update
sudo apt upgrade -y

# Install Java version manager = sdkman or jenv
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Install Eclipse
sudo snap install --classic eclipse

# Install Docker
sudo apt install docker.io
sudo systemctl enable --now docker.service
sudo usermod -aG docker $USER

# Install Dbeaver
sudo snap install dbeaver-ce

# Install Postgres SQL with all dependencies
sudo apt install postgresql postgresql-contrib
sudo -u postgres createuser --interactive
sudo -u postgres createdb $USER

# Install Node.js
sudo apt install nodejs npm

# Install Nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Install Angular cli
npm install -g @angular/cli

# Install Golang
sudo snap install go --classic

# Install Oh my posh with all dependencies
sudo apt install golang-go fonts-powerline
go get -u github.com/justjanne/powerline-go
echo 'GOPATH=$HOME/go' >> ~/.bashrc
echo 'function _update_ps1() {' >> ~/.bashrc
echo '    PS1="$($GOPATH/bin/powerline-go -error $?)"' >> ~/.bashrc
echo '}' >> ~/.bashrc
echo 'if [ "$TERM" != "linux" ] && [ -f "$GOPATH/bin/powerline-go" ]; then' >> ~/.bashrc
echo '    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"' >> ~/.bashrc
echo 'fi' >> ~/.bashrc

# Install Anaconda
wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh
bash Anaconda3-2021.05-Linux-x86_64.sh
rm Anaconda3-2021.05-Linux-x86_64.sh


# Install gui Xfce
sudo apt install xfce4 xfce4-goodies


# Configure git with user information
sudo apt install git
git config --global user.name "Said Zitouni"
git config --global user.email "zitouni.sd@gmail.com"