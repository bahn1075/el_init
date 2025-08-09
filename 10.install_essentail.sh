#bin/bash
#sudo tee /etc/wsl.conf > /dev/null <<'EOF'
#[user]
#default=cozy
#[boot]
#systemd=true
#EOF
sudo timedatectl set-timezone Asia/Seoul
sudo dnf install epel-release -y
sudo dnf install btop tree file bat zip vim curl zsh wget fontconfig lsof net-tools bind-utils socat fastfetch -y
sudo dnf group install "Development Tools"
sudo dnf update -y
mkdir -p ~/.config/fastfetch
cp ./fastfetch_config.jsonc ~/.config/fastfetch/config.jsonc
#sudo usermod -s /usr/bin/zsh $USER
#git config --global user.email "bahn1075@gmail.com"
#git config --global user.name "Cozy"
