# omps-launcher

`omps` の実体（`~/.zcmd.sh` の `omps()` はこのスクリプトを呼ぶだけ）。

- リポジトリ内の実装: `tools/omp/omps-launcher`
- 稼働中のランチャー: `~/.omp/sandbox/omps-launcher` (mode 700)
- 基礎ポリシー: `~/.omp/sandbox/omp-sandboxed`（変更しない）
- 合成テスト: `tools/omp/tests/omps-launcher-test.sh`

## 何をするか

1. `git rev-parse` と `git worktree list --porcelain -z` で workspace、Git 管理領域、
   登録 worktree を取得する。候補の実パス、common dir、相互参照、機密パスや
   既存許可領域との重複を検証し、HOME 配下の安全な別 worktree のみ追加する。
   不正な候補は警告して除外し、列挙全体が信頼できなければ自動許可を無効にする。
2. 現在の workspace の祖先から HOME までの `AGENTS.md` をファイル単位で許可する。
   symlink や検証できないファイルは除外し、親ディレクトリ全体は許可しない。
3. `omp-sandboxed --print-profile` を基礎ポリシーとし、Git 管理領域、
   `OMPS_EXTRA_READ`、検証済み worktree と親 `AGENTS.md` の読み取りを追加する。
   到達に必要な中間ディレクトリは metadata-only とし、書き込みは追加しない。
   worktree の機密候補・socket に対する限定 deny も挿入する。
   追加ルールは dotenv 保護より前に置き、既存の `.env` deny を維持する。
4. `sandbox-exec` でポリシーの適用を確認し、失敗時は中止する。
   Sandbox なしの `omp` へはフォールバックしない。
5. クリーン環境（`env -i` と必要な環境変数）で `omp` を exec する。
   `--print-plan` は `WORKTREE_ENUM`、`WORKTREE_READ`、`WORKTREE_SKIP`、
   `PARENT_AGENTS` などを表示する。

## 環境変数

| 変数 | 意味 |
| --- | --- |
| `OMPS_EXTRA_READ="a:b"` | 起動時限定の追加読み取り（コロン区切り・絶対パス・実在必須）。機密パスは無条件拒否 |
| `OMPS_AWS_MODE=1` | 既存挙動: `~/.aws` の読み取りを許可（`OMP_SANDBOX_CONFIRM_SENSITIVE_READ=1`） |
| `OMP_SANDBOX_YOLO=1` | `--auto-approve` を付与（`omps()` が常に 1 を渡す） |
| `OMPS_GIT_GLOBAL_CONFIG=read` | `~/.gitconfig` / `~/.config/git/config` を明示的に読み取り許可（既定は許可しない） |
| `OMPS_LAUNCHER_VERBOSE=1` | 起動計画を stderr に出力 |
| `OMP_SANDBOX_PASS_ENV` | ランチャーが HERDR 系と AWS・Git 系の必要な変数を指定する（呼び出し元の値は置き換える） |
| `OMP_SANDBOX_INHERIT_ENV=1` / `OMP_SANDBOX_SKIP_HOME_VERIFY=1` / `OMP_SANDBOX_CONFIRM_WIDE=1` | 既存ラッパーと同じ抜け道（非推奨） |

`OMP_SANDBOX_EXTRA_READ` / `OMP_SANDBOX_EXTRA_WRITE` を直接指定すると中止する（write 拡大は扱わない）。

## 使い方

```sh
cd ~/projects/example && omps
OMPS_EXTRA_READ="$HOME/docs" omps                     # 起動時限定の追加読み取り
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

## 合成テスト

通常の macOS ターミナルでリポジトリのルートから実行する。
テストは候補版を対象とし、稼働中のランチャーを更新しない。

```sh
/bin/bash tools/omp/tests/omps-launcher-test.sh
```

終了コードは `0` = 全項目成功、`1` = 失敗あり、`2` = スキップあり。
`2` は検証完了を意味しない。

追加の Seatbelt 適用が禁止されたセッションでは、管理者が通常ターミナルで実行する。
実 Docker、Docker context、本番リポジトリ、実認証情報を試験に使用しない。

### この変更の検証状況

- 構文検査と `--launcher-help` は成功。独立した合成 Git fixture では、登録済み
  worktree の相互参照を検証し、共有管理領域の逆参照を破損させると不一致を検出した。
- 管理者による通常 macOS ターミナルでの修正後の Seatbelt 合成テスト結果:
  **PASS 235 / FAIL 0 / SKIP 0 / 終了コード 0**（管理者報告）。
- 対象は通常・linked worktree 双方向の読み取り、書き込み拒否、親 `AGENTS.md`、
  dotenv・機密候補、合成 Unix/TCP socket の基礎ポリシーとの比較、
  AWS・HERDR・クリーン環境・自動承認・fail-closed の回帰。
- リポジトリ内実装は受け入れ済み。稼働中ランチャーへの反映は別途承認が必要。

## 反映と切り戻し

以下は**反映の明示承認後だけ**、通常ターミナルで実行する。
リポジトリのルートで、承認対象コミットが HEAD であることを確認する。
反映対象はコミット内のランチャーだけ。作業ツリー内の無関係な変更は使用しない。

```sh
git log -1 --oneline
```

バックアップ・候補の構文確認・反映を一つのブロックで実行する。
途中の失敗時は停止する。バックアップは残し、表示した絶対パスを別途控える。

```sh
(
  set -eu
  umask 077
  target="$HOME/.omp/sandbox/omps-launcher"
  backups="$HOME/.omp/sandbox/backups"
  test -f "$target" && test ! -L "$target"
  mkdir -p "$backups"
  chmod 700 "$backups"
  saved="$(mktemp -d "$backups/phase-a.XXXXXX")"
  cp -p "$target" "$saved/omps-launcher"
  cmp "$target" "$saved/omps-launcher"
  printf 'ROLLBACK_SOURCE=%s\n' "$saved/omps-launcher"
  git rev-parse HEAD > "$saved/source-commit"
  staged="$(mktemp "$HOME/.omp/sandbox/omps-launcher.new.XXXXXX")"
  trap 'rm -f "$staged"' EXIT
  git show HEAD:tools/omp/omps-launcher > "$staged"
  /bin/bash -n "$staged"
  chmod 700 "$staged"
  mv -f "$staged" "$target"
  printf 'Installed commit: %s\n' "$(cat "$saved/source-commit")"
)
```

### 反映後の最小スモーク

通常ターミナルのリポジトリルートで、まず反映内容がコミットと一致すること、
help と実際のポリシー生成・Seatbelt 適用が成功することを確認する。
OMP 本体・Docker・認証情報へのアクセスは行わない。

```sh
(
  set -eu
  target="$HOME/.omp/sandbox/omps-launcher"
  expected="$(mktemp)"
  trap 'rm -f "$expected"' EXIT
  git show HEAD:tools/omp/omps-launcher > "$expected"
  cmp "$expected" "$target"
  "$target" --launcher-help > /dev/null
  "$target" --print-plan
  "$target" --print-profile > /dev/null
)
```

`WORKSPACE`、`WORKTREE_ENUM`、`WORKTREE_READ`、`PARENT_AGENTS` と警告が想定どおりか
確認する。worktree がない場合、追加数ゼロは正常。失敗や予期しない許可があれば切り戻す。
このスモークは合成テストの代替ではない。既に起動中の OMP セッションの権限は変わらず、
新しいポリシーは次回起動から有効になる。

### 切り戻し

反映時に表示した `ROLLBACK_SOURCE` の絶対パスを `backup` に設定して実行する。
基礎ラッパー・設定・シェル関数は変更しない。

```sh
(
  set -eu
  backup='/反映時に表示した絶対パス/omps-launcher'
  target="$HOME/.omp/sandbox/omps-launcher"
  test -f "$backup"
  restored="$(mktemp "$HOME/.omp/sandbox/omps-launcher.restore.XXXXXX")"
  trap 'rm -f "$restored"' EXIT
  cp -p "$backup" "$restored"
  /bin/bash -n "$restored"
  cmp "$backup" "$restored"
  mv -f "$restored" "$target"
  cmp "$backup" "$target"
)
```

必要な検証は新規起動で行う。既存セッションを巻き戻す操作ではない。

## 既知の制約

- linked worktree では git 共通管理領域が workspace 外なので **書き込みは許可しない**。
  そのため worktree 上での `git add` / `commit` は失敗する（権限設計は別工程）。
- Git 管理領域への追加許可は `file-read*`（readdir 含む）。中間ディレクトリは
  `file-read-metadata`（stat のみ・readdir 不可）に限定。
- 自動許可した worktree 内では `.ssh`、`.aws`、`.gnupg`、`.kube`、`.docker`、
  `.npmrc`、`.netrc`、`.git-credentials` と、一般的な秘密鍵名や
  `.pem`、`.key`、`.p12`、`.pfx` を名前に基づき拒否する。通常の開発ファイルにも
  同名なら影響する。別名の秘密情報は検出できず、登録変更・パス置換の競合も残る。
  ただし元から読み取り許可されている Git 管理領域が worktree 内にある場合は、
  その領域の既存読み取り権限を維持する（dotenv 保護は従来どおり適用）。
- 合成試験の socket 比較は成功（管理者報告）。登録外の context や
  TCP 経路の遮断を意味しない。
- ネットワークは開放されており、Docker socket や別 Docker context の全面遮断は保証されない。
  合成 socket の比較は経路の全網羅を意味しない。
