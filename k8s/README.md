# k3s デプロイメントガイド

## 前提条件

- k3s クラスターが稼働していること
- kubectl が k3s クラスターに接続できること
- Docker レジストリへのアクセス権限があること

## デプロイ手順

### 1. 設定の更新

以下のファイルを実際の環境に合わせて更新してください：

- `k8s/configmap.yaml`: `APP_HOST`を実際のドメインに変更
- `k8s/secret.yaml`: パスワードやキーを実際の値に変更
- `k8s/rails-deployment.yaml`: Docker イメージを実際のレジストリのものに変更
- `k8s/ingress.yaml`: ドメイン名を実際のものに変更

### 2. Docker イメージのビルドとプッシュ

```bash
# イメージをビルド
docker build -t your-registry/oshidoko:latest .

# レジストリにプッシュ
docker push your-registry/oshidoko:latest
```

### 3. デプロイの実行

```bash
# 自動デプロイスクリプトを実行
./deploy.sh

# または手動でデプロイ
kubectl apply -f k8s/
```

### 4. MinIO の初期化

```bash
# MinIOの設定を実行
./scripts/init-minio.sh
```

### 5. 動作確認

```bash
# ポッドの状態確認
kubectl get pods -n oshidoko

# サービスの確認
kubectl get services -n oshidoko

# Ingressの確認
kubectl get ingress -n oshidoko
```

## トラブルシューティング

### ログの確認

```bash
# Railsアプリのログ
kubectl logs -n oshidoko -l app=oshidoko-web

# MySQLのログ
kubectl logs -n oshidoko -l app=mysql

# MinIOのログ
kubectl logs -n oshidoko -l app=minio
```

### データベースの初期化

```bash
# マイグレーションの実行
kubectl exec -n oshidoko deployment/oshidoko-web -- bundle exec rails db:migrate

# シードデータの投入
kubectl exec -n oshidoko deployment/oshidoko-web -- bundle exec rails db:seed
```

## 重要な注意事項

1. **セキュリティ**: `k8s/secret.yaml`の値は実際の本番環境用の安全な値に変更してください
2. **ドメイン**: 実際のドメイン名に変更してください
3. **SSL 証明書**: cert-manager を使用して SSL 証明書を自動取得することを推奨します
4. **バックアップ**: データベースと MinIO のデータは定期的にバックアップしてください
