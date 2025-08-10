#!/bin/bash

# Minikube 워크로드 기반 노드 자동 스케일링 시뮬레이션 스크립트
# 실제 Cluster Autoscaler 동작을 모방

set -e

# 설정 변수
MIN_NODES=2
MAX_NODES=4
CHECK_INTERVAL=30  # 30초마다 체크
CPU_THRESHOLD=70   # CPU 사용률 임계값 (%)
MEMORY_THRESHOLD=80 # 메모리 사용률 임계값 (%)

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 현재 노드 수 확인
get_current_node_count() {
    kubectl get nodes --no-headers | grep -v "control-plane" | wc -l
}

# 전체 노드 수 확인 (control-plane 포함)
get_total_node_count() {
    kubectl get nodes --no-headers | wc -l
}

# 대기 중인 Pod 수 확인
get_pending_pods() {
    kubectl get pods --all-namespaces --field-selector=status.phase=Pending --no-headers | wc -l
}

# 노드 리소스 사용률 확인
get_node_utilization() {
    local node_name=$1
    
    # CPU 사용률 계산
    local cpu_usage=$(kubectl top node $node_name --no-headers | awk '{print $3}' | sed 's/%//')
    local memory_usage=$(kubectl top node $node_name --no-headers | awk '{print $5}' | sed 's/%//')
    
    echo "$cpu_usage,$memory_usage"
}

# 클러스터 전체 리소스 사용률 확인
check_cluster_utilization() {
    local total_cpu=0
    local total_memory=0
    local node_count=0
    
    log "클러스터 리소스 사용률 확인 중..." >&2
    
    # metrics-server가 없으면 설치
    if ! kubectl get deployment metrics-server -n kube-system &>/dev/null; then
        warning "metrics-server가 없습니다. 설치 중..." >&2
        kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml >&2
        
        # metrics-server가 준비될 때까지 대기
        kubectl patch -n kube-system deployment metrics-server --type=json \
            -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]' >&2
        
        kubectl wait --for=condition=available --timeout=300s deployment/metrics-server -n kube-system >&2
        sleep 30  # 메트릭 수집 대기
    fi
    
    # 각 워커 노드의 사용률 확인
    for node in $(kubectl get nodes --no-headers | grep -v "control-plane" | awk '{print $1}'); do
        if kubectl top node $node &>/dev/null; then
            local utilization=$(get_node_utilization $node)
            local cpu=$(echo $utilization | cut -d',' -f1)
            local memory=$(echo $utilization | cut -d',' -f2)
            
            total_cpu=$((total_cpu + cpu))
            total_memory=$((total_memory + memory))
            node_count=$((node_count + 1))
            
            log "노드 $node: CPU ${cpu}%, Memory ${memory}%" >&2
        fi
    done
    
    if [ $node_count -gt 0 ]; then
        local avg_cpu=$((total_cpu / node_count))
        local avg_memory=$((total_memory / node_count))
        echo "$avg_cpu,$avg_memory"
    else
        echo "0,0"
    fi
}

# 스케일 아웃 (노드 추가)
scale_out() {
    local current_nodes=$(get_current_node_count)
    
    if [ $current_nodes -ge $MAX_NODES ]; then
        warning "최대 노드 수($MAX_NODES)에 도달했습니다."
        return 1
    fi
    
    log "노드를 추가합니다... (현재: $current_nodes -> $((current_nodes + 1)))"
    
    if minikube node add --worker; then
        success "노드가 성공적으로 추가되었습니다!"
        
        # 새 노드가 Ready 상태가 될 때까지 대기
        local max_wait=300
        local wait_time=0
        
        while [ $wait_time -lt $max_wait ]; do
            local new_node_count=$(get_current_node_count)
            if [ $new_node_count -gt $current_nodes ]; then
                if kubectl get nodes | grep -q "Ready"; then
                    success "새 노드가 Ready 상태입니다."
                    break
                fi
            fi
            sleep 10
            wait_time=$((wait_time + 10))
        done
        
        return 0
    else
        error "노드 추가에 실패했습니다."
        return 1
    fi
}

# 스케일 인 (노드 제거)
scale_in() {
    local current_nodes=$(get_current_node_count)
    
    if [ $current_nodes -le $MIN_NODES ]; then
        warning "최소 노드 수($MIN_NODES)에 도달했습니다."
        return 1
    fi
    
    # 가장 적게 사용되는 노드 찾기
    local least_used_node=""
    local min_usage=100
    
    for node in $(kubectl get nodes --no-headers | grep -v "control-plane" | awk '{print $1}'); do
        if kubectl top node $node &>/dev/null; then
            local utilization=$(get_node_utilization $node)
            local cpu=$(echo $utilization | cut -d',' -f1)
            
            if [ $cpu -lt $min_usage ]; then
                min_usage=$cpu
                least_used_node=$node
            fi
        fi
    done
    
    if [ -n "$least_used_node" ] && [ $min_usage -lt 30 ]; then
        log "노드 $least_used_node (CPU: ${min_usage}%)를 제거합니다..."
        
        # 노드의 Pod들을 다른 노드로 이동
        kubectl drain $least_used_node --ignore-daemonsets --delete-emptydir-data --timeout=300s
        
        if minikube node delete $least_used_node; then
            success "노드 $least_used_node가 성공적으로 제거되었습니다!"
            return 0
        else
            error "노드 제거에 실패했습니다."
            kubectl uncordon $least_used_node  # 실패 시 복구
            return 1
        fi
    else
        warning "제거할 수 있는 노드가 없습니다."
        return 1
    fi
}

# 스케일링 결정 로직
make_scaling_decision() {
    local pending_pods=$(get_pending_pods)
    local utilization=$(check_cluster_utilization)
    local avg_cpu=$(echo $utilization | cut -d',' -f1)
    local avg_memory=$(echo $utilization | cut -d',' -f2)
    local current_nodes=$(get_current_node_count)
    
    log "=== 현재 클러스터 상태 ==="
    log "워커 노드 수: $current_nodes"
    log "대기 중인 Pod: $pending_pods"
    log "평균 CPU 사용률: ${avg_cpu}%"
    log "평균 메모리 사용률: ${avg_memory}%"
    log "=========================="
    
    # 스케일 아웃 조건
    if [ "$pending_pods" -gt 0 ] || [ "${avg_cpu:-0}" -gt "$CPU_THRESHOLD" ] || [ "${avg_memory:-0}" -gt "$MEMORY_THRESHOLD" ]; then
        warning "스케일 아웃이 필요합니다!"
        scale_out
    # 스케일 인 조건 (리소스 사용률이 낮고 대기 중인 Pod가 없을 때)
    elif [ "$pending_pods" -eq 0 ] && [ "${avg_cpu:-0}" -lt 30 ] && [ "${avg_memory:-0}" -lt 40 ] && [ "$current_nodes" -gt "$MIN_NODES" ]; then
        warning "스케일 인을 시도합니다."
        scale_in
    else
        log "현재 클러스터 상태가 적절합니다."
    fi
}

# 메인 모니터링 루프
main() {
    log "Minikube 워크로드 기반 오토스케일러 시작"
    log "최소 노드: $MIN_NODES, 최대 노드: $MAX_NODES"
    log "체크 간격: ${CHECK_INTERVAL}초"
    log "CPU 임계값: ${CPU_THRESHOLD}%, 메모리 임계값: ${MEMORY_THRESHOLD}%"
    
    # 초기 클러스터 상태 확인
    if ! kubectl cluster-info &>/dev/null; then
        error "Kubernetes 클러스터에 연결할 수 없습니다."
        exit 1
    fi
    
    # 무한 루프로 모니터링
    while true; do
        make_scaling_decision
        log "다음 체크까지 ${CHECK_INTERVAL}초 대기..."
        sleep $CHECK_INTERVAL
    done
}

# 시그널 처리
trap 'log "오토스케일러를 종료합니다..."; exit 0' INT TERM

# 스크립트 실행
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi