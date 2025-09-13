## install zsh
sudo dnf install zsh -y

## oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

## starship prompt 설치
brew install starship

# starship 설정 디렉토리 생성
mkdir -p ~/.config

# starship 설정 파일 복사
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR/starship.toml" ~/.config/starship.toml

# fastfetch 설정 디렉토리 생성 및 설정 파일 복사
mkdir -p ~/.config/fastfetch
cp "$SCRIPT_DIR/fastfetch_config.jsonc" ~/.config/fastfetch/config.jsonc

# .zshrc에 fastfetch 자동 실행 추가 (터미널 시작시)
if ! grep -q "fastfetch" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# Run fastfetch on terminal start" >> ~/.zshrc
    echo "fastfetch" >> ~/.zshrc
fi

echo "✓ fastfetch 설정 완료"
echo "✓ 설정 파일이 ~/.config/fastfetch/config.jsonc로 복사되었습니다"

# .zshrc에 starship 초기화 코드 추가
if ! grep -q "eval \"\$(starship init zsh)\"" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# Initialize starship prompt" >> ~/.zshrc
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc
fi

# WSL 환경에서 홈 디렉토리 설정
echo "" >> ~/.zshrc
echo "# WSL Home Directory Setting" >> ~/.zshrc
echo "# Always start in Linux home directory" >> ~/.zshrc
echo 'cd ~' >> ~/.zshrc

# Oh My Zsh 테마를 비활성화 (starship과 충돌 방지)
if grep -q 'ZSH_THEME="robbyrussell"' ~/.zshrc; then
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME=""/' ~/.zshrc
    echo "✓ Oh My Zsh 테마를 비활성화했습니다"
fi

echo "✓ starship 설치 및 설정 완료"
echo "✓ 설정 파일이 ~/.config/starship.toml로 복사되었습니다"

# zsh-syntax-highlighting 설치
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# .zshrc에 플러그인 추가 (이미 있으면 중복 추가 방지)
if ! grep -q "zsh-syntax-highlighting" ~/.zshrc; then
  sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-syntax-highlighting)/' ~/.zshrc
  # 만약 plugins= 라인이 없다면 추가
  if ! grep -q "^plugins=" ~/.zshrc; then
    echo "plugins=(git kubectl kube-ps1 zsh-syntax-highlighting zsh-autosuggestions)" >> ~/.zshrc
  fi
  # 플러그인 활성화 코드가 없으면 추가
  echo "source \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
fi

