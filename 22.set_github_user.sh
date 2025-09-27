#!/bin/bash

# GitHub 사용자 설정 스크립트
# Git 전역 설정, SSH 키 생성, GitHub CLI 설정 등을 포함

set -e  # 오류 시 스크립트 중단

echo "=== GitHub 사용자 설정 스크립트 (Ubuntu) ==="
echo "이 스크립트는 Ubuntu에서 GitHub 사용을 위한 환경을 설정합니다."
echo

# 현재 사용자 확인
CURRENT_USER=${SUDO_USER:-$(whoami)}
USER_HOME=$(eval echo ~$CURRENT_USER)

echo "설정 대상 사용자: $CURRENT_USER"
echo "홈 디렉터리: $USER_HOME"

echo

# Git 설치 확인
if ! command -v git &> /dev/null; then
    echo "Git이 설치되지 않았습니다. Git을 먼저 설치해 주세요."
    echo "Ubuntu: sudo apt update && sudo apt install git -y"
    exit 1
fi

echo "✓ Git 버전: $(git --version)"
echo

# 1. Git 전역 사용자 설정
echo "=== 1. Git 전역 사용자 설정 ==="

# 기존 설정 확인
existing_name=$(sudo -u $CURRENT_USER git config --global user.name 2>/dev/null || echo "")
existing_email=$(sudo -u $CURRENT_USER git config --global user.email 2>/dev/null || echo "")

if [ -n "$existing_name" ] && [ -n "$existing_email" ]; then
    echo "기존 Git 설정이 있습니다:"
    echo "  이름: $existing_name"
    echo "  이메일: $existing_email"
    echo
    read -p "기존 설정을 유지하시겠습니까? (y/N): " keep_existing
    if [[ ! "$keep_existing" =~ ^[Yy]$ ]]; then
        existing_name=""
        existing_email=""
    fi
fi

# 사용자 이름 설정
if [ -z "$existing_name" ]; then
    while true; do
        read -p "GitHub 사용자 이름을 입력하세요: " git_username
        if [ -n "$git_username" ]; then
            break
        else
            echo "사용자 이름을 입력해 주세요."
        fi
    done
    sudo -u $CURRENT_USER git config --global user.name "$git_username"
    echo "✓ Git 사용자 이름 설정: $git_username"
else
    git_username="$existing_name"
    echo "✓ 기존 Git 사용자 이름 유지: $git_username"
fi

# 이메일 설정
if [ -z "$existing_email" ]; then
    while true; do
        read -p "GitHub 이메일 주소를 입력하세요: " git_email
        if [ -z "$git_email" ]; then
            echo "이메일을 입력해 주세요."
            continue
        fi
        
        # 이메일 형식 간단 검증
        if [[ ! "$git_email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            echo "올바른 이메일 형식이 아닙니다. 다시 입력해 주세요."
            continue
        fi
        
        break
    done
    
    sudo -u $CURRENT_USER git config --global user.email "$git_email"
    echo "✓ Git 이메일 설정: $git_email"
else
    git_email="$existing_email"
    echo "✓ 기존 Git 이메일 유지: $git_email"
fi

# 추가 Git 설정
echo
echo "추가 Git 설정을 적용합니다..."
sudo -u $CURRENT_USER git config --global init.defaultBranch main
sudo -u $CURRENT_USER git config --global pull.rebase false
sudo -u $CURRENT_USER git config --global core.autocrlf input
sudo -u $CURRENT_USER git config --global core.editor "vim"
echo "✓ Git 기본 설정 완료"

echo

# 2. SSH 키 설정
echo "=== 2. SSH 키 설정 ==="

SSH_DIR="$USER_HOME/.ssh"
SSH_KEY_PATH="$SSH_DIR/id_rsa"
SSH_PUB_KEY_PATH="$SSH_DIR/id_rsa.pub"

# .ssh 디렉터리 생성
if [ ! -d "$SSH_DIR" ]; then
    sudo -u $CURRENT_USER mkdir -p "$SSH_DIR"
    sudo -u $CURRENT_USER chmod 700 "$SSH_DIR"
    echo "✓ .ssh 디렉터리 생성: $SSH_DIR"
fi

# 기존 SSH 키 확인
if [ -f "$SSH_KEY_PATH" ]; then
    echo "기존 SSH 키가 있습니다: $SSH_KEY_PATH"
    read -p "새로운 SSH 키를 생성하시겠습니까? (y/N): " create_new_key
    if [[ ! "$create_new_key" =~ ^[Yy]$ ]]; then
        echo "기존 SSH 키를 사용합니다."
        use_existing_key=true
    fi
fi

# SSH 키 생성
if [ "$use_existing_key" != true ]; then
    echo "SSH 키를 생성합니다..."
    read -p "SSH 키 패스프레이즈를 입력하세요 (엔터로 비워둘 수 있음): " -s ssh_passphrase
    echo
    
    # 기존 키 백업
    if [ -f "$SSH_KEY_PATH" ]; then
        timestamp=$(date +%Y%m%d_%H%M%S)
        sudo -u $CURRENT_USER cp "$SSH_KEY_PATH" "${SSH_KEY_PATH}.backup_${timestamp}"
        sudo -u $CURRENT_USER cp "$SSH_PUB_KEY_PATH" "${SSH_PUB_KEY_PATH}.backup_${timestamp}"
        echo "기존 SSH 키를 백업했습니다."
    fi
    
    # SSH 키 생성 (RSA 4096 비트)
    sudo -u $CURRENT_USER ssh-keygen -t rsa -b 4096 -C "$git_email" -f "$SSH_KEY_PATH" -N "$ssh_passphrase"
    sudo -u $CURRENT_USER chmod 600 "$SSH_KEY_PATH"
    sudo -u $CURRENT_USER chmod 644 "$SSH_PUB_KEY_PATH"
    echo "✓ SSH 키 생성 완료"
fi

# SSH agent 설정
echo
echo "SSH agent 설정을 추가합니다..."
ssh_agent_config="
# SSH agent 자동 시작 설정
if [ -z \"\$SSH_AUTH_SOCK\" ]; then
    eval \"\$(ssh-agent -s)\" > /dev/null
    ssh-add $SSH_KEY_PATH 2>/dev/null
fi"

# 셸 설정 파일에 SSH agent 설정 추가 (중복 방지)
# Ubuntu에서는 zsh나 bash를 사용할 수 있으므로 둘 다 확인
SHELL_RC_ADDED=false

# zsh 사용 중이고 .zshrc가 있으면 zsh 설정 파일에 추가
if [[ "$SHELL" == */zsh ]] && [ -f "$USER_HOME/.zshrc" ]; then
    if ! grep -q "SSH agent 자동 시작 설정" "$USER_HOME/.zshrc" 2>/dev/null; then
        echo "$ssh_agent_config" | sudo -u $CURRENT_USER tee -a "$USER_HOME/.zshrc" > /dev/null
        echo "✓ .zshrc에 SSH agent 자동 시작 설정 추가"
        SHELL_RC_ADDED=true
    fi
fi

# bash 설정 파일에도 추가 (zsh와 병행 사용 가능)
if ! grep -q "SSH agent 자동 시작 설정" "$USER_HOME/.bashrc" 2>/dev/null; then
    echo "$ssh_agent_config" | sudo -u $CURRENT_USER tee -a "$USER_HOME/.bashrc" > /dev/null
    if [ "$SHELL_RC_ADDED" = true ]; then
        echo "✓ .bashrc에도 SSH agent 자동 시작 설정 추가"
    else
        echo "✓ .bashrc에 SSH agent 자동 시작 설정 추가"
    fi
fi

# 공개 키 출력
echo
echo "=== GitHub에 등록할 SSH 공개 키 ==="
echo "다음 공개 키를 GitHub에 등록하세요:"
echo "----------------------------------------"
cat "$SSH_PUB_KEY_PATH"
echo "----------------------------------------"
echo

# 3. GitHub CLI 설치 및 설정
echo "=== 3. GitHub CLI 설정 ==="

# GitHub CLI 설치 확인
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI(gh)가 설치되지 않았습니다."
    read -p "GitHub CLI를 설치하시겠습니까? (y/N): " install_gh
    
    if [[ "$install_gh" =~ ^[Yy]$ ]]; then
        echo "GitHub CLI를 설치합니다..."
        
        # Ubuntu/Debian용 설치
        echo "Ubuntu에서 GitHub CLI를 설치합니다..."
        
        # curl이 없으면 설치
        if ! command -v curl &> /dev/null; then
            sudo apt update
            sudo apt install curl -y
        fi
        
        # GitHub CLI 공식 저장소 추가 및 설치
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install gh -y
        
        if command -v gh &> /dev/null; then
            echo "✓ GitHub CLI 설치 완료: $(gh --version | head -1)"
        else
            echo "GitHub CLI 설치에 실패했습니다."
        fi
    fi
fi

# GitHub CLI 인증 안내
if command -v gh &> /dev/null; then
    echo
    echo "GitHub CLI 인증을 설정합니다."
    echo "다음 명령으로 GitHub에 로그인할 수 있습니다:"
    echo "  gh auth login"
    echo
    read -p "지금 GitHub CLI 인증을 진행하시겠습니까? (y/N): " do_auth
    
    if [[ "$do_auth" =~ ^[Yy]$ ]]; then
        echo "GitHub CLI 인증을 시작합니다..."
        sudo -u $CURRENT_USER gh auth login
    else
        echo "나중에 'gh auth login' 명령으로 인증을 진행하세요."
    fi
fi

echo

# 4. 설정 요약 및 다음 단계 안내
echo "=== 설정 완료 ==="
echo "✓ Git 사용자 설정:"
echo "  이름: $git_username"
echo "  이메일: $git_email"
echo "✓ SSH 키 생성 완료: $SSH_PUB_KEY_PATH"
echo "✓ SSH agent 자동 시작 설정 추가"

if command -v gh &> /dev/null; then
    echo "✓ GitHub CLI 설치 완료"
fi

echo
echo "=== 다음 단계 ==="
echo "1. GitHub 웹사이트(https://github.com/settings/keys)에서 SSH 키를 등록하세요"
echo "2. 위에 출력된 공개 키를 복사하여 GitHub에 추가하세요"
echo "3. SSH 연결 테스트: ssh -T git@github.com"
echo "4. 새 터미널을 열거나 현재 셸에 맞는 설정을 적용하세요:"
echo "   - bash 사용시: source ~/.bashrc"
echo "   - zsh 사용시: source ~/.zshrc"

if command -v gh &> /dev/null; then
    echo "5. GitHub CLI 인증: gh auth login (아직 하지 않았다면)"
fi

echo

# 5. Git 리포지토리 권한 문제 해결
echo "=== 5. Git 리포지토리 권한 확인 및 수정 ==="

# 현재 디렉터리가 Git 리포지토리인지 확인
if [ -d ".git" ]; then
    echo "Git 리포지토리가 발견되었습니다. 권한을 확인합니다..."
    
    # .git 디렉터리 소유권 확인
    git_owner=$(stat -c '%U' .git 2>/dev/null || echo "unknown")
    if [ "$git_owner" != "$CURRENT_USER" ]; then
        echo "⚠️  .git 디렉터리 소유권 문제 발견 (현재 소유자: $git_owner, 필요: $CURRENT_USER)"
        echo "Git 디렉터리 소유권을 $CURRENT_USER로 변경합니다..."
        
        # .git 디렉터리 전체 소유권 변경
        chown -R $CURRENT_USER:$CURRENT_USER .git
        
        # 특히 FETCH_HEAD와 config 파일 권한 확인
        if [ -f ".git/FETCH_HEAD" ]; then
            chown $CURRENT_USER:$CURRENT_USER .git/FETCH_HEAD
            echo "✓ FETCH_HEAD 소유권 수정"
        fi
        
        if [ -f ".git/config" ]; then
            chown $CURRENT_USER:$CURRENT_USER .git/config
            echo "✓ config 파일 소유권 수정"
        fi
        
        echo "✓ Git 디렉터리 소유권이 $CURRENT_USER로 변경되었습니다."
    else
        echo "✓ Git 디렉터리 소유권이 올바릅니다 ($CURRENT_USER)"
    fi
    
    # Git 작업 테스트
    echo
    echo "Git 작업 권한을 테스트합니다..."
    if sudo -u $CURRENT_USER git status >/dev/null 2>&1; then
        echo "✓ Git 작업 권한이 정상입니다"
    else
        echo "⚠️  Git 작업에 여전히 문제가 있을 수 있습니다"
        echo "수동으로 확인해 주세요: git status"
    fi
else
    echo "현재 디렉터리는 Git 리포지토리가 아닙니다."
fi

echo

echo "GitHub 설정이 완료되었습니다! 🎉"

exit 0