# GitHub Secrets 設定ガイド

GitHub Actions で CI/CD を動作させるために、以下の Secrets をリポジトリに設定してください。

## 設定方法

1. GitHub リポジトリ → Settings → Secrets and variables → Actions
2. "New repository secret"をクリック
3. 以下の Secrets を追加

## 必要な Secrets

### DOCKER_USERNAME

- Docker Hub のユーザー名

### DOCKER_PASSWORD

- Docker Hub の Personal Access Token
- Docker Hub → Account Settings → Security → New Access Token

### KUBECONFIG

- k3s クラスターの kubeconfig ファイル（Base64 エンコード済み）
- VPS で以下のコマンドを実行して Base64 エンコード:

```bash
sudo cat /etc/rancher/k3s/k3s.yaml | base64 -w 0
```

- 出力された文字列を Secrets に設定

## 設定確認

すべての Secrets が設定されたら、`main`ブランチに push して GitHub Actions が正常に動作することを確認してください。
