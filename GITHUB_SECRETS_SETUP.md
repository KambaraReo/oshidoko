# GitHub Secrets 設定ガイド

GitHub Actions で CI/CD を動作させるために、以下の Secrets をリポジトリに設定してください。

## 設定方法

1. GitHub リポジトリ → Settings → Secrets and variables → Actions
2. "New repository secret"をクリック
3. 以下の Secrets を追加

## 必要な Secrets

### Docker 関連

- **DOCKER_USERNAME**
- **DOCKER_PASSWORD**: Docker Hub の Personal Access Token

### Kubernetes 関連

- **KUBECONFIG**: k3s クラスターの kubeconfig ファイル（Base64 エンコード済み）
  ```bash
  cat /home/<ユーザー名>/k3s.yaml | base64 -w 0
  ```

### アプリケーション関連

- **GMAIL_SPECIFIC_PASSWORD**
- **GOOGLE_MAP_API_KEY**
- **SEND_MAIL**
- **MINIO_ACCESS_KEY**
- **MINIO_SECRET_KEY**
- **MINIO_ROOT_USER**
- **MINIO_ROOT_PASSWORD**
- **MYAPP_DATABASE**
- **MYAPP_DATABASE_USERNAME**
- **MYAPP_DATABASE_PASSWORD**
- **MYAPP_DATABASE_HOST**
- **RAILS_MASTER_KEY**

## 設定確認

すべての Secrets が設定されたら、`main`ブランチに push して GitHub Actions が正常に動作することを確認してください。
