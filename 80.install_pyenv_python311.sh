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

# pyenv 설치 전에 기존 pyenv 디렉토리 제거
if [ -d "$HOME/.pyenv" ]; then
    echo "기존 pyenv 디렉토리가 존재합니다. 제거를 진행합니다."
    rm -rf "$HOME/.pyenv"
fi

# pyenv 설치
if ! command -v pyenv &> /dev/null; then
    echo "pyenv가 설치되어 있지 않습니다. 설치를 진행합니다."
    curl https://pyenv.run | bash

    # pyenv 환경 설정
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# pyenv PATH 설정 보장
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# zsh 및 bash 환경에서 PATH 설정 확인
echo "현재 PATH: $PATH"
if ! command -v pyenv &> /dev/null; then
    echo "pyenv가 PATH에 추가되지 않았습니다. 환경 변수를 다시 확인하세요."
else
    echo "pyenv가 PATH에 정상적으로 추가되었습니다."
fi

# pyenv 환경 변수 설정
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# zsh 환경에서도 pyenv 설정 적용
if [ -n "$ZSH_VERSION" ]; then
    echo "zsh 환경에서 pyenv 설정 적용 중..."
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init - zsh)"
    eval "$(pyenv virtualenv-init -)"
fi

# bash 환경에서도 pyenv 설정 적용
if [ -n "$BASH_VERSION" ]; then
    echo "bash 환경에서 pyenv 설정 적용 중..."
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init - bash)"
    eval "$(pyenv virtualenv-init -)"
fi

# .zshrc와 .bashrc에 pyenv 환경 변수 추가
if ! grep -q 'export PYENV_ROOT="$HOME/.pyenv"' ~/.zshrc; then
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
    echo 'eval "$(pyenv init - zsh)"' >> ~/.zshrc
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc
    echo "pyenv 설정이 .zshrc에 추가되었습니다."
fi

if ! grep -q 'export PYENV_ROOT="$HOME/.pyenv"' ~/.bashrc; then
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
    echo 'eval "$(pyenv init - bash)"' >> ~/.bashrc
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
    echo "pyenv 설정이 .bashrc에 추가되었습니다."
fi

# pyenv를 통해 Python 3.11.11 설치
if ! pyenv versions | grep -q "3.11.11"; then
    echo "Python 3.11.11 설치를 진행합니다."
    pyenv install 3.11.11
fi

# Python 3.11.11을 글로벌 버전으로 설정
pyenv global 3.11.11

# pyenv PATH 설정
export PATH="$HOME/.pyenv/versions/3.11.11/bin:$PATH"

# pip 최신 버전으로 업그레이드
echo "pip 최신 버전으로 업그레이드 중..."
pip install --upgrade pip

# Python 및 pip 버전 확인
echo "설치된 Python 버전: $(python --version)"
echo "설치된 pip 버전: $(pip --version)"

echo "설치가 완료되었습니다. Python 3.11.11 및 최신 pip이 준비되었습니다."