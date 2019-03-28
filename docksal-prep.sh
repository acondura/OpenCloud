#! /usr/bin/env bash

#-------------------------- Helper functions --------------------------------

# Console colors
red='\033[0;31m'
green='\033[0;32m'
green_bg='\033[42m'
yellow='\033[1;33m'
NC='\033[0m'

echo-red () { echo -e "${red}$1${NC}"; }
echo-green () { echo -e "${green}$1${NC}"; }
echo-green-bg () { echo -e "${green_bg}$1${NC}"; }
echo-yellow () { echo -e "${yellow}$1${NC}"; }

#-------------------------- Execution --------------------------------

set -e

echo -e "${green_bg} Step 1 ${NC}${green} Updating packages...${NC}"

export DEBIAN_FRONTEND=noninteractive

# Update package info
apt-get update
# Upgrade packages
apt-get -y upgrade
# This makes sure that ALL security updates are applied
unattended-upgrade -d

# Install packages to allow apt to use a repository over HTTPS
apt-get -y install apt-utils pv
apt-get -y install apt-transport-https ca-certificates gnupg2 software-properties-common host

# Install Oh my ZSH
echo -e "${green_bg} Step 2 ${NC}${green} Installing required packages (curl, zsh, git, gcc, etc.)...${NC}"
apt-get -y install sudo curl zsh git p7zip-full tmux

# LetsEncrypt Certbot
echo -e "${green_bg} Step 3 ${NC}${green} Installing LetsEncrypt...${NC}"
apt-get -y install certbot

echo -e "${green_bg} Step 4 ${NC}${green} Creating the 'docksal' user...${NC}"
# Add docksal as a sudo group with no password
echo "docksal ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
# Create the docksal user
adduser --disabled-password --gecos "" --shell /usr/bin/zsh docksal
# Assign the docksal group to the user
usermod -aG docksal docksal
# Make sure the SSH key is in place
mkdir /home/docksal/.ssh
cp -rf /root/.ssh/authorized_keys /home/docksal/.ssh
chown -R docksal:docksal /home/docksal/.ssh

# Set SSH to run with NO password, just SSH keys
echo -e "${green_bg} Step 5 ${NC}${green} Securing the server to accept no passwords, just SSH keys, non-root logins...${NC}"
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#   PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/ssh_config

echo -e "${green_bg} Step 6 ${NC}${green} Setting up the 'docksal' user...${NC}"
touch /home/docksal/.zshrc
chown docksal:docksal /home/docksal/.zshrc

# Install Oh my Zsh
echo -e "${green_bg} Step 7 ${NC}${green} Installing Oh My ZSH!...${NC}"
runuser -l docksal --session-command -s zsh "zsh -c $(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
runuser -l docksal --session-command -s zsh "echo 'alias s=\"cd ..\"' >> /home/docksal/.zshrc"
runuser -l docksal --session-command -s zsh "sed -i 's/ZSH_THEME=\".*\"/ZSH_THEME=\"bira\"/g' /home/docksal/.zshrc"

# Clone VimProc
runuser -l docksal --session-command -s zsh "git clone https://github.com/Shougo/vimproc.vim.git"

# Install SpaceVIM
echo -e "${green_bg} Step 8 ${NC}${green} Installing SpaceVIM...${NC}"
runuser -l docksal --session-command -s zsh "curl -sLf https://spacevim.org/install.sh | bash"
runuser -l docksal --session-command -s zsh "sed -i 's/colorscheme = \".*\"/colorscheme = \"SpaceVim\"/g' /home/docksal/.SpaceVim.d/init.toml"

# Add Vim Twig support
runuser -l docksal --session-command -s zsh "git clone https://github.com/lumiliet/vim-twig.git"
runuser -l docksal --session-command -s zsh "echo '' >> /home/docksal/.SpaceVim.d/init.toml"
runuser -l docksal --session-command -s zsh "echo '# Vim Twig support' >> /home/docksal/.SpaceVim.d/init.toml"
runuser -l docksal --session-command -s zsh "echo '[[custom_plugins]]' >> /home/docksal/.SpaceVim.d/init.toml"
runuser -l docksal --session-command -s zsh "echo 'name = \"lumiliet/vim-twig\"' >> /home/docksal/.SpaceVim.d/init.toml"
runuser -l docksal --session-command -s zsh "echo 'merged = false' >> /home/docksal/.SpaceVim.d/init.toml"

# Install Docksal
echo -e "${green_bg} Step 9 ${NC}${green} Installing Docksal...${NC}"
runuser -l docksal --session-command -s zsh 'curl -fsSL get.docksal.io | zsh'
runuser -l docksal --session-command -s zsh 'newgrp docker'

# Set the proxy ip in the global docksal environment file.
runuser -l docksal --session-command -s zsh "echo 'DOCKSAL_VHOST_PROXY_IP=\"0.0.0.0\"' > /home/docksal/.docksal/docksal.env"
# Reset the system.
runuser -l docksal --session-command -s zsh 'fin reset system'
