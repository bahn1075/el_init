#!/bin/bash

# RHEL9 계열 OS에서 최신 Minikube 설치 및 초기 설정 스크립트

echo "Minikube 설치 또는 업데이트를 시작합니다..."

# 최신 Minikube 버전 가져오기
LATEST_VERSION=$(curl -s https://api.github.com/repos/kubernetes/minikube/releases/latest | grep tag_name | cut -d '"' -f 4)
if [ -z "$LATEST_VERSION" ]; then
  echo "최신 Minikube 버전을 가져오는 데 실패했습니다."
  # 필요시 기본 버전 설정 또는 오류 처리
  # LATEST_VERSION="v1.30.1" # 예시: 특정 버전으로 대체
  exit 1
fi
echo "최신 Minikube 버전: $LATEST_VERSION"

# Minikube 설치 여부 확인
if command -v minikube &> /dev/null; then
  INSTALLED_VERSION=$(minikube version --short)
  echo "설치된 Minikube 버전: $INSTALLED_VERSION"

  # 버전 비교 및 업그레이드
  if [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then
    echo "최신 버전($LATEST_VERSION)이 아닙니다. 업그레이드를 진행합니다..."

    # Minikube 바이너리 다운로드 및 설치
    curl -Lo minikube-linux-amd64 "https://storage.googleapis.com/minikube/releases/$LATEST_VERSION/minikube-linux-amd64"
    if [ $? -ne 0 ]; then
      echo "Minikube 바이너리 다운로드에 실패했습니다."
      exit 1
    fi

    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    if [ $? -ne 0 ]; then
      echo "Minikube 업그레이드에 실패했습니다."
      exit 1
    fi
    rm minikube-linux-amd64 # 다운로드한 파일 삭제

    echo "Minikube가 $LATEST_VERSION 버전으로 업그레이드되었습니다."
  else
    echo "Minikube가 이미 최신 버전입니다."
  fi
else
  echo "Minikube가 설치되어 있지 않습니다. 최신 버전($LATEST_VERSION) 설치를 진행합니다..."

  # Minikube 바이너리 다운로드 및 설치
  curl -Lo minikube-linux-amd64 "https://storage.googleapis.com/minikube/releases/$LATEST_VERSION/minikube-linux-amd64"
  if [ $? -ne 0 ]; then
    echo "Minikube 바이너리 다운로드에 실패했습니다."
    exit 1
  fi

  sudo install minikube-linux-amd64 /usr/local/bin/minikube
  if [ $? -ne 0 ]; then
    echo "Minikube 설치에 실패했습니다."
    exit 1
  fi
  rm minikube-linux-amd64 # 다운로드한 파일 삭제

  echo "Minikube 설치가 완료되었습니다."
fi

# Minikube 초기 기동 및 설정
echo "Minikube를 초기화하고 설정을 적용합니다..."

# 최신 Kubernetes 릴리스 버전 가져오기 (GitHub API 사용)
echo "최신 Kubernetes 릴리스 버전을 확인합니다 (GitHub)..."
# GitHub API는 속도 제한이 있을 수 있으므로 주의
K8S_LATEST_RELEASE_TAG=$(curl -s https://api.github.com/repos/kubernetes/kubernetes/releases/latest | grep tag_name | cut -d '"' -f 4)
if [ -z "$K8S_LATEST_RELEASE_TAG" ]; then
  echo "최신 Kubernetes 릴리스 버전을 GitHub API에서 가져오는 데 실패했습니다."
  # 대체 방법: stable.txt 사용 시도 또는 오류 종료
  echo "대체 방법으로 stable.txt를 사용합니다..."
  K8S_LATEST_RELEASE_TAG=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
  if [ -z "$K8S_LATEST_RELEASE_TAG" ]; then
    echo "stable.txt에서도 최신 버전을 가져오는 데 실패했습니다."
    exit 1
  fi
fi
echo "최신 Kubernetes 릴리스 버전: $K8S_LATEST_RELEASE_TAG"

# Minikube를 최신 Kubernetes 릴리스 버전으로 시작
minikube start --cpus=4 --memory=18432 --kubernetes-version=$K8S_LATEST_RELEASE_TAG
if [ $? -ne 0 ]; then
  # 시작 실패 시, 기존 클러스터 버전으로 재시도하는 로직 추가 가능
  echo "Minikube 초기화에 실패했습니다."
  echo "기존 클러스터가 있고 버전 충돌이 발생했을 수 있습니다."
  echo "기존 클러스터 버전으로 시작을 시도하려면 'minikube start'를 직접 실행해 보세요."
  # 또는 'minikube delete' 후 재시도 제안
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
