# omps-launcher

`omps` の実体（`~/.zcmd.sh` の `omps()` はこのスクリプトを呼ぶだけ）。

- ランチャー: `~/.omp/sandbox/omps-launcher` (mode 700)
- 既存ラッパー: `~/.omp/sandbox/omp-sandboxed`（**未変更**）
- テスト: `~/.omp/sandbox/tests/omps-launcher-test.sh`（ダミーリポジトリのみで検証）
- バックアップ: `~/.omp/sandbox/backups/`（mode 700 / 各ファイル 600）

## 何をするか

1. `git rev-parse`（読み取り専用）で workspace / git-dir / git-common-dir を検出し、
   通常リポジトリと linked worktree を区別する。
2. 既存ラッパー `omp-sandboxed --print-profile` の出力を基礎ポリシーとして取得する
   （`--print-profile` は必ずラッパーの**先頭引数**。`--config` の後ろに置くと omp に転送され失敗する）。
3. 追加が**必要な場合だけ**、読み取り専用ルールを「dotenv 保護ブロックの直前」に挿入する。
   - `(allow file-read* (subpath "<git-common-dir>"))` — workspace 外の Git 管理領域
   - `(allow file-read* (subpath "<OMPS_EXTRA_READ の各パス>"))`
   - `(allow file-read-metadata (literal "<中間ディレクトリ>"))` — 到達に必要な親のみ
   - `file-write*` の追加は一切生成しない（生成したら内部エラーで中止）
   - dotenv 保護より前に挿入するので `.env` の読み取り禁止は追加パス配下でも有効
4. `sandbox-exec` でポリシーを適用できることを確認してから起動する。
   失敗したら**中止**（Sandbox なしの `omp` へはフォールバックしない）。
5. 既存ラッパーと同じクリーン環境（`env -i` + allowlist + `OMP_SANDBOX_PASS_ENV`）で `omp` を exec する。

## 環境変数

| 変数 | 意味 |
| --- | --- |
| `OMPS_EXTRA_READ="a:b"` | 起動時限定の追加読み取り（コロン区切り・絶対パス・実在必須）。機密パスは無条件拒否 |
| `OMPS_AWS_MODE=1` | 既存挙動: `~/.aws` の読み取りを許可（`OMP_SANDBOX_CONFIRM_SENSITIVE_READ=1`） |
| `OMP_SANDBOX_YOLO=1` | `--auto-approve` を付与（`omps()` が常に 1 を渡す） |
| `OMPS_GIT_GLOBAL_CONFIG=read` | `~/.gitconfig` / `~/.config/git/config` を明示的に読み取り許可（既定は許可しない） |
| `OMPS_LAUNCHER_VERBOSE=1` | 起動計画を stderr に出力 |
| `OMP_SANDBOX_PASS_ENV` | 既存挙動: クリーン環境へ転送する変数（HERDR 系・AWS 系） |
| `OMP_SANDBOX_INHERIT_ENV=1` / `OMP_SANDBOX_SKIP_HOME_VERIFY=1` / `OMP_SANDBOX_CONFIRM_WIDE=1` | 既存ラッパーと同じ抜け道（非推奨） |

`OMP_SANDBOX_EXTRA_READ` / `OMP_SANDBOX_EXTRA_WRITE` を直接指定すると中止する（write 拡大は扱わない）。

## 使い方

```sh
cd ~/maintenance/ntu-member && omps                 # 通常リポジトリ
cd ~/github/.../ntu-member-cms-strapi-5.58.0 && omps # linked worktree（Git 読み取り可）
OMPS_EXTRA_READ="$HOME/docs:/Volumes/work/spec" omps # 起動時限定の追加読み取り
OMPS_AWS_MODE=1 omps                                 # = ompsaws
omps --print-plan                                    # 検出結果と追加ルールの確認（omp は起動しない）
omps --print-profile                                 # 合成後ポリシーの確認
omps --launcher-help                                 # この仕組みの説明（--help は omp へ転送）
OMPS_LAUNCHER_VERBOSE=1 omps                         # 起動時に計画を stderr へ
```

## Git について（重要）

基礎ポリシーは `$HOME` 全体を読み取り禁止するため、`~/.gitconfig` が読めず
`git status` すら失敗する。ランチャーは**権限を増やさず**に
`GIT_CONFIG_GLOBAL=/dev/null`（＋ `core.excludesFile` / `core.attributesFile` を `/dev/null`）を
渡して git の読み取り系を動かす。グローバル設定（identity・alias・credential helper）を
サンドボックス内で使いたい場合だけ `OMPS_GIT_GLOBAL_CONFIG=read` を明示する。

## テスト

```sh
~/.omp/sandbox/tests/omps-launcher-test.sh        # exit 0=全PASS / 1=FAIL / 2=SKIPあり
```

## ロールバック

```sh
cp -p ~/.omp/sandbox/backups/zcmd.sh.<TS>.bak ~/dotfiles/shells/zsh/zcmd.sh
chmod 644 ~/dotfiles/shells/zsh/zcmd.sh
# 新しい zsh で確認
zsh -i -c 'whence -f omps'
```

ランチャー自体を無効化するだけなら `~/.omp/sandbox/omps-launcher` を退避すれば
`omps()` がエラーを返して停止する（黙って旧実装へは戻らない）。
旧実装（ラッパー直呼び）はバックアップ内の `omps()` にそのまま残っている。

## 既知の制約

- linked worktree では git 共通管理領域が workspace 外なので **書き込みは許可しない**。
  そのため worktree 上での `git add` / `commit` は失敗する（権限設計は別工程）。
- Git 管理領域への追加許可は `file-read*`（readdir 含む）。中間ディレクトリは
  `file-read-metadata`（stat のみ・readdir 不可）に限定。
- ネットワーク / Docker socket の制御は対象外（既存どおり）。
