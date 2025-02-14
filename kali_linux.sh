# Update and upgrade system
sudo apt update && sudo apt -y full-upgrade

# Install dependencies
sudo apt install -y curl unzip git

# Install SDKMAN
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Install PYENV
curl https://pyenv.run | bash
echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
source ~/.bashrc

# Install Salesforce CLI
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt install -y nodejs
npm install sfdx-cli --global

# Install NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Install Snap
sudo apt install -y snapd
sudo systemctl enable --now snapd apparmor
sudo ln -s /var/lib/snapd/snap /snap

# add spap to path by adding following to bashrc
# echo 'export PATH=$PATH:/snap/bin' >> ~/.bashrc
# source ~/.bashrc

# Install Eclipse
sudo snap install --classic eclipse

# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

echo "Development environment setup complete!"