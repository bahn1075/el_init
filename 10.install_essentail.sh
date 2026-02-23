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

# eza 설치 (OEL10/RHEL에는 dnf 미지원 - GitHub Releases 바이너리 사용)
echo "eza를 설치합니다..."
EZA_URL=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest \
    | grep "browser_download_url" \
    | grep "eza_x86_64-unknown-linux-musl.tar.gz\"" \
    | cut -d '"' -f 4)
if [ -n "$EZA_URL" ]; then
    curl -fsSL "$EZA_URL" -o /tmp/eza.tar.gz
    tar -xzf /tmp/eza.tar.gz -C /tmp
    sudo mv /tmp/eza /usr/local/bin/eza
    rm -f /tmp/eza.tar.gz
    echo "✓ eza $(eza --version | head -1) 설치 완료"
else
    echo "✗ eza 다운로드 URL을 가져오지 못했습니다"
fi

# 시스템 업데이트
echo "시스템을 업데이트합니다..."
sudo dnf update -y

echo "=== 필수 패키지 설치 완료 ==="