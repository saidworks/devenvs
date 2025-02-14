# Check if Chocolatey is installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install WSL
choco install wsl -y

# Update WSL to WSL 2
wsl --update
wsl --set-default-version 2

# Install Kali Linux with GUI
wsl --install -d kali-linux

# Install Docker
choco install docker-desktop -y


# Install NVM
choco install nvm -y

# Install WinRAR
choco install winrar -y

# Install Spotify
choco install spotify -y

# Install Media Player Classic - Home Cinema (MPC-HC) with K-Lite Mega Codec Pack
choco install k-litecodecpackmega -y

# Install Git for Windows
choco install git -y
choco install plantuml


# Install Git for Kali Linux in WSL
wsl -d kali-linux -u root -- apt update
wsl -d kali-linux -u root -- apt install -y git

# Install Visual Studio Code
choco install vscode -y

# Install Oh My Posh
choco install oh-my-posh -y


# Install Adobe Acrobat Reader
choco install adobereader -y

#install llm dependencies
choco install ollama

#install scoop
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

#install poetry with dependencies
scoop install pipx
pipx ensurepath


# databases
scoop install postgresql
# choco install postgresql -y

# Placeholder for Git configuration
# Uncomment and configure the following lines as needed
git config --global user.name "FirstName LastNAme"
git config --global user.email "username@gmail.com"
.\git_ssh_config.sh

# install jenv to manage java versions
git clone git@github.com:FelixSelter/JEnv-for-Windows.git
cd Jenv-for-Windows.git
.\jenv.bat


# api testing 
choco install postman


choco install make
