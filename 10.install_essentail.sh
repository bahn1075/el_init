#!/bin/bash

# Oracle Linux 10 필수 패키지 설치 스크립트
echo "=== Oracle Linux 10 필수 패키지 설치 시작 ==="

# 타임존 설정
echo "타임존을 Asia/Seoul로 설정합니다..."
sudo timedatectl set-timezone Asia/Seoul

# EPEL 리포지토리 추가
echo "EPEL 리포지토리를 추가합니다..."
sudo dnf install -y oracle-epel-release-el10

# DNF로 설치 가능한 기본 패키지들
echo "기본 패키지들을 설치합니다..."
sudo dnf install fastfetch gh bat btop jq tree file zip vim curl zsh wget fontconfig yq lsof net-tools bind-utils socat -y

# Development Tools 설치
echo "Development Tools을 설치합니다..."
sudo dnf group install "Development Tools" -y

# 아키텍처 감지
ARCH=$(uname -m)

# eza 설치 (OEL10/RHEL에는 dnf 미지원 - GitHub Releases 바이너리 사용)
echo "eza를 설치합니다..."
EZA_VERSION=$(curl -sI https://github.com/eza-community/eza/releases/latest 2>/dev/null \
    | grep -i "^location:" | tr -d '\r' | sed 's|.*/tag/||')
if [ -n "$EZA_VERSION" ]; then
    EZA_URL="https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_${ARCH}-unknown-linux-musl.tar.gz"
    curl -fsSL "$EZA_URL" -o /tmp/eza.tar.gz
    tar -xzf /tmp/eza.tar.gz -C /tmp
    sudo mv /tmp/eza /usr/local/bin/eza
    rm -f /tmp/eza.tar.gz
    echo "✓ eza $(eza --version | head -1) 설치 완료"
else
    echo "✗ eza 버전 정보를 가져오지 못했습니다"
fi

# superfile 설치 (GitHub Releases 바이너리 사용)
echo "superfile을 설치합니다..."
# 아키텍처 매핑 (uname -m → superfile 릴리즈 표기)
case "$ARCH" in
    x86_64)  SPF_ARCH="amd64" ;;
    aarch64) SPF_ARCH="arm64" ;;
    armv7l)  SPF_ARCH="arm" ;;
    *)       SPF_ARCH="$ARCH" ;;
esac
SPF_VERSION=$(curl -sI https://github.com/yorukot/superfile/releases/latest 2>/dev/null \
    | grep -i "^location:" | tr -d '\r' | sed 's|.*/tag/||')
if [ -n "$SPF_VERSION" ]; then
    SPF_URL="https://github.com/yorukot/superfile/releases/download/${SPF_VERSION}/superfile-linux-${SPF_VERSION}-${SPF_ARCH}.tar.gz"
    curl -fsSL "$SPF_URL" -o /tmp/superfile.tar.gz
    tar -xzf /tmp/superfile.tar.gz -C /tmp
    sudo mv /tmp/dist/superfile-linux-${SPF_VERSION}-${SPF_ARCH}/spf /usr/local/bin/spf
    rm -rf /tmp/superfile.tar.gz /tmp/dist
    echo "✓ superfile $(spf --version 2>/dev/null | head -1) 설치 완료"
else
    echo "✗ superfile 버전 정보를 가져오지 못했습니다"
fi

# 시스템 업데이트
echo "시스템을 업데이트합니다..."
sudo dnf update -y

echo "=== 필수 패키지 설치 완료 ==="