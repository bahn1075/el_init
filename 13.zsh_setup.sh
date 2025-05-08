## install zsh
sudo dnf install zsh -y
## 설치 직후 zsh 적용
zsh
## 현재 사용자의 기본 shell을 zsh로 변경
sudo usermod -s /usr/bin/zsh $USER

## p110k theme apply
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
## .zshrc에 p10k 적용
sed -i 's/robbyrussell/powerlevel10k\/powerlevel10k/g' ~/.zshrc
