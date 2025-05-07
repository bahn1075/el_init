#!/bin/bash

# MesloLGS Nerd Font 설치 스크립트
# RHEL9 계열 OS에서 실행

# zip 부터 설치
sudo dnf install zip -y

# 최신 릴리스 정보 가져오기
echo "MesloLGS Nerd Font 최신 버전을 확인 중입니다..."
LATEST_RELEASE=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep "tag_name" | cut -d '"' -f 4)

if [ -z "$LATEST_RELEASE" ]; then
  echo "최신 릴리스 정보를 가져오지 못했습니다. 인터넷 연결을 확인하세요."
  exit 1
fi

echo "최신 릴리스: $LATEST_RELEASE"

# 다운로드 URL 구성
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/$LATEST_RELEASE/Meslo.zip"

# 다운로드 및 설치
if [ -f "Meslo.zip" ]; then
  echo "Meslo.zip 파일이 이미 존재합니다. 다운로드를 건너뜁니다."
else
  echo "MesloLGS Nerd Font를 다운로드 중입니다..."
  curl -LO "$FONT_URL"

  if [ $? -ne 0 ]; then
    echo "폰트 다운로드에 실패했습니다."
    exit 1
  fi
fi

echo "다운로드 완료. 폰트 디렉토리를 확인합니다..."
mkdir -p ~/.local/share/fonts

echo "압축을 해제합니다..."
unzip -o Meslo.zip -d ~/.local/share/fonts

if [ $? -ne 0 ]; then
  echo "압축 해제에 실패했습니다."
  exit 1
fi

# 폰트 캐시 갱신
echo "폰트 캐시를 갱신합니다..."
if ! command -v fc-cache &> /dev/null; then
  echo "fc-cache 명령어를 찾을 수 없습니다. fontconfig 패키지가 설치되어 있는지 확인하세요."
  echo "RHEL 계열 OS에서는 'sudo dnf install fontconfig' 명령어로 설치할 수 있습니다."
  exit 1
fi

fc-cache -fv

if [ $? -ne 0 ]; then
  echo "폰트 캐시 갱신에 실패했습니다."
  exit 1
fi

# 정리
echo "임시 파일을 정리합니다..."
rm -f Meslo.zip

echo "MesloLGS Nerd Font 설치가 완료되었습니다!"
