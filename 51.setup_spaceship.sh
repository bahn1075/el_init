## spaceship prompt로 변경
brew install spaceship
echo "source $(brew --prefix)/opt/spaceship/spaceship.zsh" >>! ~/.zshrc
#sed -i 's/robbyrussell/spaceship/g' ~/.zshrc
## zshrc/.zshrc 파일을 홈디렉토리로 복사
cp /app/el_init/zshrc/.zshrc ~/.zshrc

# .zshrc 끝에 Spaceship Prompt 관련 설정 추가
cat << 'EOF' >> ~/.zshrc

SPACESHIP_KUBECTL_CONTEXT_COLOR_GROUPS=(
  # red if namespace is "kube-system"
  red    '\(kube-system)$'

  # else, green if "dev-01" is anywhere in the context or namespace
  green  dev-01

  # else, red if context name ends with ".k8s.local" _and_ namespace is "system"
  red    '\.k8s\.local \(system)$'

  # else, yellow if the entire content is "test-" followed by digits, and no namespace is displayed
  yellow '^test-[0-9]+$'
)

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
source /home/linuxbrew/.linuxbrew/opt/spaceship/spaceship.zsh

# kubectl section 설정
SPACESHIP_KUBECTL_SHOW=true
SPACESHIP_KUBECTL_ASYNC=true
SPACESHIP_KUBECTL_PREFIX=" "
SPACESHIP_KUBECTL_SUFFIX=$SPACESHIP_PROMPT_DEFAULT_SUFFIX
#SPACESHIP_KUBECTL_SYMBOL="☸️ "
SPACESHIP_KUBECTL_COLOR="cyan"

SPACESHIP_KUBECTL_VERSION_SHOW=true
SPACESHIP_KUBECTL_VERSION_ASYNC=true
SPACESHIP_KUBECTL_VERSION_COLOR="green"

SPACESHIP_KUBECTL_CONTEXT_SHOW=true
SPACESHIP_KUBECTL_CONTEXT_SHOW_NAMESPACE=true
SPACESHIP_KUBECTL_CONTEXT_COLOR="yellow"

SPACESHIP_KUBECTL_CONTEXT_COLOR_GROUPS=(
  red   '^buildcenter-aks-aiagent-prd \(.*\)$'
  blue  '^buildcenter-aks-aiagent \(.*\)$'
)

# prompt 순서
SPACESHIP_PROMPT_ORDER=(
  time
  user
  dir
  git
  kubectl
  exec_time
  line_sep
  jobs
  exit_code
  char
)

# custom 영역
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

npx oh-my-logo "MY WSL" sunset --filled

EOF

## 현재 사용자의 기본 shell을 zsh로 변경
sudo usermod -s /usr/bin/zsh $USER

