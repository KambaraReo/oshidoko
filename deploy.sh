#!/bin/bash

# k3sデプロイスクリプト
set -e  # エラー時に停止

echo "Starting deployment to k3s..."

# Docker buildxが利用可能か確認
if ! docker buildx version > /dev/null 2>&1; then
  echo "Docker buildx is not available. Please install Docker Desktop or enable buildx."
  exit 1
fi

# Docker イメージを x86_64 向けにビルドして Docker Hub に直接 push
echo "Building and pushing Docker image for x86_64 architecture..."
docker buildx build --platform linux/amd64 -t sakuraore/oshidoko:latest . --push
# --platform linux/amd64 : k3s(VPS) で動作するアーキテクチャを指定
# -t sakuraore/oshidoko:latest : Docker Hub 上のリポジトリ名とタグ
# --push : ビルド後に自動で Docker Hub にアップロード

echo "Image built and pushed successfully!"

# Kubernetes マニフェストを適用
echo "Applying Kubernetes manifests..."
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml

# データベース(MySQL) とストレージ(MinIO) を先にデプロイ
echo "Deploying database and storage..."
kubectl apply -f k8s/mysql-deployment.yaml
kubectl apply -f k8s/minio-deployment.yaml

# MySQL Pod が Ready になるまで待機
echo "Waiting for database to be ready..."
if kubectl wait --for=condition=ready pod -l app=mysql -n oshidoko --timeout=300s; then
    echo "Database is ready!"
else
    echo "Database failed to start. Check logs with: kubectl logs -l app=mysql -n oshidoko"
    exit 1
fi

# MinIO Pod が Ready になるまで待機
echo "Waiting for MinIO to be ready..."
if kubectl wait --for=condition=ready pod -l app=minio -n oshidoko --timeout=300s; then
    echo "MinIO is ready!"
else
    echo "MinIO failed to start. Check logs with: kubectl logs -l app=minio -n oshidoko"
    exit 1
fi

# Rails アプリケーションをデプロイ
echo "Deploying Rails application..."
kubectl apply -f k8s/rails-deployment.yaml
kubectl apply -f k8s/ingress.yaml

# Rails Pod が Ready になるまで待機
echo "Waiting for Rails pods to be ready..."
if kubectl wait --for=condition=ready pod -l app=oshidoko-web -n oshidoko --timeout=300s; then
    echo "Rails application is ready!"
else
    echo "Rails application failed to start. Check logs with: kubectl logs -l app=oshidoko-web -n oshidoko"
    exit 1
fi

# デプロイ完了の通知と確認用メッセージ
echo ""
echo "Deployment completed successfully!"
echo ""
echo "Status check:"
kubectl get pods -n oshidoko
echo ""
echo "Next steps:"
# バケット作成や初期ユーザー設定
echo "1. Initialize MinIO: ./scripts/init-minio.sh"
# Ingress のアドレス確認
echo "2. Check application: kubectl get ingress -n oshidoko"
# Rails ログ確認
echo "3. View logs: kubectl logs -l app=oshidoko-web -n oshidoko"
