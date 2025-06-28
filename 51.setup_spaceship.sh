## spaceship prompt로 변경
brew install spaceship
echo "source $(brew --prefix)/opt/spaceship/spaceship.zsh" >>! ~/.zshrc
#sed -i 's/robbyrussell/spaceship/g' ~/.zshrc
## zshrc/.zshrc 파일을 홈디렉토리로 복사
cp /app/el_init/zshrc/.zshrc ~/.zshrc

## 현재 사용자의 기본 shell을 zsh로 변경
sudo usermod -s /usr/bin/zsh $USER
