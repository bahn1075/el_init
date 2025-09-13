#!/bin/bash

# WSL 시작 사용자 설정 및 systemctl 활성화 스크립트
# Oracle Linux/CentOS/RHEL 계열용

# 스크립트가 루트 권한으로 실행되는지 확인
if [ "$(id -u)" -ne 0 ]; then
  echo "이 스크립트는 루트 권한으로 실행해야 합니다. (예: sudo $0)"
  exit 1
fi

# WSL 환경 확인
if ! grep -qi microsoft /proc/version 2>/dev/null && ! grep -qi wsl /proc/version 2>/dev/null; then
  echo "경고: 이 스크립트는 WSL 환경에서 실행하는 것을 권장합니다."
  read -p "계속 진행하시겠습니까? (y/N): " continue_anyway
  if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
    echo "스크립트를 종료합니다."
    exit 0
  fi
fi

echo "=== WSL 시작 설정 스크립트 ==="
echo

# 기본 사용자 입력받기
read -p "WSL 시작 시 사용할 기본 사용자명을 입력하세요: " default_user

# 사용자 이름이 비어 있는지 확인
if [ -z "$default_user" ]; then
  echo "사용자 이름이 입력되지 않았습니다. 스크립트를 종료합니다."
  exit 1
fi

# 사용자명 유효성 검사 (영문자, 숫자, 하이픈, 언더스코어만 허용)
if ! [[ "$default_user" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then
  echo "오류: 유효하지 않은 사용자 이름입니다."
  echo "사용자 이름은 영문 소문자로 시작하고, 영문자, 숫자, 하이픈(-), 언더스코어(_)만 포함할 수 있습니다."
  exit 1
fi

# 사용자가 시스템에 존재하는지 확인
if ! id "$default_user" &>/dev/null; then
  echo "경고: 사용자 '$default_user'이(가) 시스템에 존재하지 않습니다."
  echo "사용자를 생성하거나 올바른 사용자명을 입력해 주세요."
  read -p "계속 진행하시겠습니까? (y/N): " continue_anyway
  if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
    echo "스크립트를 종료합니다."
    exit 1
  fi
fi

echo "설정할 기본 사용자: $default_user"
echo

# /etc/wsl.conf 파일 설정
wsl_conf_file="/etc/wsl.conf"
echo "WSL 설정 파일을 구성합니다: $wsl_conf_file"

# 기존 파일 백업 (있다면)
if [ -f "$wsl_conf_file" ]; then
  timestamp=$(date +%Y%m%d_%H%M%S)
  backup_file="${wsl_conf_file}.backup_${timestamp}"
  cp "$wsl_conf_file" "$backup_file"
  echo "기존 설정 파일을 백업했습니다: $backup_file"
fi

# wsl.conf 내용 생성
cat > "$wsl_conf_file" << EOF
# WSL 설정 파일
# 생성일: $(date)

[boot]
# systemctl 및 systemd 서비스 활성화
systemd=true

[user]
# WSL 시작 시 기본 사용자 설정
default=$default_user

[interop]
# Windows와의 상호 운용성 설정
enabled=true
appendWindowsPath=true

[network]
# 네트워크 설정
generateHosts=true
generateResolvConf=true

[automount]
# Windows 드라이브 자동 마운트 설정
enabled=true
root=/mnt/
options="metadata,uid=1000,gid=1000,umask=022,fmask=011,case=off"
mountFsTab=false
EOF

# 파일 권한 설정
chmod 644 "$wsl_conf_file"

echo "✓ WSL 설정 파일이 생성되었습니다."
echo

# 설정 내용 확인
echo "=== 생성된 설정 내용 ==="
cat "$wsl_conf_file"
echo

# systemd 활성화 안내
echo "=== 추가 안내 사항 ==="
echo "1. systemctl 사용을 위해 systemd=true가 설정되었습니다."
echo "2. WSL을 재시작해야 설정이 적용됩니다."
echo "3. Windows에서 다음 명령으로 WSL을 재시작할 수 있습니다:"
echo "   wsl --shutdown"
echo "   wsl"
echo "4. 재시작 후 다음 명령으로 systemd 상태를 확인할 수 있습니다:"
echo "   systemctl --version"
echo "   ps aux | grep systemd"
echo

# 현재 사용자가 지정한 사용자와 다른 경우 안내
current_user=$(who am i 2>/dev/null | awk '{print $1}' || echo "unknown")
if [ "$current_user" != "unknown" ] && [ "$current_user" != "$default_user" ]; then
  echo "참고: 현재 로그인한 사용자($current_user)와 설정한 기본 사용자($default_user)가 다릅니다."
  echo "WSL 재시작 후에는 '$default_user' 사용자로 자동 로그인됩니다."
fi

echo "✓ WSL 시작 설정이 완료되었습니다."
echo "변경사항을 적용하려면 WSL을 재시작해 주세요."

exit 0