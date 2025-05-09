## install zsh
sudo dnf install zsh -y
## oh my zsh
#sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
## 설치 직후 zsh 적용
#zsh


## p110k theme apply
## git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
## .zshrc에 p10k 적용
## sed -i 's/robbyrussell/powerlevel10k\/powerlevel10k/g' ~/.zshrc

## spaceship prompt로 변경
mkdir -p "$HOME/.zsh"
git clone --depth=1 https://github.com/spaceship-prompt/spaceship-prompt.git "$HOME/.zsh/spaceship"
echo 'source "$HOME/.zsh/spaceship/spaceship.zsh"' >> ~/.zshrc
source "$HOME/.zsh/spaceship/spaceship.zsh"

## 현재 사용자의 기본 shell을 zsh로 변경
sudo usermod -s /usr/bin/zsh $USER
