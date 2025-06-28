#!/bin/bash

# 스크립트가 루트 권한으로 실행되는지 확인
if [ "$(id -u)" -ne 0 ]; then
  echo "이 스크립트는 루트 권한으로 실행해야 합니다. (예: sudo ./set_nopasswd_sudo.sh)"
  exit 1
fi

# 사용자 이름 입력받기
read -p "Sudo 설정을 변경할 사용자의 이름을 입력하세요: " target_username

# 사용자 이름이 비어 있는지 확인
if [ -z "$target_username" ]; then
  echo "사용자 이름이 입력되지 않았습니다. 스크립트를 종료합니다."
  exit 1
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

  # NOPASSWD 설정 추가
  echo "사용자 '$target_username'이(가) sudo 실행 시 암호를 입력하지 않도록 설정합니다..."
  echo "$target_username ALL=(ALL) NOPASSWD: ALL" > "$sudoers_config_file"

  # 생성된 파일의 권한 설정 (중요)
  chmod 0440 "$sudoers_config_file"

  if [ $? -eq 0 ]; then
    echo "성공: 사용자 '$target_username'은(는) 이제 암호 없이 sudo 명령을 사용할 수 있습니다."
    echo "설정 파일: $sudoers_config_file"
  else
    echo "오류: sudoers 설정 파일 생성 또는 권한 변경에 실패했습니다."
    # 실패 시 생성된 파일 삭제 (선택 사항)
    # rm -f "$sudoers_config_file"
    exit 1
  fi
else
  echo "사용자 '$target_username'은(는) wheel 그룹에 속해있지 않아 sudo 권한이 없는 것으로 보입니다."
  echo "먼저 사용자에게 sudo 권한을 부여해야 합니다. (예: sudo usermod -aG wheel $target_username)"
  exit 1
fi

exit 0
