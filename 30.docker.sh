# Docker 및 관련 패키지 제거
sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine \
                  podman \
                  runc

# dnf 플러그인 설치
sudo dnf -y install dnf-plugins-core

# Docker CE 저장소 추가
sudo dnf -y config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

# Docker 및 관련 패키지 설치
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Docker 서비스 활성화 및 시작
sudo systemctl enable --now docker

# Docker 설치 후 설정 단계
# docker 그룹 생성
sudo groupadd docker
# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER
# 그룹 변경 적용
newgrp docker
