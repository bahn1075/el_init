#!/bin/bash

# RHEL9 계열 OS에서 최신 Minikube 설치 및 초기 설정 스크립트

echo "Minikube 설치를 시작합니다..."

# 다운로드 경로를 /tmp로 설정
cd /tmp
# 최신 Minikube 릴리스 다운로드 및 설치
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
sudo rpm -Uvh minikube-latest.x86_64.rpm

# cluster spec 지정 및 쿠버네티스 버전, cni 타입 설정
minikube start --cpus=2 --memory=4096m --kubernetes-version=1.34.0 cni=calico

# minikube addon 활성화
minikube addons enable metrics-server
minikube addons enable dashboard
minikube addons enable ingress
minikube addons enable ingress-dns

# 설치파일 정리
rm -f /tmp/minikube-latest.x86_64.rpm