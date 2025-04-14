#!/bin/bash

# RHEL9 계열 OS에서 최신 kubectl 및 helm 설치 스크립트

echo "kubectl 및 helm 설치를 시작합니다..."

# kubectl 설치
echo "kubectl 설치를 진행합니다..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
if [ $? -ne 0 ]; then
  echo "kubectl 바이너리 다운로드에 실패했습니다."
  exit 1
fi

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
if [ $? -ne 0 ]; then
  echo "kubectl 설치에 실패했습니다."
  exit 1
fi
echo "kubectl 설치가 완료되었습니다."

# helm 설치
echo "helm 설치를 진행합니다..."
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
if [ $? -ne 0 ]; then
  echo "helm 설치에 실패했습니다."
  exit 1
fi
echo "helm 설치가 완료되었습니다."

# 설치 확인
echo "설치된 kubectl 및 helm 버전을 확인합니다..."
kubectl version --client --short
helm version --short

# 설치 완료 메시지 출력
echo "kubectl 및 helm 설치가 완료되었습니다."
echo "kubectl 버전:"
kubectl version
echo "helm 버전:"
helm version
