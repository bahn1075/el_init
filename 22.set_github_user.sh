
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
