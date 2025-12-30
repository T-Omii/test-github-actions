# Dev Container 専用 Dockerfile
# VS Code の devcontainer 用。開発体験（ツールや拡張、デバッグ）を優先して設定します。
# **CI（自動実行）や本番では使用しません。CI はリポジトリルートの `Dockerfile` を参照してください。**

FROM mcr.microsoft.com/devcontainers/python:0-3.11

# OSレベル依存（C拡張対策）
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリ
WORKDIR /workspace

# 依存関係を先にコピー（キャッシュ最適化）
COPY requirements.txt /workspace/requirements.txt

# Python依存をイメージに焼き込む
RUN python -m pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# ソースコードは後でマウント（devcontainer / CI 共通）
