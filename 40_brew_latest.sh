#!/bin/bash

# Homebrew 설치 또는 업데이트 스크립트
# RHEL9 계열 OS에서 실행

echo "Homebrew 설치 또는 업데이트를 확인합니다..."

# Homebrew 설치 여부 확인
if ! command -v brew &> /dev/null; then
  echo "Homebrew가 설치되어 있지 않습니다. 설치를 진행합니다..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ $? -ne 0 ]; then
    echo "Homebrew 설치에 실패했습니다."
    exit 1
  fi

  echo "Homebrew 설치가 완료되었습니다. 환경 변수를 설정합니다..."
  echo >> /home/$USER/.zshrc
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/$USER/.zshrc
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
  echo "Homebrew가 이미 설치되어 있습니다. 최신 버전으로 업데이트를 진행합니다..."
  brew update

  if [ $? -ne 0 ]; then
    echo "Homebrew 업데이트에 실패했습니다."
    exit 1
  fi

  echo "Homebrew가 최신 상태로 업데이트되었습니다."
fi

echo "Homebrew 설치 또는 업데이트가 완료되었습니다."
echo "설치된 Homebrew 버전을 확인합니다..."
brew --version

# source ~/.zshrc는 현재 쉘에 적용되지 않으므로 안내 메시지 추가
echo "변경된 환경 변수를 적용하려면 'source ~/.zshrc'를 직접 실행하세요."
