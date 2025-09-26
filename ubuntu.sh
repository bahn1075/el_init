# sudo 패스워드 묻지 않음
echo 'cozy ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/cozy

#필수설치
sudo apt install btop zsh curl net-tools git fonts-cascadia-code

# Meslo nerd font
curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.zip -o /tmp/meslo.zip && unzip /tmp/meslo.zip -d /tmp/meslo && sudo mkdir -p /usr/share/fonts/truetype/meslo-nerd && sudo cp /tmp/meslo/*.ttf /usr/share/fonts/truetype/meslo-nerd/ && sudo fc-cache -fv && rm -rf /tmp/meslo*

#ohmyzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#brew 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#brew 설정
echo >> /home/cozy/.zshrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/cozy/.zshrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    
# zsh-syntax-highlighting 설치
cd /tmp
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# .zshrc에 플러그인 추가 (이미 있으면 중복 추가 방지)
if ! grep -q "zsh-syntax-highlighting" ~/.zshrc; then
  sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-syntax-highlighting)/' ~/.zshrc
  # 만약 plugins= 라인이 없다면 추가
  if ! grep -q "^plugins=" ~/.zshrc; then
    echo "plugins=(git kubectl kube-ps1 zsh-syntax-highlighting zsh-autosuggestions)" >> ~/.zshrc
  fi
  # 플러그인 활성화 코드가 없으면 추가
  echo "source \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
fi
source ~/.zshrc

#amd gpu driver
웹페이지 deb 파일 다운로드 후 설치
https://www.amd.com/ko/support/download/linux-drivers.html
위 파일 설치 후
amdgpu-install --usecase=rocm,graphics,hip--vulkan=pro --opencl=rocr --accept-eula -y
설치 후 확인
ls -l /dev/dri/render*
sudo usermod -a -G render $LOGNAME
sudo usermod -a -G video $LOGNAME


wget https://repo.radeon.com/amdgpu-install/7.0.1/ubuntu/noble/amdgpu-install_7.0.1.70001-1_all.deb
sudo apt install ./amdgpu-install_7.0.1.70001-1_all.deb
sudo apt update
sudo apt install python3-setuptools python3-wheel
sudo usermod -a -G render,video $LOGNAME # Add the current user to the render and video groups
sudo apt install rocm




brew install btop starship

# starship 설정 추가
curl -o ~/.config/starship.toml https://raw.githubusercontent.com/bahn1075/el_init/oel10/starship.toml

echo 'eval "$(starship init zsh)"' >> /home/cozy/.zshrc
source ~/.zshrc

# npm 설치
sudo apt install npm -y

# docker
# 기존 버전 삭제
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# apt repo 설정
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# docker 설치
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# 설치 확인
sudo systemctl status docker

# post 작업
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

# docker 확인
docker ps

# minikube install
cd /tmp
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb
#minikube 확인
minikube version

# minikube start
minikube config set cpus 8
minikube config set memory 28672
minikube start --addons=metrics-server,ingress,ingress-dns,logviewer
minikube tunnel

#web logviewer 접속
http://192.168.49.2:32000/

#기동후 amd gpu plugin 설치
kubectl create -f https://raw.githubusercontent.com/ROCm/k8s-device-plugin/master/k8s-ds-amdgpu-dp.yaml

# kubectl 설치
cd /tmp
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# kubectx, kubens 설치
curl -fsSL https://raw.githubusercontent.com/bahn1075/el_init/oel10/72.kubectx_kubens.sh | bash

# k9s 설치
brew install k9s


#######################################################################################################
- Linux Client 링크

https://kcloud.lgcns.com/vmCubeClients/Tilon/linux/Linker-Linux-v8.0.0.2.deb



- 설치 가이드 (현재 설치 방법 간소화 작업 진행 중)

<설치>

1. 다운로드 디렉토리에서 패키지 설치

    - sudo dpkg -i Linker-Linux~~.deb(linker client 파일)

2. 서비스 등록

    - sudo /usr/local/TILON/DstationClient/install.sh

    - /usr/local/TILON/DstationClient/setmime.sh

3. 서비스 상태 확인

    - sudo systemctl status Tservice





1. Firefox 실행

2. 주소창에 about:config 입력

3. 경고 수락

4. network.protocol-handler.expose.dslinker9 을 true로 추가

5. 터미널에서 "update-desktop-database ~/.local/share/applications" 명령어로 MIME DB 갱신

6. Firefox 종료

7. 접속 재시도
