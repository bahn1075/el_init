#!/bin/bash

# Minikube Autoscaler Service 설치 및 등록 스크립트

set -e

SERVICE_NAME="minikube-autoscaler"
SERVICE_FILE="minikube-autoscaler.service"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_PATH="/etc/systemd/system/${SERVICE_NAME}.service"

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 루트 권한 확인
if [ "$EUID" -ne 0 ]; then
    error "이 스크립트는 root 권한으로 실행해야 합니다."
    echo "sudo $0 을 사용하세요."
    exit 1
fi

# 서비스 파일 존재 확인
if [ ! -f "${SCRIPT_DIR}/${SERVICE_FILE}" ]; then
    error "서비스 파일 ${SERVICE_FILE}을 찾을 수 없습니다."
    exit 1
fi

# 스크립트 파일 존재 확인
if [ ! -f "${SCRIPT_DIR}/minikube-autoscaler.sh" ]; then
    error "실행 스크립트 minikube-autoscaler.sh를 찾을 수 없습니다."
    exit 1
fi

log "Minikube Autoscaler 서비스 설치를 시작합니다..."

# 이미 실행 중인 서비스가 있으면 중지
if systemctl is-active --quiet ${SERVICE_NAME}; then
    warning "기존 ${SERVICE_NAME} 서비스가 실행 중입니다. 중지합니다..."
    systemctl stop ${SERVICE_NAME}
fi

# 기존 서비스가 등록되어 있으면 비활성화
if systemctl is-enabled --quiet ${SERVICE_NAME} 2>/dev/null; then
    warning "기존 ${SERVICE_NAME} 서비스가 등록되어 있습니다. 비활성화합니다..."
    systemctl disable ${SERVICE_NAME}
fi

# 스크립트에 실행 권한 부여
chmod +x "${SCRIPT_DIR}/minikube-autoscaler.sh"
success "실행 스크립트에 권한을 부여했습니다."

# 서비스 파일을 systemd 디렉토리로 복사
cp "${SCRIPT_DIR}/${SERVICE_FILE}" "${SERVICE_PATH}"
success "서비스 파일을 복사했습니다: ${SERVICE_PATH}"

# systemd 데몬 리로드
log "systemd 데몬을 리로드합니다..."
systemctl daemon-reload

# 서비스 등록 (부팅 시 자동 시작)
log "서비스를 등록합니다..."
systemctl enable ${SERVICE_NAME}
success "서비스가 등록되었습니다. 부팅 시 자동으로 시작됩니다."

# 서비스 시작
log "서비스를 시작합니다..."
systemctl start ${SERVICE_NAME}

# 서비스 상태 확인
sleep 2
if systemctl is-active --quiet ${SERVICE_NAME}; then
    success "${SERVICE_NAME} 서비스가 성공적으로 시작되었습니다!"
    
    echo ""
    log "서비스 상태 정보:"
    systemctl status ${SERVICE_NAME} --no-pager -l
    
    echo ""
    log "서비스 관리 명령어:"
    echo "  서비스 상태 확인: systemctl status ${SERVICE_NAME}"
    echo "  서비스 중지:     systemctl stop ${SERVICE_NAME}"
    echo "  서비스 시작:     systemctl start ${SERVICE_NAME}"
    echo "  서비스 재시작:   systemctl restart ${SERVICE_NAME}"
    echo "  로그 확인:       journalctl -u ${SERVICE_NAME} -f"
    echo "  서비스 제거:     systemctl disable ${SERVICE_NAME} && rm ${SERVICE_PATH}"
else
    error "${SERVICE_NAME} 서비스 시작에 실패했습니다."
    echo ""
    warning "오류 확인을 위한 로그:"
    journalctl -u ${SERVICE_NAME} --no-pager -l
    exit 1
fi