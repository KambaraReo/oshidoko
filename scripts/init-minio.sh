#!/bin/bash

# MinIO初期化スクリプト
# k3sデプロイ後に実行してください

echo "Setting up MinIO..."

# MinIOポッドの名前を取得
MINIO_POD=$(kubectl get pods -n oshidoko -l app=minio -o jsonpath='{.items[0].metadata.name}')

echo "MinIO pod: $MINIO_POD"

# MinIO Clientの設定
MINIO_ROOT_PASSWORD=$(kubectl get secret oshidoko-secret -n oshidoko -o jsonpath='{.data.MINIO_ROOT_PASSWORD}' | base64 -d)

if kubectl exec -n oshidoko $MINIO_POD -- mc alias set local http://localhost:9000 admin "${MINIO_ROOT_PASSWORD}" 2>/dev/null; then
    echo "MinIO client alias configured successfully"
else
    echo "MinIO client alias already configured"
fi

# アプリケーション用ユーザーの作成
kubectl exec -n oshidoko $MINIO_POD -- mc admin user add local minio_oshidokoak minio_oshidokosk

# ポリシーの適用
kubectl exec -n oshidoko $MINIO_POD -- mc admin policy attach local readwrite --user minio_oshidokoak

# バケットの作成
kubectl exec -n oshidoko $MINIO_POD -- mc mb local/oshidoko-bucket --ignore-existing

# バケットを公開読み取り可能に設定
kubectl exec -n oshidoko $MINIO_POD -- mc anonymous set public local/oshidoko-bucket

echo "MinIO setup completed!"
