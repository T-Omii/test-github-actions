# test-github-actions（日本語説明）

## 概要 ✅
このリポジトリは「**Docker を唯一の実行環境**」として CI を回す構成を取っています。
テストや Lint 等の「何を実行するか」はすべて `scripts/` のスクリプトに委譲し、CI はそのスクリプトをコンテナ内で実行するだけに簡素化しています。

---

## 重要な設計方針（汎用性） 💡
- **環境は固定**: Docker イメージ（`Dockerfile`）を安定させ、頻繁には変えません。
- **挙動は可変**: 具体的に何を実行するかは `scripts/test.sh` などのスクリプトで定義します。環境変数 `TEST_CMD` を使って任意のテストランナー／コマンドに切り替えられます（デフォルトは `pytest -q`）。
- **CI は単純**: `.github/workflows/ci.yaml` は `docker build` / `docker run --rm ./scripts/test.sh` を呼ぶだけにします。

> 利点: ランナー（pytest / unittest / custom）に依存せず、プロジェクト毎に自由にテスト方法を変えられます。

---

## ディレクトリ構成
```
Dockerfile
.devcontainer/
  devcontainer.json
.github/workflows/
  ci.yaml
scripts/
  test.sh
  lint.sh
  format.sh
tests/
  (テストコード)
requirements.txt
```

---

## どこを**頻繁に変更**するか（案件別に） ✍️
- `scripts/test.sh`（最も頻繁）
  - テストの実行方法をここで定義。
  - 例: `TEST_CMD="python -m unittest discover"` や `pytest --cov` に切り替える。
- `tests/` 配下
  - テストコード・フィクスチャやテスト専用の設定ファイル（`pytest.ini` 等）を配置。
- `requirements.txt`
  - テストに必要な依存（テストフレームワークやテストヘルパー）を追加。

> 案件固有のテスト手順や注意点は `tests/README.md`（存在させること推奨）に書いてください。CI 設定を触らずに済むようにするのが目的です。

---

## どこを**ほとんど触らない**か（安定させるべき） ⚠️
- `Dockerfile`（ルート）
  - 環境（Python バージョン、OS パッケージ）をここで固定します。変更は慎重に。理由がある場合のみ更新してください。
- `.devcontainer/devcontainer.json` と `.devcontainer/Dockerfile`
  - 開発用（VS Code Remote）の設定です。ローカル開発環境を合わせたい場合のみ変更。
- `.github/workflows/ci.yaml`
  - 基本的に年に数回レベルでの更新で十分です。テスト方法は `scripts/` 側で切り替えます。

---

## Dockerfile が 2 つある理由 🧩
- `.devcontainer/Dockerfile` は **開発用**（VS Code の devcontainer 向け）です。開発者向けツールや拡張、デバッグ用パッケージなどを含めるために用います。ローカルの開発体験を向上させる目的で変更して構いません。
- `Dockerfile`（リポジトリルート）は **CI / 再現可能な実行環境** を提供します。最小で安定した環境にしておき、頻繁には変更しないのが推奨です（CI の信頼性確保のため）。

> 理由: 目的が異なるため、両方を維持することで「開発体験の向上」と「CI の安定性」を両立できます。どうしても一元化したい場合のオプション（devcontainer がルートを参照する、共通ベースを切り出す、CI イメージを GHCR に push して devcontainer がそれを利用するなど）については上記の「もし一元化したい場合の選択肢」を参照してください。

---

## CI / ローカルでの実行例 🚀
- ローカルでコンテナビルドしてテスト実行（デフォルト `TEST_CMD` を使用）:

```bash
docker build -t app:ci .
docker run --rm app:ci ./scripts/test.sh
```

- `TEST_CMD` を上書きして別のランナーを使う例:

```bash
# docker run に環境変数を渡す
docker run --rm -e TEST_CMD="python -m unittest discover -v" app:ci ./scripts/test.sh
```

- GitHub Actions で `TEST_CMD` を上書きしたい場合は、`ci.yaml` の該当 step に `env:` を追加してください。

---

## その他のベストプラクティス ✅
- `scripts/` は `set -euo pipefail` と適切なログ出力を入れておくとデバッグが楽になります。
- スクリプトには実行ビットを付けてコミットしてください（例: `git add --chmod=+x scripts/test.sh`）。
- Docker イメージの変更（ベースアップデートなど）は PR で明確に説明してください（環境に影響が大きいため）。

---

## まとめ ✨
- 「**環境（Docker）を固定**して」「**挙動（何をするか）は scripts に委譲**する」ことで、案件ごとにテストフレームワークを変えつつ CI のシンプルさを保てます。
- 案件固有の変更は **`scripts/` と `tests/`** にまとめ、`Dockerfile` や `ci.yaml` の変更は最小限にします。