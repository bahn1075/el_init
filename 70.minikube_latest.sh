#!/bin/bash

# RHEL9 계열 OS에서 최신 Minikube 설치 및 초기 설정 스크립트

echo "Minikube 설치를 시작합니다..."

# 최신 Minikube 안정 버전 (pre-release 제외) 가져오기
echo "GitHub에서 최신 Minikube 안정 버전을 확인합니다..."

# GitHub API를 통해 최신 minikube 안정 릴리즈 정보 가져오기 (pre-release 제외)
LATEST_MINIKUBE_VERSION=$(curl -s https://api.github.com/repos/kubernetes/minikube/releases | jq -r '.[] | select(.prerelease == false) | .tag_name' | head -n1 2>/dev/null)

# API 호출 실패 시 대체 방법 시도
if [ $? -ne 0 ] || [ -z "$LATEST_MINIKUBE_VERSION" ] || [ "$LATEST_MINIKUBE_VERSION" = "null" ]; then
  echo "GitHub API를 통한 minikube 안정 버전 확인에 실패했습니다. 대체 방법을 시도합니다..."
  
  # curl과 grep을 사용한 대체 방법 (stable 버전만)
  LATEST_MINIKUBE_VERSION=$(curl -s https://github.com/kubernetes/minikube/releases | grep -oP 'kubernetes/minikube/tree/v\K[0-9]+\.[0-9]+\.[0-9]+(?=")' | head -n1 2>/dev/null)
  
  if [ -z "$LATEST_MINIKUBE_VERSION" ]; then
    echo "최신 Minikube 안정 버전을 가져오는데 실패했습니다. 기본 다운로드 URL을 사용합니다."
    MINIKUBE_DOWNLOAD_URL="https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"
  else
    LATEST_MINIKUBE_VERSION="v$LATEST_MINIKUBE_VERSION"
    echo "최신 Minikube 안정 버전: $LATEST_MINIKUBE_VERSION (대체 방법으로 확인)"
    MINIKUBE_DOWNLOAD_URL="https://github.com/kubernetes/minikube/releases/download/$LATEST_MINIKUBE_VERSION/minikube-linux-amd64"
  fi
else
  echo "최신 Minikube 안정 버전: $LATEST_MINIKUBE_VERSION (GitHub API로 확인)"
  MINIKUBE_DOWNLOAD_URL="https://github.com/kubernetes/minikube/releases/download/$LATEST_MINIKUBE_VERSION/minikube-linux-amd64"
fi

# Minikube 설치 여부 확인
if ! command -v minikube &> /dev/null; then
  echo "Minikube가 설치되어 있지 않습니다. 설치를 진행합니다..."

  # 동적으로 결정된 다운로드 URL 사용
  echo "다운로드 URL: $MINIKUBE_DOWNLOAD_URL"
  curl -Lo /tmp/minikube-linux-amd64 "$MINIKUBE_DOWNLOAD_URL"
  if [ $? -ne 0 ]; then
    echo "Minikube 바이너리 다운로드에 실패했습니다."
    exit 1
  fi

  sudo install /tmp/minikube-linux-amd64 /usr/local/bin/minikube
  if [ $? -ne 0 ]; then
    echo "Minikube 설치에 실패했습니다."
    exit 1
  fi

  echo "Minikube 설치가 완료되었습니다."
else
  echo "Minikube가 이미 설치되어 있습니다."
fi

# 최신 Kubernetes 안정 버전 (pre-release 제외) 가져오기
echo "GitHub에서 최신 Kubernetes 안정 버전을 확인합니다..."

# GitHub API를 통해 최신 안정 릴리즈 정보 가져오기 (pre-release 제외)
LATEST_K8S_VERSION=$(curl -s https://api.github.com/repos/kubernetes/kubernetes/releases | jq -r '.[] | select(.prerelease == false) | .tag_name' | head -n1 2>/dev/null)

# API 호출 실패 시 대체 방법 시도
if [ $? -ne 0 ] || [ -z "$LATEST_K8S_VERSION" ] || [ "$LATEST_K8S_VERSION" = "null" ]; then
  echo "GitHub API를 통한 Kubernetes 버전 확인에 실패했습니다. 기본값 'latest'를 사용합니다."
  LATEST_K8S_VERSION="latest"
else
  echo "최신 Kubernetes 안정 버전: $LATEST_K8S_VERSION (GitHub API로 확인)"
fi

# 버전 정보 표시
if [ "$LATEST_K8S_VERSION" != "latest" ]; then
  echo "최신 안정 Kubernetes 버전을 사용합니다: $LATEST_K8S_VERSION"
else
  echo "기본값을 사용합니다: latest"
fi

# Minikube 초기 기동 및 설정
echo "Minikube를 초기화하고 설정을 적용합니다..."
minikube start --nodes 2 --cpus=4 --memory=8192 --kubernetes-version=$LATEST_K8S_VERSION
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
