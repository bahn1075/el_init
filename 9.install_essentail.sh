sudo dnf install epel-release -y
sudo dnf install btop tree file bat zip vim curl zsh wget fontconfig lsof net-tools bind-utils -y
sudo dnf group install "Development Tools"
sudo dnf update -y
sudo usermod -s /usr/bin/zsh $USER
