#!/bin/bash

# Oracle Linux 10 필수 패키지 설치 스크립트
echo "=== Oracle Linux 10 필수 패키지 설치 시작 ==="

# 타임존 설정
echo "타임존을 Asia/Seoul로 설정합니다..."
sudo timedatectl set-timezone Asia/Seoul

# EPEL 리포지토리 추가
echo "EPEL 리포지토리를 추가합니다..."
sudo dnf install epel-release -y

# DNF로 설치 가능한 기본 패키지들
echo "기본 패키지들을 설치합니다..."
sudo dnf install jq tree file zip vim curl zsh wget fontconfig lsof net-tools bind-utils socat -y

# Development Tools 설치
echo "Development Tools을 설치합니다..."
sudo dnf group install "Development Tools" -y

# btop 직접 설치 (Oracle Linux 10에서 dnf로 설치되지 않음)
echo "btop을 직접 다운로드하여 설치합니다..."
if ! command -v btop &> /dev/null; then
    BTOP_VERSION="v1.4.4"
    BTOP_FILE="btop-x86_64-linux-musl.tbz"
    
    echo "btop ${BTOP_VERSION} 다운로드 중..."
    cd /tmp
    curl -L "https://github.com/aristocratos/btop/releases/download/${BTOP_VERSION}/${BTOP_FILE}" -o "${BTOP_FILE}"
    
    if [ $? -eq 0 ]; then
        echo "btop 압축 해제 및 설치 중..."
        tar -xjf "${BTOP_FILE}"
        sudo mv btop/bin/btop /usr/local/bin/
        sudo chmod +x /usr/local/bin/btop
        
        # 테마 디렉터리 생성 및 복사
        sudo mkdir -p /usr/local/share/btop/themes
        sudo cp -r btop/themes/* /usr/local/share/btop/themes/ 2>/dev/null || true
        
        # 정리
        rm -rf btop "${BTOP_FILE}"
        echo "✓ btop 설치 완료"
    else
        echo "⚠️ btop 다운로드 실패, 건너뜁니다."
    fi
else
    echo "✓ btop이 이미 설치되어 있습니다."
fi

# yq 직접 설치 (Oracle Linux 10에서 dnf로 설치되지 않음)
echo "yq를 직접 다운로드하여 설치합니다..."
if ! command -v yq &> /dev/null; then
    YQ_VERSION="v4.47.2"
    YQ_BINARY="yq_linux_amd64"
    
    echo "yq ${YQ_VERSION} 다운로드 중..."
    curl -L "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}" -o /tmp/yq
    
    if [ $? -eq 0 ]; then
        echo "yq 설치 중..."
        sudo mv /tmp/yq /usr/local/bin/yq
        sudo chmod +x /usr/local/bin/yq
        echo "✓ yq 설치 완료"
    else
        echo "⚠️ yq 다운로드 실패, 건너뜁니다."
    fi
else
    echo "✓ yq가 이미 설치되어 있습니다."
fi

# bat 직접 설치 (Oracle Linux 10에서 dnf로 설치되지 않음)
echo "bat을 직접 다운로드하여 설치합니다..."
if ! command -v bat &> /dev/null; then
    BAT_VERSION="v0.25.0"
    BAT_FILE="bat-${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz"
    
    echo "bat ${BAT_VERSION} 다운로드 중..."
    cd /tmp
    curl -L "https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}/${BAT_FILE}" -o "${BAT_FILE}"
    
    if [ $? -eq 0 ]; then
        echo "bat 압축 해제 및 설치 중..."
        tar -xzf "${BAT_FILE}"
        cd "bat-${BAT_VERSION}-x86_64-unknown-linux-musl"
        sudo mv bat /usr/local/bin/
        sudo chmod +x /usr/local/bin/bat
        
        # man page 설치
        sudo mkdir -p /usr/local/share/man/man1
        sudo cp bat.1 /usr/local/share/man/man1/ 2>/dev/null || true
        
        # 정리
        cd /tmp
        rm -rf "bat-${BAT_VERSION}-x86_64-unknown-linux-musl" "${BAT_FILE}"
        echo "✓ bat 설치 완료"
    else
        echo "⚠️ bat 다운로드 실패, 건너뜁니다."
    fi
else
    echo "✓ bat이 이미 설치되어 있습니다."
fi

# fastfetch 직접 설치 (Oracle Linux 10에서 dnf로 설치되지 않음)
echo "fastfetch를 직접 다운로드하여 설치합니다..."
if ! command -v fastfetch &> /dev/null; then
    FASTFETCH_VERSION="2.29.0"
    FASTFETCH_FILE="fastfetch-linux-amd64.tar.gz"
    
    echo "fastfetch v${FASTFETCH_VERSION} 다운로드 중..."
    cd /tmp
    curl -L "https://github.com/fastfetch-cli/fastfetch/releases/download/${FASTFETCH_VERSION}/${FASTFETCH_FILE}" -o "${FASTFETCH_FILE}"
    
    if [ $? -eq 0 ]; then
        echo "fastfetch 압축 해제 및 설치 중..."
        tar -xzf "${FASTFETCH_FILE}"
        cd fastfetch-linux-amd64
        sudo mv usr/bin/fastfetch /usr/local/bin/
        sudo chmod +x /usr/local/bin/fastfetch
        
        # 설정 파일 및 프리셋 복사
        sudo mkdir -p /usr/local/share/fastfetch
        sudo cp -r usr/share/fastfetch/* /usr/local/share/fastfetch/ 2>/dev/null || true
        
        # 정리
        cd /tmp
        rm -rf fastfetch-linux-amd64 "${FASTFETCH_FILE}"
        echo "✓ fastfetch 설치 완료"
    else
        echo "⚠️ fastfetch 다운로드 실패, 건너뜁니다."
    fi
else
    echo "✓ fastfetch가 이미 설치되어 있습니다."
fi

# 시스템 업데이트
echo "시스템을 업데이트합니다..."
sudo dnf update -y

echo "=== 필수 패키지 설치 완료 ==="
echo ""
echo "설치된 도구들:"
echo "- btop: $(/usr/local/bin/btop --version 2>/dev/null | head -1 || echo '설치 실패')"
echo "- yq: $(/usr/local/bin/yq --version 2>/dev/null || echo '설치 실패')"
echo "- jq: $(jq --version 2>/dev/null || echo '설치 실패')"
echo "- tree: $(tree --version 2>/dev/null | head -1 || echo '설치 실패')"
echo "- bat: $(/usr/local/bin/bat --version 2>/dev/null | head -1 || echo '설치 실패')"
echo "- fastfetch: $(/usr/local/bin/fastfetch --version 2>/dev/null | head -1 || echo '설치 실패')"
echo ""
echo "재부팅 후 모든 기능이 정상 동작합니다."
