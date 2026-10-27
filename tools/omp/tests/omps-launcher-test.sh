#!/bin/bash
# omps-launcher 検証スイート
#   * ダミーリポジトリ（$HOME 配下の一時ディレクトリ）だけで書き込み系を検証する。
#   * 実プロジェクトに対する操作は「読み取りのみ」（git status / rev-parse / log）。
#   * 終了コード: 0=全PASS, 1=FAILあり, 2=SKIPありでFAILなし
set -uo pipefail

L="$HOME/.omp/sandbox/omps-launcher"
SANDBOXED="$HOME/.omp/sandbox/omp-sandboxed"
NTU_REPO="$HOME/maintenance/ntu-member"
NTU_WT="$HOME/github/rakuweb/ntu-membership-repos/ntu-member-cms-strapi-5.58.0"
REAL_GITCONFIG_READ="${REAL_GITCONFIG_READ:-0}"   # 1 でグローバル gitconfig 読み取りテストを追加

PASS=0; FAIL=0; SKIP=0
ok()   { PASS=$((PASS+1)); printf 'PASS: %s\n' "$1"; }
ng()   { FAIL=$((FAIL+1)); printf 'FAIL: %s\n' "$1"; }
skip() { SKIP=$((SKIP+1)); printf 'SKIP: %s\n' "$1"; }
t()    { local n="$1"; shift; if "$@" >/dev/null 2>&1; then ok "$n"; else ng "$n"; fi; }
t_not(){ local n="$1"; shift; if "$@" >/dev/null 2>&1; then ng "$n"; else ok "$n"; fi; }
t_eq() { local n="$1" want="$2" got="$3"; if [ "$want" = "$got" ]; then ok "$n"; else ng "$n (want='$want' got='$got')"; fi; }
t_contains(){ local n="$1" needle="$2" hay="$3"
  case "$hay" in *"$needle"*) ok "$n" ;; *) ng "$n (missing '$needle')" ;; esac; }
t_not_contains(){ local n="$1" needle="$2" hay="$3"
  case "$hay" in *"$needle"*) ng "$n (unexpected '$needle')" ;; *) ok "$n" ;; esac; }

ROOT="$HOME/.omps-launcher-test.$$"
cleanup() { /bin/rm -rf "$ROOT" 2>/dev/null || true; }
trap cleanup EXIT INT TERM

# sandbox-exec プローブ（最小環境）
probe() { local p="$1"; shift
  /usr/bin/env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin \
    /usr/bin/sandbox-exec -f "$p" "$@"; }
# sandbox-exec + git（$HOME の gitconfig を読まない・ロックを取らない＝読み取り専用）
probe_git() { local p="$1"; shift
  /usr/bin/env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin \
    GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_COUNT=2 \
    GIT_CONFIG_KEY_0=core.excludesFile GIT_CONFIG_VALUE_0=/dev/null \
    GIT_CONFIG_KEY_1=core.attributesFile GIT_CONFIG_VALUE_1=/dev/null \
    GIT_OPTIONAL_LOCKS=0 \
    /usr/bin/sandbox-exec -f "$p" "$@"; }

prof() { "$L" --print-profile; }
plan() { "$L" --print-plan; }
base_prof() { ( cd "$1" && /usr/bin/env OMP_SANDBOX_WORKSPACE="$1" OMP_SANDBOX_EXTRA_READ="" \
    OMP_SANDBOX_CONFIRM_SENSITIVE_READ=0 "$SANDBOXED" --print-profile ); }

printf '== 0. 前提 ==\n'
t "launcher が存在し実行可能" test -x "$L"
t "bash -n で構文 OK" /bin/bash -n "$L"
t "既存ラッパーが存在" test -x "$SANDBOXED"
WRAPPER_SHA_EXPECTED="2cc49f63e3e36869b0776890f979a05ab75fa2c022ba81da554da0b7dbcdbd08"
t_eq "既存ラッパー(omp-sandboxed)は未変更（記録済み sha256 と一致）" \
  "$WRAPPER_SHA_EXPECTED" "$(shasum -a 256 "$SANDBOXED" | awk '{print $1}')"

printf '\n== 1. ダミー環境の作成（$HOME 配下・workspace 外は書き込み不可の領域）==\n'
mkdir -p "$ROOT/docs1" "$ROOT/docs2"
echo "doc1" > "$ROOT/docs1/note.md"; echo "doc2" > "$ROOT/docs2/note.md"
echo "outside" > "$ROOT/outside.txt"
GITC="git -c user.name=t -c user.email=t@example.com -c init.defaultBranch=main"
$GITC init -q "$ROOT/repoA"
( cd "$ROOT/repoA" && echo a > a.txt && $GITC add a.txt && $GITC commit -qm "init A" && echo a2 >> a.txt )
echo "SECRET=1" > "$ROOT/repoA/.env"; echo "SECRET=" > "$ROOT/repoA/.env.example"
( cd "$ROOT/repoA" && $GITC add .env.example && $GITC commit -qm "env example" )
$GITC -C "$ROOT/repoA" worktree add -q -b wt "$ROOT/wtB"
( cd "$ROOT/wtB" && echo b > b.txt && $GITC add b.txt && $GITC commit -qm "init B" )
ok "dummy repo A / linked worktree B / docs を作成"

printf '\n== 2. 通常リポジトリ（差分ゼロであること）==\n'
( cd "$ROOT/repoA" && plan > "$ROOT/planA.txt" 2>"$ROOT/planA.err" ); t "planA が成功" test $? -eq 0
git -C "$ROOT/repoA" rev-parse --show-toplevel >/dev/null
t_contains "GIT_LAYOUT=repository" "GIT_LAYOUT=repository" "$(cat "$ROOT/planA.txt")"
t_contains "GIT_DIR_OUTSIDE_WORKSPACE=0" "GIT_DIR_OUTSIDE_WORKSPACE=0" "$(cat "$ROOT/planA.txt")"
t_not_contains "GIT_READ_ROOT を追加しない" "GIT_READ_ROOT=" "$(cat "$ROOT/planA.txt")"
t_not_contains "METADATA_LITERAL を追加しない" "METADATA_LITERAL=" "$(cat "$ROOT/planA.txt")"
P_A="$ROOT/profA.sbpl"; ( cd "$ROOT/repoA" && prof > "$P_A" )
base_prof "$ROOT/repoA" > "$ROOT/baseA.sbpl"
t_eq "ポリシーが基礎ポリシーと完全一致（差分ゼロ）" "" \
  "$(diff "$ROOT/baseA.sbpl" "$P_A" | /usr/bin/grep '^[<>]' || true)"

printf '\n== 3. 書き込み境界（Seatbelt 実効）==\n'
t "workspace 内に書き込みできる" probe "$P_A" /bin/bash -c "echo ok > '$ROOT/repoA/probe.txt'"
t_not "workspace 外（親ディレクトリ）に書き込みできない" probe "$P_A" /bin/bash -c "echo x > '$ROOT/outside2.txt'"
t_not "\$HOME 直下に書き込みできない" probe "$P_A" /bin/bash -c "echo x > '$HOME/.omps_probe_$$'"
t_not "/etc に書き込みできない" probe "$P_A" /bin/bash -c 'echo x > /etc/.omps_probe'
t "workspace 内は読み取りできる" probe "$P_A" /bin/cat "$ROOT/repoA/a.txt"
t_not ".env は読めない" probe "$P_A" /bin/cat "$ROOT/repoA/.env"
t ".env.example は読める" probe "$P_A" /bin/cat "$ROOT/repoA/.env.example"
t_not "~/.ssh は読めない" probe "$P_A" /bin/ls "$HOME/.ssh"
t_not "~/.aws は読めない（通常モード）" probe "$P_A" /bin/ls "$HOME/.aws"
t_not "\$HOME の readdir は不可" probe "$P_A" /bin/ls "$HOME"

printf '\n== 4. linked worktree ==\n'
( cd "$ROOT/wtB" && plan > "$ROOT/planB.txt" )
t_contains "GIT_LAYOUT=linked-worktree" "GIT_LAYOUT=linked-worktree" "$(cat "$ROOT/planB.txt")"
t_contains "GIT_DIR_OUTSIDE_WORKSPACE=1" "GIT_DIR_OUTSIDE_WORKSPACE=1" "$(cat "$ROOT/planB.txt")"
COMMON_REAL="$(cd "$ROOT/repoA/.git" && pwd -P)"
t_contains "共通管理ディレクトリを読み取り許可" "GIT_READ_ROOT=$COMMON_REAL" "$(cat "$ROOT/planB.txt")"
t_contains "worktree の middle dir に metadata 許可" "METADATA_LITERAL=$ROOT" "$(cat "$ROOT/planB.txt")"
P_B="$ROOT/profB.sbpl"; ( cd "$ROOT/wtB" && prof > "$P_B" )
t_contains "profile に共通管理ディレクトリの subpath" "(subpath \"$COMMON_REAL\")" "$(cat "$P_B")"
t "sandboxed git status が成功（worktree）" probe_git "$P_B" /usr/bin/git -C "$ROOT/wtB" status --porcelain
t "sandboxed git rev-parse HEAD が成功（worktree）" probe_git "$P_B" /usr/bin/git -C "$ROOT/wtB" rev-parse HEAD
t_eq "HEAD が sandbox 外と一致" \
  "$(git -C "$ROOT/wtB" rev-parse HEAD)" "$(probe_git "$P_B" /usr/bin/git -C "$ROOT/wtB" rev-parse HEAD)"
t "sandboxed git log が成功（worktree）" probe_git "$P_B" /usr/bin/git -C "$ROOT/wtB" log --oneline -1
t_not "共通管理領域への書き込みは拒否" probe "$P_B" /bin/bash -c "echo x > '$COMMON_REAL/omps_probe'"
t_not "共通管理領域の readdir は不可（metadata のみ）" probe "$P_B" /bin/ls "$ROOT/repoA"
t "中間ディレクトリの stat は可能" probe "$P_B" /usr/bin/stat -f %Su "$ROOT"
t "workspace 内書き込みは可能（worktree）" probe "$P_B" /bin/bash -c "echo ok > '$ROOT/wtB/probe.txt'"
t_not "追加読み取り領域 (docs1) は未指定なら読めない" probe "$P_B" /bin/cat "$ROOT/docs1/note.md"
t_not "git add は失敗する（既知の制約・書き込み拡大しない）" \
  probe_git "$P_B" /usr/bin/git -C "$ROOT/wtB" add probe.txt

printf '\n== 5. 起動時限定の追加読み取り (OMPS_EXTRA_READ) ==\n'
( cd "$ROOT/wtB" && OMPS_EXTRA_READ="$ROOT/docs1" plan > "$ROOT/planR1.txt" )
P_R1="$ROOT/profR1.sbpl"; ( cd "$ROOT/wtB" && OMPS_EXTRA_READ="$ROOT/docs1" prof > "$P_R1" )
t_contains "EXTRA_READ_PATH が計画に載る" "EXTRA_READ_PATH=$ROOT/docs1" "$(cat "$ROOT/planR1.txt")"
t_contains "profile に subpath 追加" "(subpath \"$ROOT/docs1\")" "$(cat "$P_R1")"
t "追加読み取り先が実際に読める" probe "$P_R1" /bin/cat "$ROOT/docs1/note.md"
t_not "指定外の docs2 は読めない" probe "$P_R1" /bin/cat "$ROOT/docs2/note.md"
t_not "追加読み取り先でも .env は読めない" probe "$P_R1" /bin/cat "$ROOT/repoA/.env"
cp "$ROOT/docs1/note.md" "$ROOT/docs1/.env"; t_not "追加読み取り先の .env も読めない" probe "$P_R1" /bin/cat "$ROOT/docs1/.env"; rm -f "$ROOT/docs1/.env"

P_R2="$ROOT/profR2.sbpl"; ( cd "$ROOT/wtB" && OMPS_EXTRA_READ="$ROOT/docs1:$ROOT/docs2" prof > "$P_R2" )
t "複数指定（コロン区切り）: docs1" probe "$P_R2" /bin/cat "$ROOT/docs1/note.md"
t "複数指定（コロン区切り）: docs2" probe "$P_R2" /bin/cat "$ROOT/docs2/note.md"

printf '\n== 6. 異常指定は fail closed ==\n'
bad() { local d="$1"; shift; ( cd "$ROOT/wtB" && env "$@" "$L" --print-profile >/dev/null 2>"$ROOT/bad.err" ); echo $?; }
RC=$(bad "機密 ~/.ssh" OMPS_EXTRA_READ="$HOME/.ssh")
t_eq "機密パス (~/.ssh) を拒否" "1" "$RC"; t_contains "  理由が機密判定" "機密パス" "$(cat "$ROOT/bad.err")"
RC=$(bad "機密 ~/.aws" OMPS_EXTRA_READ="$HOME/.aws"); t_eq "機密パス (~/.aws) を拒否" "1" "$RC"
RC=$(bad "機密 Keychains" OMPS_EXTRA_READ="$HOME/Library/Keychains"); t_eq "機密パス (Keychains) を拒否" "1" "$RC"
ln -sfn "$HOME/.ssh" "$ROOT/sshlink"
RC=$(bad "シンボリックリンク経由" OMPS_EXTRA_READ="$ROOT/sshlink"); t_eq "シンボリックリンク経由の機密パスを拒否" "1" "$RC"
RC=$(bad "\$HOME 自体" OMPS_EXTRA_READ="$HOME"); t_eq "\$HOME 自体を拒否" "1" "$RC"
RC=$(bad "@/ 自体" OMPS_EXTRA_READ="/"); t_eq "/ を拒否" "1" "$RC"
RC=$(bad "相対パス" OMPS_EXTRA_READ="docs1"); t_eq "相対パスを拒否" "1" "$RC"
RC=$(bad "存在しないパス" OMPS_EXTRA_READ="$ROOT/nope"); t_eq "存在しないパスを拒否" "1" "$RC"
RC=$(bad ".. を含む" OMPS_EXTRA_READ="$ROOT/docs1/../outside.txt"); t_eq ".. を含むパスを拒否" "1" "$RC"
( cd "$ROOT/wtB" && OMPS_EXTRA_READ="" "$L" --print-plan > "$ROOT/planEmpty.txt" 2>&1 )
t_eq "空文字は未指定として扱う（追加パスなし）" "0" "$?"
t_not_contains "  追加読み取りが増えない" "EXTRA_READ_PATH=" "$(cat "$ROOT/planEmpty.txt")"
RC=$(bad "改行を含む" OMPS_EXTRA_READ="$ROOT/docs1"$'\n'"x"); t_eq "制御文字を含むパスを拒否" "1" "$RC"
RC=$(bad "OLD var" OMP_SANDBOX_EXTRA_READ="$HOME/.ssh"); t_eq "OMP_SANDBOX_EXTRA_READ 直接指定を拒否" "1" "$RC"

printf '\n== 7. AWS モード / HERDR / クリーン環境 / 引数転送（スタブ omp）==\n'
STUB_DIR="$ROOT/repoA/.stub"; mkdir -p "$STUB_DIR"
cat > "$STUB_DIR/omp" <<EOS
#!/bin/bash
out="$STUB_DIR/out.txt"
{
  printf 'ARGV\n'
  for a in "\$@"; do printf 'ARG %s\n' "\$a"; done
  printf 'ENV\n'
  /usr/bin/env | /usr/bin/sort
  if /bin/echo x > "\$HOME/.omps_stub_probe_\$\$" 2>/dev/null; then
    printf 'SEATBELT=off\n'; /bin/rm -f "\$HOME/.omps_stub_probe_\$\$"
  else
    printf 'SEATBELT=on\n'
  fi
} > "\$out" 2>/dev/null
exit 0
EOS
chmod 700 "$STUB_DIR/omp"
STUB_PATH="$STUB_DIR:$PATH"
run_stub() { rm -f "$STUB_DIR/out.txt"; ( cd "$ROOT/repoA" && env PATH="$STUB_PATH" "$@" ); }

run_stub OMP_SANDBOX_YOLO=1 "$L" --foo bar --baz=1 --version
OUT="$STUB_DIR/out.txt"
t "スタブが起動した（= sandbox-exec 経由で omp が起動）" test -f "$OUT"
t_contains "自動承認 --auto-approve が付与される" "ARG --auto-approve" "$(cat "$OUT")"
t_contains "--config が転送される" "ARG --config" "$(cat "$OUT")"
t_contains "sandbox.yml が指定される" "ARG $HOME/.omp/agent/sandbox.yml" "$(cat "$OUT")"
t_contains "CLI 引数 --foo が転送される" "ARG --foo" "$(cat "$OUT")"
t_contains "CLI 引数 'bar' が転送される" "ARG bar" "$(cat "$OUT")"
t_contains "CLI 引数 --baz=1 が転送される" "ARG --baz=1" "$(cat "$OUT")"
t_contains "引数順序は auto-approve -> config -> user" "ARG --auto-approve.ARG --config.ARG $HOME/.omp/agent/sandbox.yml.ARG --foo" \
  "$( /usr/bin/tr '\n' '.' < "$OUT" )"
t_contains "Seatbelt が実効（スタブ内の \$HOME 書き込みが拒否される）" "SEATBELT=on" "$(cat "$OUT")"
t_contains "sandbox marker (OMP_SANDBOX=seatbelt)" "OMP_SANDBOX=seatbelt" "$(cat "$OUT")"
t_contains "PI_SANDBOX=seatbelt" "PI_SANDBOX=seatbelt" "$(cat "$OUT")"
t_contains "AWS 認証情報を遮断 (AWS_SHARED_CREDENTIALS_FILE=/dev/null)" "AWS_SHARED_CREDENTIALS_FILE=/dev/null" "$(cat "$OUT")"
t_contains "AWS 認証情報を遮断 (AWS_CONFIG_FILE=/dev/null)" "AWS_CONFIG_FILE=/dev/null" "$(cat "$OUT")"
t_contains "git は \$HOME の gitconfig を読まない (GIT_CONFIG_GLOBAL=/dev/null)" "GIT_CONFIG_GLOBAL=/dev/null" "$(cat "$OUT")"

run_stub OMP_SANDBOX_YOLO=0 "$L" --version
t_not_contains "YOLO=0 では --auto-approve を付けない" "ARG --auto-approve" "$(cat "$STUB_DIR/out.txt")"

run_stub OMP_SANDBOX_YOLO=1 HERDR_ENV=zellij HERDR_PANE_ID=pane-1 HERDR_SOCKET_PATH=/tmp/h.sock "$L" --version
OUT="$STUB_DIR/out.txt"
t_contains "HERDR_ENV を引き継ぐ" "HERDR_ENV=zellij" "$(cat "$OUT")"
t_contains "HERDR_PANE_ID を引き継ぐ" "HERDR_PANE_ID=pane-1" "$(cat "$OUT")"
t_contains "HERDR_SOCKET_PATH を引き継ぐ" "HERDR_SOCKET_PATH=/tmp/h.sock" "$(cat "$OUT")"
t_not_contains "未設定の HERDR_* は作られない" "HERDR_TAB_ID=" "$(cat "$OUT")"

run_stub OMP_SANDBOX_YOLO=1 OMPS_TEST_CANARY=super-secret-123 "$L" --version
t_not_contains "クリーン環境: canary が漏れない" "OMPS_TEST_CANARY" "$(cat "$STUB_DIR/out.txt")"
t_contains "クリーン環境: HOME は実ホーム" "HOME=$HOME" "$(cat "$STUB_DIR/out.txt")"

run_stub OMP_SANDBOX_YOLO=1 OMPS_AWS_MODE=1 "$L" --version
OUT="$STUB_DIR/out.txt"
t_not_contains "AWS モード: AWS_* を /dev/null に潰さない" "AWS_SHARED_CREDENTIALS_FILE=/dev/null" "$(cat "$OUT")"
P_AWS="$ROOT/profAWS.sbpl"; ( cd "$ROOT/repoA" && OMPS_AWS_MODE=1 prof > "$P_AWS" )
t_contains "AWS モード: ~/.aws を読み取り許可" "(subpath \"$HOME/.aws\")" "$(cat "$P_AWS")"
t_contains "AWS モード: CONFIRM_SENSITIVE_READ=1" "CONFIRM_SENSITIVE_READ=1" \
  "$( cd "$ROOT/repoA" && OMPS_AWS_MODE=1 plan )"
t "AWS モード: ~/.aws が実際に読める" probe "$P_AWS" /bin/ls "$HOME/.aws"
t_not "AWS モードでも ~/.ssh は読めない" probe "$P_AWS" /bin/ls "$HOME/.ssh"

printf '\n== 8. ポリシー差分の監査（想定外の権限拡大が無いこと）==\n'
audit_profile() {  # $1=base $2=final $3=label
  local added bad=0 line
  added="$(diff "$1" "$2" | /usr/bin/grep '^>' | /usr/bin/sed 's/^> //')"
  [ -n "$added" ] || { ok "$3: 追加ルールなし（=基礎ポリシーと同一）"; return; }
  while IFS= read -r line; do
    case "$line" in
      ''|';;'*|'(allow file-read*'|'(allow file-read-metadata'|'    (subpath "'*'")'|'    (literal "'*'")'|')') ;;
      *) bad=1 ;;
    esac
    case "$line" in *file-write*|*'(deny '*) bad=1 ;; esac
  done <<EOF
$added
EOF
  [ "$bad" = 0 ] && ok "$3: 追加行は file-read* / file-read-metadata のみ" || ng "$3: 想定外の追加行がある"
  t_eq "$3: file-write* 許可の件数が不変" \
    "$(/usr/bin/grep -c '^(allow file-write\*' "$1")" "$(/usr/bin/grep -c '^(allow file-write\*' "$2")"
  t_eq "$3: deny ルールの件数が不変" \
    "$(/usr/bin/grep -c '^(deny ' "$1")" "$(/usr/bin/grep -c '^(deny ' "$2")"
  t_eq "$3: 削除された行が無い" "" "$(diff "$1" "$2" | /usr/bin/grep '^<' || true)"
}
audit_profile "$ROOT/baseA.sbpl" "$P_A" "repoA"
base_prof "$ROOT/wtB" > "$ROOT/baseB.sbpl"
audit_profile "$ROOT/baseB.sbpl" "$P_B" "wtB"
audit_profile "$ROOT/baseB.sbpl" "$P_R1" "wtB+EXTRA_READ"
audit_profile "$ROOT/baseA.sbpl" "$P_AWS" "repoA+AWS"

printf '\n== 9. Sandbox なしフォールバックが無いこと（静的検査）==\n'
# 行継続を結合して exec 文単位で検査する
EXEC_STMTS="$(/usr/bin/awk '{ while ($0 ~ /\\$/) { sub(/\\$/, ""); if ((getline nxt) > 0) $0 = $0 " " nxt; else break } if ($0 ~ /(^|[ \t])exec /) print }' "$L")"
t_eq "exec 文は 2 つだけ（通常 / INHERIT_ENV）" "2" "$(printf '%s\n' "$EXEC_STMTS" | /usr/bin/grep -c .)"
t_eq "すべての exec 文が sandbox-exec 経由" "2" "$(printf '%s\n' "$EXEC_STMTS" | /usr/bin/grep -c 'sandbox-exec -f')"
t_eq "omp を sandbox-exec なしで exec する箇所が無い" "" \
  "$(printf '%s\n' "$EXEC_STMTS" | /usr/bin/grep '\$OMP_BIN' | /usr/bin/grep -v 'sandbox-exec' || true)"
t_contains "sandbox 適用失敗時は die する" "起動を中止します" "$(cat "$L")"

printf '\n== 10. 実プロジェクト（Read Only）==\n'
if [ -d "$NTU_REPO/.git" ]; then
  P_N="$ROOT/profNTU.sbpl"; ( cd "$NTU_REPO" && prof > "$P_N" )
  GDIR="$(git -C "$NTU_REPO" rev-parse --absolute-git-dir)"
  IDX_BEFORE="none"; [ -f "$GDIR/index" ] && IDX_BEFORE=$(shasum -a 256 "$GDIR/index" | awk '{print $1}')
  probe_git "$P_N" /usr/bin/git -C "$NTU_REPO" status --porcelain > "$ROOT/ntu.out" 2>"$ROOT/ntu.err"
  t_eq "NTU 通常リポジトリ: sandboxed git status が exit 0" "0" "$?"
  t_eq "NTU 通常リポジトリ: git status の出力が sandbox 外と一致" \
    "$(git -C "$NTU_REPO" status --porcelain 2>/dev/null)" "$(cat "$ROOT/ntu.out")"
  t_eq "NTU 通常リポジトリ: git-dir が取得できる" "$GDIR" \
    "$(probe_git "$P_N" /usr/bin/git -C "$NTU_REPO" rev-parse --absolute-git-dir)"
  if git -C "$NTU_REPO" rev-parse --verify -q HEAD >/dev/null 2>&1; then
    t_eq "NTU 通常リポジトリ: HEAD 一致" \
      "$(git -C "$NTU_REPO" rev-parse HEAD)" "$(probe_git "$P_N" /usr/bin/git -C "$NTU_REPO" rev-parse HEAD)"
  else
    ok "NTU 通常リポジトリ: 未コミットの空リポジトリ（HEAD 比較はスキップ、status/git-dir は検証済み）"
  fi
  IDX_AFTER="none"; [ -f "$GDIR/index" ] && IDX_AFTER=$(shasum -a 256 "$GDIR/index" | awk '{print $1}')
  t_eq "NTU: index が変化していない（読み取りのみ）" "$IDX_BEFORE" "$IDX_AFTER"
else
  skip "NTU 通常リポジトリが見つからない"
fi

if [ -d "$NTU_WT/.git" ] || [ -f "$NTU_WT/.git" ]; then
  P_W="$ROOT/profNTUWT.sbpl"; ( cd "$NTU_WT" && prof > "$P_W" )
  C_IDX="$(probe_git "$P_W" /usr/bin/git -C "$NTU_WT" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)"
  IDX2_BEFORE=$(shasum -a 256 "$C_IDX/index" | awk '{print $1}')
  probe_git "$P_W" /usr/bin/git -C "$NTU_WT" status --porcelain > "$ROOT/ntuwt.out" 2>"$ROOT/ntuwt.err"
  RC_STATUS=$?
  t_eq "NTU worktree: sandboxed git status が exit 0" "0" "$RC_STATUS"
  t_eq "NTU worktree: git status の出力が sandbox 外と一致" \
    "$(git -C "$NTU_WT" status --porcelain 2>/dev/null)" "$(cat "$ROOT/ntuwt.out")"
  t_eq "NTU worktree: HEAD 一致" \
    "$(git -C "$NTU_WT" rev-parse HEAD)" "$(probe_git "$P_W" /usr/bin/git -C "$NTU_WT" rev-parse HEAD)"
  t "NTU worktree: git log が成功" probe_git "$P_W" /usr/bin/git -C "$NTU_WT" log --oneline -1
  t_not "NTU worktree: 共通管理領域への書き込みは拒否" probe "$P_W" /bin/bash -c "echo x > '$C_IDX/omps_probe'"
  IDX2_AFTER=$(shasum -a 256 "$C_IDX/index" | awk '{print $1}')
  t_eq "NTU worktree: index が変化していない（読み取りのみ）" "$IDX2_BEFORE" "$IDX2_AFTER"
  t_not "NTU worktree: ~/.ssh は読めない" probe "$P_W" /bin/ls "$HOME/.ssh"
  t_not "NTU worktree: 他リポジトリ (ntu-member) は workspace 外なので読めない" probe "$P_W" /bin/cat "$NTU_REPO/.git/HEAD"
else
  skip "NTU linked worktree が見つからない"
fi

printf '\n== 結果 ==\nPASS=%d FAIL=%d SKIP=%d\n' "$PASS" "$FAIL" "$SKIP"
[ "$FAIL" -eq 0 ] || exit 1
[ "$SKIP" -eq 0 ] && exit 0 || exit 2
