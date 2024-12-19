
#!/bin/bash

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install VS Code
choco install vscode

# Install MySQL Workbench
choco install mysql.workbench

# Install Java version manager sdkman
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Install Eclipse
choco install eclipse

# Install Docker
choco install docker-desktop

# Install DBeaver
choco install dbeaver

# Install Postgres SQL with all dependencies
choco install postgresql

# Install Node.js
choco install nodejs

# Install Nvm
choco install nvm

# Install Angular CLI
npm install -g @angular/cli

# Install Golang
choco install golang

# Install Oh my posh with all dependencies
choco install poshgit
Install-Module oh-my-posh -Scope CurrentUser
Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck
Import-Module oh-my-posh
Set-PoshPrompt -Theme paradox

# Install Anaconda
choco install anaconda3

# Install Salesforce extension pack
code --install-extension salesforce.salesforcedx-vscode

# Install Java extension pack
code --install-extension vscjava.vscode-java-pack

# Install Javascript code runner
code --install-extension formulahendry.code-runner

# Install Pretty code formatter
code --install-extension esbenp.prettier-vscode

# Install Auto close tags
code --install-extension formulahendry.auto-close-tag

# Install Live server
code --install-extension ritwickdey.liveserver

# Install Python extension pack
code --install-extension donjayamanne.python-extension-pack

# Install Golang extension pack
code --install-extension golang.go

# Install Python compiler
code --install-extension njpwerner.autodocstring

# Install VS code extension
code --install-extension ms-vscode.cpptools

# Install Pycharm
choco install pycharm-community

# Configure git with user information
git config --global user.name "Said Zitouni"
git config --global user.email "zitouni.sd@gmail.com"