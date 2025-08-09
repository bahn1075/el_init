# Minikube 워크로드 기반 노드 자동 스케일링

Minikube 환경에서 워크로드 기반 노드 자동 스케일링을 시뮬레이션하는 프로젝트입니다. 실제 클라우드 환경의 Cluster Autoscaler 동작을 모방하여 CPU/메모리 사용률과 대기 중인 Pod를 기반으로 노드를 자동으로 추가/제거합니다.

## 🎯 주요 기능

- **워크로드 기반 자동 스케일링**: CPU/메모리 사용률 및 대기 중인 Pod 수를 모니터링
- **동적 노드 관리**: 최소/최대 노드 수 범위 내에서 자동 노드 추가/제거
- **실시간 모니터링**: 30초 간격으로 클러스터 상태 체크
- **안전한 스케일 인**: 사용률이 낮은 노드를 안전하게 드레인 후 제거
- **테스트 워크로드 제공**: 스케일링 동작을 검증할 수 있는 다양한 워크로드

## 📋 사전 요구사항

### 필수 도구
- **Minikube** (최신 버전 권장)
- **kubectl** (Kubernetes CLI)
- **Docker** (Minikube 드라이버로 사용)
- **Bash** (스크립트 실행용)

### 시스템 요구사항
- **CPU**: 최소 4코어 (권장 8코어)
- **메모리**: 최소 8GB (권장 16GB)
- **디스크**: 최소 20GB 여유 공간

## 🚀 빠른 시작

### 1. 프로젝트 클론 및 설정

```bash
# 프로젝트 디렉토리 생성
mkdir minikube-autoscaler && cd minikube-autoscaler

# 스크립트 파일 생성 (위에서 제공된 스크립트 복사)
# minikube-autoscaler.sh 파일 생성
# workload-test-manifests.yaml 파일 생성

# 실행 권한 부여
chmod +x minikube-autoscaler.sh
```

### 2. Minikube 클러스터 시작

```bash
# 기본 2노드로 클러스터 시작 (1 control-plane + 1 worker)
minikube start --nodes=2 --cpus=4 --memory=8192 --driver=docker

# 더 많은 리소스가 필요한 경우
minikube start --nodes=2 --cpus=8 --memory=16384 --disk-size=30g --driver=docker
```

### 3. Metrics Server 설치 및 설정

```bash
# Metrics Server 설치
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Minikube용 설정 패치
kubectl patch -n kube-system deployment metrics-server --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

# Metrics Server 준비 완료 대기
kubectl wait --for=condition=available --timeout=300s deployment/metrics-server -n kube-system

# 메트릭 수집 안정화 대기 (약 1-2분)
sleep 60
```

### 4. 오토스케일러 실행

```bash
# 백그라운드에서 실행
./minikube-autoscaler.sh &

# 또는 로그와 함께 포그라운드에서 실행
./minikube-autoscaler.sh

# 로그 파일로 저장하면서 실행
./minikube-autoscaler.sh 2>&1 | tee autoscaler.log
```

## 🧪 테스트 워크로드 배포

### 기본 테스트 워크로드

```bash
# 모든 테스트 워크로드 배포
kubectl apply -f workload-test-manifests.yaml

# 개별 워크로드 배포
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cpu-stress-test
spec:
  replicas: 3
  selector:
    matchLabels:
      app: cpu-stress
  template:
    metadata:
      labels:
        app: cpu-stress
    spec:
      containers:
      - name: stress
        image: polinux/stress
        command: ["stress"]
        args: ["--cpu", "2", "--timeout", "600s"]
        resources:
          requests:
            cpu: "1000m"
            memory: "1Gi"
          limits:
            cpu: "2000m"
            memory: "2Gi"
EOF
```

### 스케일 아웃 트리거

```bash
# 대량 Pod 생성으로 스케일 아웃 강제 트리거
kubectl scale deployment distributed-workload --replicas=10

# 리소스 집약적 Job 실행
kubectl create job heavy-workload --image=polinux/stress -- stress --cpu 4 --vm 2 --vm-bytes 2G --timeout 300s

# HPA를 통한 자동 확장 테스트
kubectl autoscale deployment stress-test-workload --cpu-percent=50 --min=1 --max=15
```

### 스케일 인 트리거

```bash
# 워크로드 축소
kubectl scale deployment stress-test-workload --replicas=1
kubectl scale deployment distributed-workload --replicas=2

# Job 삭제
kubectl delete jobs --all
```

## 📊 모니터링 및 확인

### 실시간 클러스터 상태 모니터링

```bash
# 노드 상태 실시간 확인
watch "kubectl get nodes -o wide"

# 리소스 사용률 모니터링
watch "kubectl top nodes"

# Pod 분산 상태 확인
watch "kubectl get pods -o wide --all-namespaces"

# 오토스케일러 로그 확인
tail -f autoscaler.log
```

### 스케일링 이벤트 확인

```bash
# 클러스터 이벤트 확인
kubectl get events --sort-by='.lastTimestamp'

# 노드 상세 정보
kubectl describe nodes

# Pod 스케줄링 상태 확인
kubectl get pods --all-namespaces --field-selector=status.phase=Pending
```

## ⚙️ 설정 사용자화

### 오토스케일러 파라미터 수정

스크립트 상단의 설정 변수를 수정하여 동작을 사용자화할 수 있습니다:

```bash
# minikube-autoscaler.sh 파일에서 수정
MIN_NODES=2           # 최소 워커 노드 수
MAX_NODES=5           # 최대 워커 노드 수
CHECK_INTERVAL=30     # 체크 간격 (초)
CPU_THRESHOLD=70      # CPU 사용률 임계값 (%)
MEMORY_THRESHOLD=80   # 메모리 사용률 임계값 (%)
```

### Minikube 클러스터 설정

```bash
# 더 많은 초기 노드로 시작
minikube start --nodes=3 --cpus=6 --memory=12288

# 특정 Kubernetes 버전 사용
minikube start --nodes=2 --kubernetes-version=v1.33.3

# 다른 드라이버 사용
minikube start --nodes=2 --driver=virtualbox
```

## 🔧 문제 해결

### 일반적인 문제

#### 1. Metrics Server 작동하지 않음
```bash
# Metrics Server 재시작
kubectl rollout restart deployment/metrics-server -n kube-system

# 로그 확인
kubectl logs -n kube-system deployment/metrics-server
```

#### 2. 노드 추가 실패
```bash
# Minikube 상태 확인
minikube status

# 시스템 리소스 확인
docker system df
docker system prune  # 필요시 정리
```

#### 3. 메트릭 수집 안됨
```bash
# kubectl top 명령 테스트
kubectl top nodes
kubectl top pods

# 수동으로 메트릭 활성화
minikube addons enable metrics-server
```

### 로그 분석

```bash
# 오토스케일러 로그 레벨별 확인
grep "\[ERROR\]" autoscaler.log
grep "\[WARNING\]" autoscaler.log
grep "\[SUCCESS\]" autoscaler.log

# 특정 시간대 로그 확인
grep "$(date '+%Y-%m-%d %H:')" autoscaler.log
```

## 📈 성능 최적화

### 리소스 할당 최적화

```bash
# Minikube 설정 확인
minikube config view

# 시스템 리소스 사용량 확인
minikube ssh "free -h && df -h"

# 더 많은 리소스 할당
minikube config set cpus 8
minikube config set memory 16384
```

### 스케일링 응답성 향상

```bash
# 체크 간격 단축 (스크립트에서)
CHECK_INTERVAL=15  # 15초로 단축

# 임계값 조정
CPU_THRESHOLD=60   # 더 민감하게 반응
MEMORY_THRESHOLD=70
```

## 🛑 정리 및 종료

### 오토스케일러 중지

```bash
# 포그라운드 실행 시: Ctrl+C

# 백그라운드 실행 시
pkill -f "minikube-autoscaler.sh"

# 프로세스 확인
ps aux | grep minikube-autoscaler
```

### 테스트 워크로드 정리

```bash
# 모든 테스트 워크로드 삭제
kubectl delete -f workload-test-manifests.yaml

# 수동 생성한 리소스 정리
kubectl delete jobs --all
kubectl delete deployments --all
kubectl delete services --all
```

### 클러스터 완전 정리

```bash
# 클러스터 중지
minikube stop

# 클러스터 삭제
minikube delete

# Minikube 전체 정리 (모든 프로필)
minikube delete --all --purge
```

## 🚀 프로덕션 환경으로 확장

이 시뮬레이션을 바탕으로 실제 프로덕션 환경에서 오토스케일링을 구현하려면:

### 클라우드 서비스별 가이드

#### AWS EKS
```bash
# Cluster Autoscaler 설치
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

# Node Group 설정 (Terraform 예시)
resource "aws_eks_node_group" "workers" {
  scaling_config {
    desired_size = 2
    max_size     = 10
    min_size     = 1
  }
}
```

#### Google GKE
```bash
# 클러스터 생성 시 오토스케일링 활성화
gcloud container clusters create my-cluster \
  --enable-autoscaling \
  --min-nodes=1 \
  --max-nodes=10
```

#### Azure AKS
```bash
# 오토스케일러 활성화
az aks nodepool update \
  --resource-group myResourceGroup \
  --cluster-name myAKSCluster \
  --name mynodepool \
  --enable-cluster-autoscaler \
  --min-count 1 \
  --max-count 10
```

## 📝 참고 자료

- [Kubernetes Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler)
- [Minikube 공식 문서](https://minikube.sigs.k8s.io/docs/)
- [Kubernetes Metrics Server](https://github.com/kubernetes-sigs/metrics-server)
- [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)

## 🤝 기여하기

이 프로젝트에 기여하고 싶으시면:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch  
5. Create a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

---

**주의**: 이 도구는 학습 및 테스트 목적으로 제작되었습니다. 프로덕션 환경에서는 각 클라우드 제공업체의 공식 오토스케일러를 사용하시기 바랍니다.