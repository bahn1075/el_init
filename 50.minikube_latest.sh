#!/bin/bash

# RHEL9 계열 OS에서 최신 Minikube 설치 및 초기 설정 스크립트

echo "Minikube 설치를 시작합니다..."

# Minikube 설치 여부 확인
if ! command -v minikube &> /dev/null; then
  echo "Minikube가 설치되어 있지 않습니다. 설치를 진행합니다..."

  # Minikube 바이너리 다운로드 및 설치
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  if [ $? -ne 0 ]; then
    echo "Minikube 바이너리 다운로드에 실패했습니다."
    exit 1
  fi

  sudo install minikube-linux-amd64 /usr/local/bin/minikube
  if [ $? -ne 0 ]; then
    echo "Minikube 설치에 실패했습니다."
    exit 1
  fi

  echo "Minikube 설치가 완료되었습니다."
else
  echo "Minikube가 이미 설치되어 있습니다."
fi

# Minikube 초기 기동 및 설정
echo "Minikube를 초기화하고 설정을 적용합니다..."
minikube start --cpus=4 --memory=18432
if [ $? -ne 0 ]; then
  echo "Minikube 초기화에 실패했습니다."
  exit 1
fi

# Addons 활성화
echo "Minikube Addons를 활성화합니다..."
minikube addons enable metrics-server
if [ $? -ne 0 ]; then
  echo "metrics-server 활성화에 실패했습니다."
  exit 1
fi

minikube addons enable dashboard
if [ $? -ne 0 ]; then
  echo "dashboard 활성화에 실패했습니다."
  exit 1
fi

echo "Minikube 설치 및 초기 설정이 완료되었습니다."
