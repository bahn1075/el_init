#!/bin/bash

# OEL9 계열 OS에서 kubectx 및 kubens 설치 스크립트

echo "kubectx 및 kubens 설치를 시작합니다..."

# kubectx 및 kubens 설치
KUBECTX_REPO="https://github.com/ahmetb/kubectx"
echo "kubectx 및 kubens를 다운로드합니다..."

git clone $KUBECTX_REPO ~/.kubectx
if [ $? -ne 0 ]; then
  echo "kubectx 및 kubens 다운로드에 실패했습니다."
  exit 1
fi

sudo ln -sf ~/.kubectx/kubectx /usr/local/bin/kubectx
if [ $? -ne 0 ]; then
  echo "kubectx 심볼릭 링크 생성에 실패했습니다."
  exit 1
fi

sudo ln -sf ~/.kubectx/kubens /usr/local/bin/kubens
if [ $? -ne 0 ]; then
  echo "kubens 심볼릭 링크 생성에 실패했습니다."
  exit 1
fi

echo "kubectx 및 kubens 설치가 완료되었습니다."

# 설치 확인
echo "설치된 kubectx 및 kubens 명령어를 확인합니다..."
kubectx --help > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "kubectx 명령어가 제대로 동작하지 않습니다."
  exit 1
fi

kubens --help > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "kubens 명령어가 제대로 동작하지 않습니다."
  exit 1
fi

echo "kubectx 및 kubens 설치가 성공적으로 완료되었습니다."