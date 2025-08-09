#!/bin/bash

# oh-my-logo 설치 스크립트
# 최신 npm 설치부터 oh-my-logo Global Installation (CLI) 설치 및 테스트

set -e  # 에러 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 단계별 진행 상황 표시
step=1
total_steps=6

print_step() {
    echo -e "\n${BLUE}=== Step ${step}/${total_steps}: $1 ===${NC}\n"
    ((step++))
}

# Node.js 및 npm 설치 여부 확인
check_nodejs() {
    print_step "Node.js 및 npm 확인"
    
    if command -v node >/dev/null 2>&1; then
        log_info "Node.js 버전: $(node --version)"
    else
        log_warning "Node.js가 설치되지 않았습니다. Node.js를 먼저 설치해주세요."
        return 1
    fi
    
    if command -v npm >/dev/null 2>&1; then
        log_info "npm 버전: $(npm --version)"
    else
        log_error "npm이 설치되지 않았습니다."
        return 1
    fi
}

# npm 최신 버전으로 업데이트
update_npm() {
    print_step "npm을 최신 버전으로 업데이트"
    
    log_info "현재 npm 버전: $(npm --version)"
    log_info "npm을 최신 버전으로 업데이트 시도 중..."
    
    # sudo 권한이 있는지 확인하고 업데이트 시도
    if sudo -n true 2>/dev/null; then
        sudo npm install -g npm@latest
        log_success "npm 업데이트 완료! 새 버전: $(npm --version)"
    else
        log_warning "sudo 권한이 없어 npm 업데이트를 건너뜁니다."
        log_info "수동으로 업데이트하려면: sudo npm install -g npm@latest"
    fi
}

# figlet 설치 확인 (oh-my-logo의 의존성)
check_figlet() {
    print_step "figlet 설치 확인"
    
    if command -v figlet >/dev/null 2>&1; then
        # figlet 버전 정보를 안전하게 가져오기
        figlet_info=$(figlet -v 2>&1 | head -n1 || echo "figlet installed")
        log_info "figlet이 이미 설치되어 있습니다: $figlet_info"
    else
        log_warning "figlet이 설치되지 않았습니다. 설치 중..."
        
        # OS에 따른 figlet 설치
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get update && sudo apt-get install -y figlet
            elif command -v yum >/dev/null 2>&1; then
                sudo yum install -y figlet
            elif command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y figlet
            elif command -v pacman >/dev/null 2>&1; then
                sudo pacman -S --noconfirm figlet
            else
                log_error "지원되지 않는 Linux 배포판입니다. figlet을 수동으로 설치해주세요."
                return 1
            fi
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            if command -v brew >/dev/null 2>&1; then
                brew install figlet
            else
                log_error "Homebrew가 설치되지 않았습니다. figlet을 수동으로 설치해주세요."
                return 1
            fi
        else
            log_error "지원되지 않는 OS입니다. figlet을 수동으로 설치해주세요."
            return 1
        fi
        
        log_success "figlet 설치 완료!"
    fi
}

# oh-my-logo Global Installation (CLI) 또는 npx 사용
install_oh_my_logo() {
    print_step "oh-my-logo 설치 및 확인"
    
    # 이미 전역으로 설치되어 있는지 확인
    if command -v oh-my-logo >/dev/null 2>&1; then
        log_info "oh-my-logo가 이미 전역으로 설치되어 있습니다."
        log_info "버전 정보:"
        oh-my-logo --version
        return 0
    fi
    
    # 전역 설치 시도 (sudo 권한이 있는 경우)
    if sudo -n true 2>/dev/null; then
        log_info "sudo 권한이 있습니다. oh-my-logo를 전역으로 설치 중..."
        sudo npm install -g oh-my-logo
        
        if command -v oh-my-logo >/dev/null 2>&1; then
            log_success "oh-my-logo 전역 설치 완료!"
            log_info "버전 정보:"
            oh-my-logo --version
            return 0
        fi
    fi
    
    # 전역 설치 실패 시 npx 사용 확인
    log_warning "전역 설치에 실패했거나 sudo 권한이 없습니다."
    log_info "npx를 통한 oh-my-logo 사용 가능 여부를 확인합니다..."
    
    # npx로 oh-my-logo 실행 테스트
    if npx --yes oh-my-logo --version >/dev/null 2>&1; then
        log_success "npx를 통해 oh-my-logo를 사용할 수 있습니다!"
        log_info "버전 정보:"
        npx --yes oh-my-logo --version
        return 0
    else
        log_error "oh-my-logo 설치 및 npx 실행에 모두 실패했습니다."
        log_info "수동 설치 방법:"
        log_info "1. sudo npm install -g oh-my-logo (관리자 권한)"
        log_info "2. 또는 npx oh-my-logo \"TEXT\" (매번 다운로드)"
        return 1
    fi
}

# 사용 가능한 팔레트 확인
check_palettes() {
    print_step "사용 가능한 팔레트 확인"
    
    # oh-my-logo 실행 방법 결정
    local cmd_prefix=""
    if command -v oh-my-logo >/dev/null 2>&1; then
        cmd_prefix="oh-my-logo"
    else
        cmd_prefix="npx --yes oh-my-logo"
    fi
    
    log_info "oh-my-logo에서 사용 가능한 색상 팔레트:"
    echo ""
    $cmd_prefix "" --list-palettes
}

# oh-my-logo 테스트
test_oh_my_logo() {
    print_step "oh-my-logo 테스트"
    
    # oh-my-logo 실행 방법 결정
    local cmd_prefix=""
    if command -v oh-my-logo >/dev/null 2>&1; then
        cmd_prefix="oh-my-logo"
        log_info "전역 설치된 oh-my-logo를 사용합니다."
    else
        cmd_prefix="npx --yes oh-my-logo"
        log_info "npx를 통해 oh-my-logo를 사용합니다."
    fi
    
    log_info "테스트 실행: $cmd_prefix \"INSTALLED!\""
    echo ""
    $cmd_prefix "INSTALLED!"
    echo ""
    
    log_info "추가 테스트 - 다양한 스타일:"
    echo ""
    
    # sunset 팔레트로 테스트
    log_info "Sunset 팔레트 테스트:"
    $cmd_prefix "SUCCESS" sunset
    echo ""
    
    # matrix 팔레트 filled 모드로 테스트
    log_info "Matrix 팔레트 (filled) 테스트:"
    $cmd_prefix "MATRIX" matrix --filled
    echo ""
    
    # 다중 라인 테스트
    log_info "다중 라인 테스트:"
    $cmd_prefix "OH\nMY\nLOGO" ocean
    echo ""
    
    log_success "모든 테스트가 성공적으로 완료되었습니다!"
}

# 메인 실행 함수
main() {
    echo -e "${GREEN}"
    echo "=================================================="
    echo "     oh-my-logo 설치 및 설정 스크립트"
    echo "=================================================="
    echo -e "${NC}"
    
    # 각 단계별 실행
    check_nodejs || exit 1
    update_npm || exit 1
    check_figlet || exit 1
    install_oh_my_logo || exit 1
    check_palettes || exit 1
    test_oh_my_logo || exit 1
    
    echo ""
    echo -e "${GREEN}=================================================="
    echo "🎉 oh-my-logo 설치 및 설정이 완료되었습니다! 🎉"
    echo "=================================================="
    echo -e "${NC}"
    echo ""
    echo -e "${BLUE}사용법:${NC}"
    echo "  oh-my-logo \"YOUR TEXT\"                    # 기본 ASCII 아트"
    echo "  oh-my-logo \"YOUR TEXT\" sunset             # sunset 팔레트 사용"
    echo "  oh-my-logo \"YOUR TEXT\" matrix --filled    # matrix 팔레트, filled 모드"
    echo "  oh-my-logo \"LINE1\\nLINE2\" ocean           # 다중 라인"
    echo "  oh-my-logo --gallery \"TEXT\"               # 모든 팔레트로 미리보기"
    echo "  oh-my-logo --list-palettes                 # 사용 가능한 팔레트 목록"
    echo ""
    echo -e "${BLUE}더 많은 정보:${NC}"
    echo "  GitHub: https://github.com/shinshin86/oh-my-logo"
    echo "  README: https://github.com/shinshin86/oh-my-logo/blob/main/README.md"
    echo ""
}

# 스크립트 실행
main "$@"
