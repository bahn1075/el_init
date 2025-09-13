#!/bin/bash

# 스크립트가 루트 권한으로 실행되는지 확인
if [ "$(id -u)" -ne 0 ]; then
  echo "이 스크립트는 루트 권한으로 실행해야 합니다. (예: sudo ./set_nopasswd_sudo.sh)"
  exit 1
fi

# sudo 패키지 설치 확인 및 설치 (Oracle Linux 10)
if ! command -v visudo &> /dev/null; then
  echo "visudo 명령이 없습니다. sudo 패키지를 설치합니다..."
  if command -v dnf &> /dev/null; then
    # Oracle Linux 10은 dnf 사용
    dnf install -y sudo || {
      echo "오류: sudo 패키지 설치에 실패했습니다."
      echo "수동으로 설치해 주세요: dnf install sudo"
      exit 1
    }
  elif command -v yum &> /dev/null; then
    # 구버전 Oracle Linux는 yum 사용
    yum install -y sudo || {
      echo "오류: sudo 패키지 설치에 실패했습니다."
      echo "수동으로 설치해 주세요: yum install sudo"
      exit 1
    }
  else
    echo "패키지 관리자(dnf/yum)를 찾을 수 없습니다."
    echo "수동으로 sudo 패키지를 설치해 주세요."
    exit 1
  fi
  
  # 설치 후 다시 확인
  if ! command -v visudo &> /dev/null; then
    echo "sudo 패키지가 설치되었지만 visudo를 찾을 수 없습니다."
    echo "PATH 문제일 수 있습니다. /usr/sbin/visudo 경로를 확인해 주세요."
    exit 1
  fi
  
  echo "sudo 패키지가 성공적으로 설치되었습니다."
fi

# 사용자 이름 입력받기
read -p "Sudo 설정을 변경할 사용자의 이름을 입력하세요: " target_username

# 사용자 이름이 비어 있는지 확인
if [ -z "$target_username" ]; then
  echo "사용자 이름이 입력되지 않았습니다. 현재 로그인한 사용자($USER)로 진행합니다."
  target_username="$USER"
fi

# 사용자가 시스템에 존재하는지 확인
if ! id "$target_username" &>/dev/null; then
  echo "사용자 '$target_username'을(를) 찾을 수 없습니다. 스크립트를 종료합니다."
  exit 1
fi

# 사용자가 wheel 그룹에 속해 있는지 확인 (sudo 권한 확인)
if groups "$target_username" | grep -q -w wheel; then
  echo "사용자 '$target_username'은(는) sudo 권한(wheel 그룹 소속)을 가지고 있습니다."

  # sudoers 설정 파일 경로 정의
  # 파일 이름은 시스템에서 고유해야 하며, 일반적으로 숫자로 시작하여 로드 순서를 제어할 수 있습니다.
  # 기존 설정과 충돌하지 않도록 주의합니다.
  sudoers_config_file="/etc/sudoers.d/90-nopasswd-${target_username}" # 90- prefix는 다른 기본 설정보다 나중에 적용되도록 함

  # 이미 NOPASSWD 설정이 있는지 간단히 확인 (선택 사항)
  if [ -f "$sudoers_config_file" ] && grep -q "${target_username}.*NOPASSWD" "$sudoers_config_file"; then
    echo "이미 사용자 '$target_username'에 대한 NOPASSWD 설정이 '$sudoers_config_file'에 존재합니다."
    exit 0
  fi

  # /etc/sudoers.d 디렉터리 존재 확인 및 생성
  if [ ! -d "/etc/sudoers.d" ]; then
    echo "/etc/sudoers.d 디렉터리가 없어 생성합니다..."
    mkdir -p /etc/sudoers.d || { echo "디렉터리 생성 실패"; exit 1; }
    chmod 0755 /etc/sudoers.d
  fi

  # NOPASSWD 설정 추가
  echo "사용자 '$target_username'이(가) sudo 실행 시 암호를 입력하지 않도록 설정합니다..."
  
  # 임시 파일에 먼저 작성하여 검증
  tmpfile=$(mktemp /tmp/sudoers_test.XXXXXX) || { echo "임시 파일 생성 실패"; exit 1; }
  echo "$target_username ALL=(ALL) NOPASSWD: ALL" > "$tmpfile"
  
  # visudo로 구문 검증
  if visudo -cf "$tmpfile" 2>/dev/null; then
    # 검증 성공 시 실제 파일로 복사
    cat "$tmpfile" > "$sudoers_config_file"
    chmod 0440 "$sudoers_config_file"
    rm -f "$tmpfile"
    echo "성공: 사용자 '$target_username'은(는) 이제 암호 없이 sudo 명령을 사용할 수 있습니다."
    echo "설정 파일: $sudoers_config_file"
    
    # 전체 sudoers 설정 재검증
    echo "전체 sudoers 설정을 검증합니다..."
    if visudo -c; then
      echo "sudoers 설정이 모두 올바릅니다."
    else
      echo "경고: sudoers 설정에 문제가 있을 수 있습니다. 확인이 필요합니다."
    fi
  else
    echo "오류: sudoers 구문 검증에 실패했습니다."
    echo "임시 파일 내용:"
    cat "$tmpfile"
    rm -f "$tmpfile"
    exit 1
  fi
else
  echo "사용자 '$target_username'은(는) wheel 그룹에 속해있지 않아 sudo 권한이 없는 것으로 보입니다."
  echo "먼저 사용자에게 sudo 권한을 부여해야 합니다. (예: sudo usermod -aG wheel $target_username)"
  exit 1
fi

exit 0
