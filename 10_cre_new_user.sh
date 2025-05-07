#!/bin/bash

# 스크립트가 루트 권한으로 실행되는지 확인
if [ "$(id -u)" -ne 0 ]; then
  echo "이 스크립트는 루트 권한으로 실행해야 합니다. (예: sudo ./create_sudo_user_forced_pw_change.sh)"
  exit 1
fi

# 새 사용자 이름 입력받기
read -p "생성할 새 사용자의 이름을 입력하세요: " username

# 사용자 이름이 비어 있는지 확인
if [ -z "$username" ]; then
  echo "사용자 이름이 입력되지 않았습니다. 스크립트를 종료합니다."
  exit 1
fi

# 사용자가 이미 존재하는지 확인
if id "$username" &>/dev/null; then
  echo "사용자 '$username'은(는) 이미 존재합니다. 스크립트를 종료합니다."
  exit 1
fi

# 사용자 생성 (-m 옵션으로 홈 디렉토리 생성)
useradd -m "$username"
if [ $? -ne 0 ]; then
  echo "사용자 '$username' 생성에 실패했습니다."
  exit 1
fi
echo "사용자 '$username'이(가) 성공적으로 생성되었습니다."

# 초기 암호 설정 ('Pass' + 사용자명 + '1234!')
initial_password="Pass${username}1234!"
echo "설정될 초기 암호: ${initial_password}" # 디버깅 또는 확인용
echo "${username}:${initial_password}" | chpasswd
if [ $? -ne 0 ]; then
  echo "'$username' 사용자의 초기 암호 설정에 실패했습니다."
  userdel -r "$username" # 실패 시 사용자 삭제
  exit 1
fi
echo "'$username' 사용자의 초기 암호가 성공적으로 설정되었습니다."

# 첫 로그인 시 암호 변경 강제
chage -d 0 "$username"
if [ $? -ne 0 ]; then
  echo "'$username' 사용자의 암호 변경 강제 설정에 실패했습니다."
  # 실패 시 롤백 고려 (예: 사용자 삭제 또는 경고 후 계속)
  # userdel -r "$username"
  exit 1
fi
echo "'$username' 사용자는 다음 로그인 시 암호를 변경해야 합니다."

# 사용자에게 sudo 권한 부여 (wheel 그룹에 추가)
usermod -aG wheel "$username"
if [ $? -ne 0 ]; then
  echo "'$username' 사용자에게 sudo 권한 부여(wheel 그룹 추가)에 실패했습니다."
  exit 1
fi
echo "'$username' 사용자에게 sudo 권한이 성공적으로 부여되었습니다."

echo "모든 작업이 완료되었습니다."
echo "새 사용자 '$username'의 초기 암호는 '${initial_password}' 입니다."
echo "해당 사용자로 처음 로그인하면 암호를 변경해야 합니다."
echo "예: ssh ${username}@<서버주소>"

exit 0
