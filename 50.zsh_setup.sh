## install zsh
sudo dnf install zsh -y
## oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# zsh-syntax-highlighting 설치
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# .zshrc에 플러그인 추가 (이미 있으면 중복 추가 방지)
if ! grep -q "zsh-syntax-highlighting" ~/.zshrc; then
  sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-syntax-highlighting)/' ~/.zshrc
  # 만약 plugins= 라인이 없다면 추가
  if ! grep -q "^plugins=" ~/.zshrc; then
    echo "plugins=(zsh-syntax-highlighting)" >> ~/.zshrc
  fi
  # 플러그인 활성화 코드가 없으면 추가
  echo "source \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
fi

