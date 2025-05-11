sudo dnf install epel-release -y
sudo dnf install btop bat zip vim curl zsh wget fontconfig -y
sudo dnf group install "Development Tools"
sudo dnf update -y
sudo usermod -s /usr/bin/zsh $USER
