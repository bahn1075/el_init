#!/bin/bash
# RHEL9 계열 OS에서 최신 kubectl 및 helm 설치 스크립트 (SSL 문제 해결)

echo "kubectl 및 helm 설치를 시작합니다..."

# kubectl 설치
echo "kubectl 설치를 진행합니다..."

# SSL 검증 우회하여 최신 버전 확인
KUBECTL_VERSION=$(curl -k -L -s https://dl.k8s.io/release/stable.txt)
if [ $? -ne 0 ]; then
  echo "kubectl 버전 확인에 실패했습니다. 고정 버전을 사용합니다."
  KUBECTL_VERSION="v1.31.0"
fi

echo "kubectl 버전: $KUBECTL_VERSION"

# kubectl 바이너리 다운로드 (SSL 검증 우회)
curl -k -Lo /tmp/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
if [ $? -ne 0 ]; then
  echo "kubectl 바이너리 다운로드에 실패했습니다."
  exit 1
fi

# kubectl 설치
sudo install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
if [ $? -ne 0 ]; then
  echo "kubectl 설치에 실패했습니다."
  exit 1
fi

echo "kubectl 설치가 완료되었습니다."

# helm 설치
echo "helm 설치를 진행합니다..."

# helm 설치 스크립트 다운로드 및 실행 (SSL 검증 우회)
curl -k -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
if [ $? -ne 0 ]; then
  echo "helm 설치에 실패했습니다. 대안 방법을 시도합니다..."
  
  # 대안: 직접 바이너리 다운로드
  HELM_VERSION="v3.15.4"
  curl -k -Lo /tmp/helm.tar.gz "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz"
  if [ $? -eq 0 ]; then
    tar -zxvf /tmp/helm.tar.gz -C /tmp/
    sudo mv /tmp/linux-amd64/helm /usr/local/bin/helm
    sudo chmod +x /usr/local/bin/helm
    echo "helm 대안 설치가 완료되었습니다."
  else
    echo "helm 설치에 완전히 실패했습니다."
    exit 1
  fi
fi

# 임시 파일 정리
rm -f /tmp/kubectl /tmp/helm.tar.gz
rm -rf /tmp/linux-amd64

# 설치 확인
echo "설치된 kubectl 및 helm 버전을 확인합니다..."
echo "kubectl 버전:"
kubectl version --client
echo "helm 버전:"
helm version

echo "kubectl 및 helm 설치가 완료되었습니다."
