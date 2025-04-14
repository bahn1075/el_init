#!/bin/bash

# Development Tools 설치 확인 및 설치
if ! sudo dnf groupinfo "Development Tools" | grep -q "Installed Packages"; then
    echo "Development Tools 그룹이 설치되어 있지 않습니다. 설치를 진행합니다."
    sudo dnf groupinstall -y "Development Tools"
else
    echo "Development Tools 그룹이 이미 설치되어 있습니다."
fi

# Python 빌드에 필요한 라이브러리 설치
sudo dnf install -y bzip2 bzip2-devel ncurses ncurses-devel libffi libffi-devel readline readline-devel openssl openssl-devel zlib zlib-devel xz xz-devel

# SQLite3 및 Tkinter 빌드에 필요한 라이브러리 설치
sudo dnf install -y sqlite sqlite-devel tk tk-devel

# uv 설치 전에 기존 uv 디렉토리 제거
if [ -d "$HOME/.uv" ]; then
    echo "기존 uv 디렉토리가 존재합니다. 제거를 진행합니다."
    rm -rf "$HOME/.uv"
fi

# uv 설치
if ! command -v uv &> /dev/null; then
    echo "uv가 설치되어 있지 않습니다. 설치를 진행합니다."
    curl -sSL https://uv.run | bash

    # uv 환경 설정
    export PATH="$HOME/.uv/bin:$PATH"
    eval "$(uv init --path)"
    eval "$(uv init -)"
    eval "$(uv virtualenv-init -)"
fi

# uv PATH 설정 보장
export UV_ROOT="$HOME/.uv"
export PATH="$UV_ROOT/bin:$PATH"
eval "$(uv init --path)"
eval "$(uv init -)"
eval "$(uv virtualenv-init -)"

# zsh 및 bash 환경에서 PATH 설정 확인
echo "현재 PATH: $PATH"
if ! command -v uv &> /dev/null; then
    echo "uv가 PATH에 추가되지 않았습니다. 환경 변수를 다시 확인하세요."
else
    echo "uv가 PATH에 정상적으로 추가되었습니다."
fi

# uv 환경 변수 설정
export UV_ROOT="$HOME/.uv"
export PATH="$UV_ROOT/bin:$PATH"

# zsh 환경에서도 uv 설정 적용
if [ -n "$ZSH_VERSION" ]; then
    echo "zsh 환경에서 uv 설정 적용 중..."
    export PATH="$HOME/.uv/bin:$PATH"
    eval "$(uv init --path)"
    eval "$(uv init - zsh)"
    eval "$(uv virtualenv-init -)"
fi

# bash 환경에서도 uv 설정 적용
if [ -n "$BASH_VERSION" ]; then
    echo "bash 환경에서 uv 설정 적용 중..."
    export PATH="$HOME/.uv/bin:$PATH"
    eval "$(uv init --path)"
    eval "$(uv init - bash)"
    eval "$(uv virtualenv-init -)"
fi

# .zshrc와 .bashrc에 uv 환경 변수 추가
if ! grep -q 'export UV_ROOT="$HOME/.uv"' ~/.zshrc; then
    echo 'export UV_ROOT="$HOME/.uv"' >> ~/.zshrc
    echo 'export PATH="$UV_ROOT/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(uv init --path)"' >> ~/.zshrc
    echo 'eval "$(uv init - zsh)"' >> ~/.zshrc
    echo 'eval "$(uv virtualenv-init -)"' >> ~/.zshrc
    echo "uv 설정이 .zshrc에 추가되었습니다."
fi

if ! grep -q 'export UV_ROOT="$HOME/.uv"' ~/.bashrc; then
    echo 'export UV_ROOT="$HOME/.uv"' >> ~/.bashrc
    echo 'export PATH="$UV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(uv init --path)"' >> ~/.bashrc
    echo 'eval "$(uv init - bash)"' >> ~/.bashrc
    echo 'eval "$(uv virtualenv-init -)"' >> ~/.bashrc
    echo "uv 설정이 .bashrc에 추가되었습니다."
fi

# uv를 통해 Python 3.11.11 설치
if ! uv versions | grep -q "3.11.11"; then
    echo "Python 3.11.11 설치를 진행합니다."
    uv install 3.11.11
fi

# Python 3.11.11을 글로벌 버전으로 설정
uv global 3.11.11

# uv PATH 설정
export PATH="$HOME/.uv/versions/3.11.11/bin:$PATH"

# pip 최신 버전으로 업그레이드
echo "pip 최신 버전으로 업그레이드 중..."
pip install --upgrade pip

# Python 및 pip 버전 확인
echo "설치된 Python 버전: $(python --version)"
echo "설치된 pip 버전: $(pip --version)"

echo "설치가 완료되었습니다. Python 3.11.11 및 최신 pip이 준비되었습니다."