sudo tee /etc/wsl.conf > /dev/null <<'EOF'
[user]
default=cozy

[boot]
command="cd ~"

[boot]
systemd=true
EOF
sudo dnf install epel-release -y
sudo dnf install btop tree file bat zip vim curl zsh wget fontconfig lsof net-tools bind-utils -y
sudo dnf group install "Development Tools"
sudo dnf update -y
sudo usermod -s /usr/bin/zsh $USER
git config --global user.email "bahn1075@gmail.com"
git config --global user.name "Cozy"
