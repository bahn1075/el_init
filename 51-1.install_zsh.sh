## install zsh
sudo dnf install zsh -y

## oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

## starship prompt 설치
# linuxbrew PATH 설정 (스크립트에서 brew를 사용하기 위해 필요)
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
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

# .zshrc에 brew shellenv 추가 (brew로 설치한 패키지를 찾기 위해 필요)
if ! grep -q "linuxbrew.*shellenv" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# Homebrew PATH 설정" >> ~/.zshrc
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
fi

# WSL 환경에서 홈 디렉토리 설정
if ! grep -q "^cd ~" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# WSL Home Directory Setting" >> ~/.zshrc
    echo "# Always start in Linux home directory" >> ~/.zshrc
    echo 'cd ~' >> ~/.zshrc
fi

# Oh My Zsh 테마를 비활성화 (starship과 충돌 방지)
if grep -q 'ZSH_THEME="robbyrussell"' ~/.zshrc; then
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME=""/' ~/.zshrc
    echo "✓ Oh My Zsh 테마를 비활성화했습니다"
fi

echo "✓ starship 설치 및 설정 완료"
echo "✓ 설정 파일이 ~/.config/starship.toml로 복사되었습니다"

# .zshrc에 eza alias 추가 (이미 있으면 중복 추가 방지)
if ! grep -q "alias ls=\"eza" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "alias ls=\"eza --icons --git --level=2 --time-style='+%m/%d %H:%M' --git-repos --total-size\"" >> ~/.zshrc
    echo "✓ eza alias 추가 완료"
fi

# zsh-syntax-highlighting 설치 (이미 있으면 스킵)
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# .zshrc plugins=() 배열에 플러그인 추가
if ! grep -q "zsh-syntax-highlighting" ~/.zshrc; then
    sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc
    # plugins= 라인이 없는 경우 추가
    if ! grep -q "^plugins=" ~/.zshrc; then
        echo "plugins=(git zsh-syntax-highlighting zsh-autosuggestions)" >> ~/.zshrc
    fi
elif ! grep -q "zsh-autosuggestions" ~/.zshrc; then
    # zsh-syntax-highlighting은 있지만 zsh-autosuggestions이 없는 경우
    sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions)/' ~/.zshrc
fi

# source 라인 추가 (oh-my-zsh plugins 배열과 별개로 명시적 로드)
if ! grep -q "zsh-syntax-highlighting.zsh" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "source \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
fi
if ! grep -q "zsh-autosuggestions.zsh" ~/.zshrc; then
    echo "source \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc
fi
echo "✓ zsh 플러그인 설정 완료"

