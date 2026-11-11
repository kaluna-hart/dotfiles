#!/bin/bash
# omps-launcher 合成テスト（リポジトリ内の候補実装を対象）
#
# 目的:
#   * tools/omp/omps-launcher（候補）だけを起動して検証する。稼働中の
#     ~/.omp/sandbox/omps-launcher は起動せず、変更有無の確認にのみ読み取る。
#   * 基礎ポリシーの生成に限り、既存ラッパー ~/.omp/sandbox/omp-sandboxed と
#     ~/.omp/agent/sandbox.yml の存在を利用する。認証情報（~/.aws, ~/.ssh 等）の
#     内容は読まない。実 Docker / 実 Docker socket / 本番リポジトリは使わない。
#   * ダミー Git リポジトリ・ダミー worktree・ダミー omp・合成 Unix/TCP socket を
#     $HOME 配下の一時ディレクトリに作成する。
#
# 実行（通常の macOS ターミナル。リポジトリのルートから）:
#   /bin/bash tools/omp/tests/omps-launcher-test.sh
#   exit 0=PASS のみ / 1=FAIL あり / 2=SKIP あり・FAIL なし（環境不足を含む）
#
# セッション内で sandbox-exec の追加適用が EPERM で拒否される場合、動的検証は
# 実施できない。このスクリプトはそれを事前検出し、偽の PASS を出さずに SKIP
# （exit 2）で明示する。その場合は通常ターミナルで実行すること。
#
# 既知の限界:
#   - ネットワークは基礎ポリシーで開放されている。TCP は 127.0.0.1 の合成
#     リスナーとの等価性だけを確認する（外部・実 Docker TCP は検証しない）。
#   - Unix socket の接続可否は合成 socket で経験的に比較する。Seatbelt の
#     file-read* / network* の全経路を網羅した証明ではない。macOS の /usr/bin/nc
#     は Unix socket に対して `-z` を併用できない（接続できても rc=1 になる）ため、
#     本スクリプトは `nc -U -w 2 PATH </dev/null` で接続確認する。さらに
#     network-outbound の許可・拒否を切り替えた対照 profile で、probe が両方を
#     観測できることを確認してから比較する（制御が成立しなければ SKIP）。
#   - 基礎ポリシー（~/.omp/sandbox/omp-sandboxed）の heredoc 内に
#     `ls -ld $HOME` のバッククォート展開があり、生成 profile のコメント行に
#     実行時のディレクトリ状態とロケール依存の文字列が埋め込まれる。監査では
#     この行を固定トークンへ正規化して比較する（行の欠落自体は検出できる）。
#   - extra-read / AWS ルート内に後から作られる socket は、候補が当該ルートに
#     SOCKET_GUARD を出した場合のみ検証できる。AWS の実ディレクトリには
#     合成 socket を置かない（実データを触らないため）。
#   - worktree の sensitive / outside-home / metadata-mismatch 等の一部の
#     skip 理由は、実機の機密領域を汚さずに再現できないため未検証。
#   - 実 $HOME/.gitconfig・~/.zshrc 等の symlink 解決先が candidate 内にある場合の
#     resolved-target deny は、実 dotfiles を変更せずに再現できないため未検証
#     （profile 監査は追加の範囲限定 deny を許容する）。
set -uo pipefail
umask 077

SELF="$(cd "$(dirname "$0")" && pwd -P)/$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
L="$SCRIPT_DIR/../omps-launcher"
L="$(cd "$(dirname "$L")" && pwd -P)/$(basename "$L")"
DEPLOYED="$HOME/.omp/sandbox/omps-launcher"
SANDBOXED="$HOME/.omp/sandbox/omp-sandboxed"
OMP_CONFIG="$HOME/.omp/agent/sandbox.yml"

PASS=0; FAIL=0; SKIP=0; NOTES=0
ok()   { PASS=$((PASS+1)); printf 'PASS: %s\n' "$1"; }
ng()   { FAIL=$((FAIL+1)); printf 'FAIL: %s\n' "$1"; }
skip() { SKIP=$((SKIP+1)); printf 'SKIP: %s\n' "$1"; }
note() { NOTES=$((NOTES+1)); printf 'NOTE: %s\n' "$1"; }
t()    { local n="$1"; shift; if "$@" >/dev/null 2>&1; then ok "$n"; else ng "$n"; fi; }
t_not(){ local n="$1"; shift; if "$@" >/dev/null 2>&1; then ng "$n"; else ok "$n"; fi; }
t_eq() { local n="$1" want="$2" got="$3"; if [ "$want" = "$got" ]; then ok "$n"; else ng "$n (want='$want' got='$got')"; fi; }
t_contains() { local n="$1" needle="$2" hay="$3"
  case "$hay" in *"$needle"*) ok "$n" ;; *) ng "$n (missing '$needle')" ;; esac; }
t_not_contains() { local n="$1" needle="$2" hay="$3"
  case "$hay" in *"$needle"*) ng "$n (unexpected '$needle')" ;; *) ok "$n" ;; esac; }


# ------------------------------------------------------------------ 安全確認
if [ -e "$DEPLOYED" ] && [ "$L" -ef "$DEPLOYED" ]; then
  printf 'FATAL: テスト対象が稼働中ランチャーと同一です（%s）。リポジトリの候補版を指定してください。\n' "$L" >&2
  exit 1
fi
if [ ! -f "$L" ]; then
  printf 'FATAL: 候補ランチャーが見つかりません: %s\n' "$L" >&2
  exit 1
fi

ROOT="$(/usr/bin/mktemp -d "$HOME/.omps-launcher-test.XXXXXX")" || {
  printf 'FATAL: $HOME 配下にテスト用一時ディレクトリを作成できません\n' >&2
  exit 1
}
/bin/chmod 700 "$ROOT" 2>/dev/null || true

TMPDIR_CANON="$(cd "${TMPDIR:-/tmp}" 2>/dev/null && pwd -P || echo '/private/tmp')"
case "$TMPDIR_CANON" in
  /private/tmp|/private/tmp/*|/private/var/folders/*) : ;;
  *) TMPDIR_CANON="/private/tmp" ;;
esac

SERVER_PIDS=""
stop_servers() {
  local _p
  for _p in ${SERVER_PIDS:-}; do /bin/kill "$_p" 2>/dev/null || true; done
  SERVER_PIDS=""
}
cleanup() {
  stop_servers
  /bin/chmod -R u+rwX "$ROOT" 2>/dev/null || true
  /bin/rm -rf "$ROOT" 2>/dev/null || true
}
trap cleanup EXIT INT TERM HUP

hash_of() { [ -e "$1" ] && /usr/bin/shasum -a 256 "$1" 2>/dev/null | /usr/bin/awk '{print $1}' || echo absent; }
BEFORE_DEPLOYED="$(hash_of "$DEPLOYED")"
BEFORE_WRAPPER="$(hash_of "$SANDBOXED")"
BEFORE_CONFIG="$(hash_of "$OMP_CONFIG")"

printf '== 0. 前提・静的検査 ==\n'
t "候補ランチャーが存在する" test -f "$L"
t "候補ランチャーが実行可能" test -x "$L"
t_eq "テスト対象は稼働中ランチャーではない" "0" "$([ "$L" -ef "$DEPLOYED" ] && echo 1 || echo 0)"
t "bash -n で構文 OK" /bin/bash -n "$L"
t "既存ラッパーが存在する（基礎ポリシー生成の読み取りのみ）" test -x "$SANDBOXED"
t "OmP 設定ファイルが存在する" test -f "$OMP_CONFIG"

# ------------------------------------------------------- sandbox 事前確認
SANDBOX_USABLE=0
MIN_SBPL="$ROOT/minimal.sbpl"
printf '(version 1)\n(allow default)\n' > "$MIN_SBPL"
if /usr/bin/sandbox-exec -f "$MIN_SBPL" /usr/bin/true >/dev/null 2>"$ROOT/sandbox-preflight.err"; then
  SANDBOX_USABLE=1
  ok "sandbox-exec で新しいプロファイルを適用できる"
else
  printf '\n!! sandbox-exec による追加プロファイル適用が拒否されました。\n' >&2
  /usr/bin/sed 's/^/   /' "$ROOT/sandbox-preflight.err" >&2
  printf '!! この環境では動的検証を実施できません（偽の PASS は出しません）。\n' >&2
  printf '!! 通常の macOS ターミナルで再実行してください: /bin/bash %s\n\n' "$SELF" >&2
  skip "sandbox-exec の追加適用が不可のため動的検証をスキップ（通常ターミナルで再実行）"
fi

# =====================================================================
# 以降は sandbox-exec が利用できる場合のみ。
# =====================================================================
run_dynamic_suite() {

printf '\n== 1. 合成環境の作成（$HOME 配下・実データ不使用）==\n'
REPO_A="$ROOT/repoA"
WT_B="$ROOT/wtB"
WT_CLEAN="$ROOT/wtClean"
WT_SECRET="$ROOT/wtSecret"
WT_SOCK="$ROOT/wtSock"
WT_GONE="$ROOT/wtGone"
DOCS1="$ROOT/docs1"
DOCS2="$ROOT/docs2"
# スタブは候補の sandbox 内で実行されるため、workspace 内（読み取り・実行・
# 書き込みが許可される場所）に置く。$ROOT 直下は $HOME 配下の read-deny 対象で、
# sandbox 内から exec も write もできない。
STUB_DIR="$REPO_A/.omps-stub"
STUB_OUT="$STUB_DIR/out.txt"
TEST_PATH="$STUB_DIR:/usr/bin:/bin:/usr/sbin:/sbin"
mkdir -p "$DOCS1" "$DOCS2" "$STUB_DIR" "$ROOT/parentSkip" "$ROOT/symParent"
printf 'doc1\n' > "$DOCS1/note.md"
printf 'doc2\n' > "$DOCS2/note.md"
printf 'synthetic sibling\n' > "$ROOT/outside.txt"
printf 'synthetic parent instructions\n' > "$ROOT/AGENTS.md"
printf 'real-looking agents target\n' > "$ROOT/agents-real.md"
printf 'other target\n' > "$ROOT/agents-other.md"
ln -sfn "$ROOT/agents-real.md" "$ROOT/symParent/AGENTS.md"
mkdir -p "$ROOT/parentSkip/agents-dir"
ln -sfn "$ROOT/parentSkip/agents-dir" "$ROOT/parentSkip/AGENTS.md"
printf 'root dotenv\nSECRET=0\n' > "$ROOT/.env"

GITX() {
  /usr/bin/env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin LANG=C \
    GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 GIT_OPTIONAL_LOCKS=0 \
    /usr/bin/git -c user.name=t -c user.email=t@example.com -c init.defaultBranch=main "$@"
}
GITX init -q "$REPO_A"
printf 'a\n' > "$REPO_A/a.txt"
printf 'workspace instructions\n' > "$REPO_A/AGENTS.md"
printf 'SECRET=1\n' > "$REPO_A/.env"
printf 'SECRET=\n' > "$REPO_A/.env.example"
GITX -C "$REPO_A" add a.txt .env.example AGENTS.md
GITX -C "$REPO_A" commit -qm "init A"
GITX -C "$REPO_A" worktree add -q -b wtB "$WT_B"
printf 'b\n' > "$WT_B/b.txt"
printf 'SECRET=2\n' > "$WT_B/.env"
printf 'SECRET=\n' > "$WT_B/.env.example"
GITX -C "$WT_B" add b.txt .env.example && GITX -C "$WT_B" commit -qm "init B"
ok "合成 repoA / linked worktree wtB / docs / stub を作成"

# 合成 omp スタブ（クリーン環境でも OUT パスは埋め込み）
cat > "$STUB_DIR/omp" <<EOS
#!/bin/bash
out="$STUB_OUT"
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
/bin/chmod 700 "$STUB_DIR/omp"
t "スタブ omp が実行可能" test -x "$STUB_DIR/omp"

# ------------------------------------------------------------- helpers
base_prof(){ local ws="$1" extra="${2:-}" confirm="${3:-0}"
  ( cd "$ws" && /usr/bin/env -i HOME="$HOME" PATH="$TEST_PATH" LANG=C \
      TMPDIR="$TMPDIR_CANON" \
      OMP_SANDBOX_WORKSPACE="$ws" OMP_SANDBOX_EXTRA_READ="$extra" \
      OMP_SANDBOX_CONFIRM_SENSITIVE_READ="$confirm" \
      "$SANDBOXED" --print-profile ); }
probe()    { local p="$1"; shift
  /usr/bin/env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin TMPDIR="$TMPDIR_CANON" \
    /usr/bin/sandbox-exec -f "$p" "$@"; }
probe_git(){ local p="$1"; shift
  /usr/bin/env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin TMPDIR="$TMPDIR_CANON" \
    GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_COUNT=2 \
    GIT_CONFIG_KEY_0=core.excludesFile GIT_CONFIG_VALUE_0=/dev/null \
    GIT_CONFIG_KEY_1=core.attributesFile GIT_CONFIG_VALUE_1=/dev/null \
    GIT_OPTIONAL_LOCKS=0 \
    /usr/bin/sandbox-exec -f "$p" "$@"; }

plan_vals()  { printf '%s\n' "$1" | /usr/bin/grep "^$2=" | /usr/bin/sed "s/^$2=//"; }
plan_has()   { local blob="$1" key="$2" val="$3"; plan_vals "$blob" "$key" | /usr/bin/grep -Fxq -e "$val"; }
plan_count() { plan_vals "$1" "$2" | /usr/bin/grep -c . || true; }
t_plan_has(){ local n="$1" blob="$2" key="$3" val="$4"
  if plan_has "$blob" "$key" "$val"; then ok "$n"; else ng "$n (want $key=$val)"; fi; }
t_plan_not_has(){ local n="$1" blob="$2" key="$3" val="$4"
  if plan_has "$blob" "$key" "$val"; then ng "$n (unexpected $key=$val)"; else ok "$n"; fi; }
t_plan_count(){ local n="$1" blob="$2" key="$3" want="$4" got
  got="$(plan_count "$blob" "$key")"; t_eq "$n" "$want" "$got"; }
t_plan_skip(){ local n="$1" blob="$2" val="$3"
  if plan_vals "$blob" WORKTREE_SKIP | /usr/bin/grep -Fq -e "$val"; then ok "$n"; else ng "$n (WORKTREE_SKIP '$val' なし)"; fi; }

t_profile_has(){ local n="$1" f="$2" needle="$3"
  if /usr/bin/grep -Fq -e "$needle" "$f"; then ok "$n"; else ng "$n (profile に '$needle' なし)"; fi; }
t_profile_not_has(){ local n="$1" f="$2" needle="$3"
  if /usr/bin/grep -Fq -e "$needle" "$f"; then ng "$n (profile に '$needle')"; else ok "$n"; fi; }
line_no() { local f="$1" needle="$2"; /usr/bin/grep -nF -e "$needle" "$f" 2>/dev/null | /usr/bin/head -1 | /usr/bin/cut -d: -f1; }

# ---- ポリシー監査の補助 ------------------------------------------------
# 基礎ポリシー（omp-sandboxed）は heredoc 内で `ls -ld $HOME` をバッククォート
# 展開するため、生成 profile のコメント 1 行に実行時刻・ロケール・$HOME の
# ディレクトリ状態が埋め込まれる。この行をそのまま diff すると、基礎と候補で
# ロケールが違うだけで「基礎行が削除された」と誤判定する（実際に管理者環境で
# 2 件の誤 FAIL になった）。行そのものは残す（欠落は検出可能）ため、可変部分
# だけを固定トークンへ置換して比較する。
PROFILE_VOLATILE_RE='^;; inode\) is already world-readable via .* outside any sandbox\.$'
PROFILE_VOLATILE_CANON=';; inode) is already world-readable via [normalized] outside any sandbox.'
normalize_profile() { # FILE → stdout
  /usr/bin/sed -E "s@${PROFILE_VOLATILE_RE}@${PROFILE_VOLATILE_CANON}@" "$1"
}

# 正規化済み profile 同士の差分から、基礎側で失われた行を出力する。
# （挿入だけの変更では空になる。可変コメント行は正規化済みなので影響しない。）
profile_missing_base_lines() { # BASE FINAL
  /usr/bin/diff "$1" "$2" | /usr/bin/grep '^<' | /usr/bin/sed 's/^< //' || true
}

# 正規化済み profile 同士の差分から、追加された行を出力する。
profile_added_lines() { # BASE FINAL
  /usr/bin/diff "$1" "$2" | /usr/bin/grep '^>' | /usr/bin/sed 's/^> //' || true
}

# 追加行の監査: 基礎ポリシーを削除せず、file-write* を増やさず、
# 読み取り許可 + 範囲限定 deny (socket/sensitive) のみが増えていること。
# socket guard は SBPL の複数 filter が OR 評価される事故を避け、
# 必ず (require-all (subpath ...) (vnode-type SOCKET)) の交差形式を要求する。
audit_profile() { # $1=base $2=final $3=label
  local base="$1" final="$2" label="$3" line bad=0 added removed orbad
  if [ ! -s "$base" ] || [ ! -s "$final" ]; then ng "$label: ポリシーが空のため監査できない"; return; fi
  local nb="$ROOT/audit-base.sbpl" nf="$ROOT/audit-final.sbpl"
  normalize_profile "$base" > "$nb"
  normalize_profile "$final" > "$nf"
  removed="$(profile_missing_base_lines "$nb" "$nf")"
  t_eq "$label: 基礎ポリシーの行が削除されていない" "" "$removed"
  added="$(profile_added_lines "$nb" "$nf")"
  while IFS= read -r line; do
    case "$line" in
      ''|';;'*|'(allow file-read*'|'(allow file-read-metadata'|')'|'    (subpath "'*'")'|'    (literal "'*'")') ;;
      '(deny file-read* (require-all (subpath "'*'") (vnode-type SOCKET)))' \
      |'(deny network-outbound (subpath "'*'"))' \
      |'(deny network-bind (subpath "'*'"))' \
      |'(allow file-read* (require-all (subpath "'*'") (vnode-type SOCKET)))' \
      |'(allow network-outbound (subpath "'*'"))' \
      |'(allow network-bind (subpath "'*'"))' \
      |'(deny file-read* (require-all (subpath "'*'") (regex #"'*'")))' \
      |'(allow file-read* (subpath "'*'"))' \
      |'(deny file-read* (subpath "'*'"))') : ;;
    esac
    case "$line" in *file-write*) bad=1 ;; esac
  done <<EOF
$added
EOF
  if [ "$bad" = 0 ]; then ok "$label: 追加行は read allow / 範囲限定 deny のみ"; else ng "$label: 想定外の追加行がある"; fi
  # 複数 filter の deny/allow は SBPL で OR 評価になる。socket guard が
  # require-all を伴わない形式で混入していないことを明示的に確認する。
  orbad="$(printf '%s\n' "$added" | /usr/bin/awk '/\(vnode-type SOCKET\)/ && !/\(require-all /')"
  t_eq "$label: socket guard は require-all 交差形式（OR 形式なし）" "" "$orbad"
  t_eq "$label: file-write* allow の件数が不変" \
    "$(/usr/bin/grep -c '^(allow file-write\*' "$base" || true)" \
    "$(/usr/bin/grep -c '^(allow file-write\*' "$final" || true)"
  local base_deny final_deny
  base_deny="$(/usr/bin/grep -c '^(deny ' "$base" || true)"
  final_deny="$(/usr/bin/grep -c '^(deny ' "$final" || true)"
  if [ "$final_deny" -lt "$base_deny" ]; then ng "$label: deny 行が減少している"; else ok "$label: deny 行は減少していない ($base_deny -> $final_deny)"; fi
  local a b
  a="$(line_no "$final" '(allow file-read*')"
  b="$(line_no "$final" ';; --- dotenv protection ---')"
  if [ -n "$a" ] && [ -n "$b" ] && [ "$a" -lt "$b" ]; then ok "$label: 追加の read allow は dotenv deny より前"; else ng "$label: 追加 read allow の位置が不正"; fi
  t_profile_has "$label: dotenv deny が存在" "$final" '(regex #".*/[.]env$")'
}

# =================================================== 2. 通常リポジトリ
printf '\n== 2. 通常リポジトリ（repoA, registered worktree wtB）==\n'
P_BASE_A="$ROOT/baseA.sbpl"; base_prof "$REPO_A" > "$P_BASE_A" || ng "基礎ポリシー生成（repoA）"
t "基礎ポリシー（repoA）が空でない" test -s "$P_BASE_A"
if /usr/bin/grep -Fq -e ';; inode) is already world-readable via ' "$P_BASE_A"; then
  ok "監査の前提: 基礎ポリシーに正規化対象の可変コメント行がある"
else
  skip "監査の前提: 基礎ポリシーに可変コメント行が無い（wrapper 変更の可能性）— 正規化は不要だが要確認"
fi
# 監査の対照（オラクル）: 正規化後も基礎行の欠落を検出できることを先に確認する。
_ORACLE_BASE="$ROOT/audit-oracle-base.sbpl"
_ORACLE_MISS="$ROOT/audit-oracle-missing.sbpl"
normalize_profile "$P_BASE_A" > "$_ORACLE_BASE"
/usr/bin/grep -vF -e '(deny file-write*)' "$_ORACLE_BASE" > "$_ORACLE_MISS"
t_eq "監査の対照: 未変更の基礎ポリシーは削除行なし" "" "$(profile_missing_base_lines "$_ORACLE_BASE" "$_ORACLE_BASE")"
t_eq "監査の対照: 基礎行を 1 行削除した場合に検出できる" "(deny file-write*)" "$(profile_missing_base_lines "$_ORACLE_BASE" "$_ORACLE_MISS")"
note "監査: 基礎ポリシー内の可変コメント行（ls -ld \$HOME の実行結果）を固定トークンへ正規化して比較する（行の欠落自体は検出対象）"

run_cand_plan "$REPO_A" "$ROOT/planA.txt" "$ROOT/planA.err" ; RC=$?
t_eq "repoA: --print-plan が exit 0" "0" "$RC"
t_not "repoA: --print-plan は omp を起動しない" test -f "$STUB_OUT"
PLAN_A="$(cat "$ROOT/planA.txt")"
t_contains "repoA: WORKSPACE が repoA" "WORKSPACE=$(cd "$REPO_A" && pwd -P)" "$PLAN_A"
t_contains "repoA: GIT_LAYOUT=repository" "GIT_LAYOUT=repository" "$PLAN_A"
t_contains "repoA: GIT_DIR_OUTSIDE_WORKSPACE=0" "GIT_DIR_OUTSIDE_WORKSPACE=0" "$PLAN_A"
t_contains "repoA: WORKTREE_ENUM=ok" "WORKTREE_ENUM=ok" "$PLAN_A"
t_plan_has "repoA: WORKTREE_CANDIDATE に current repoA" "$PLAN_A" WORKTREE_CANDIDATE "$(cd "$REPO_A" && pwd -P)"
t_plan_has "repoA: WORKTREE_CANDIDATE に wtB" "$PLAN_A" WORKTREE_CANDIDATE "$WT_B"
t_plan_skip "repoA: current は WORKTREE_SKIP=...:current" "$PLAN_A" "$(cd "$REPO_A" && pwd -P):current"
t_not_contains "repoA: current スキップは警告しない（plan のみ）" "worktree をスキップ" "$(cat "$ROOT/planA.err")"
t_plan_has "repoA: WORKTREE_READ に wtB" "$PLAN_A" WORKTREE_READ "$WT_B"
t_plan_has "repoA: SOCKET_GUARD に wtB" "$PLAN_A" SOCKET_GUARD "$WT_B"
t_plan_count "repoA: WORKTREE_AUTO_ROOTS は read 数と一致" "$PLAN_A" WORKTREE_AUTO_ROOTS "$(plan_count "$PLAN_A" WORKTREE_READ)"
t_plan_has "repoA: PARENT_AGENTS に親 AGENTS.md" "$PLAN_A" PARENT_AGENTS "$ROOT/AGENTS.md"
t_plan_not_has "repoA: workspace 自身の AGENTS.md は PARENT_AGENTS に含めない" "$PLAN_A" PARENT_AGENTS "$REPO_A/AGENTS.md"
t_contains "repoA: plan が PROFILE を出す" "PROFILE=" "$PLAN_A"
P_A="$(plan_vals "$PLAN_A" PROFILE)"
if [ -n "$P_A" ] && [ ! -e "$P_A" ]; then ok "repoA: --print-plan 後の一時プロファイルが削除される"; else ng "repoA: 一時プロファイルが残っている ($P_A)"; fi

run_cand_profile "$REPO_A" "$ROOT/profA.sbpl" "$ROOT/profA.err"; RC=$?
t_eq "repoA: --print-profile が exit 0" "0" "$RC"
t "repoA: 合成プロファイルが空でない" test -s "$ROOT/profA.sbpl"
t "repoA: 合成プロファイルを sandbox-exec で適用できる" probe "$ROOT/profA.sbpl" /usr/bin/true
t_profile_has "repoA: wtB の read subpath" "$ROOT/profA.sbpl" "(subpath \"$WT_B\")"
t_profile_has "repoA: 親 AGENTS.md の literal" "$ROOT/profA.sbpl" "(literal \"$ROOT/AGENTS.md\")"
t_profile_has "repoA: wtB の socket guard は require-all 交差" "$ROOT/profA.sbpl" "(deny file-read* (require-all (subpath \"$WT_B\") (vnode-type SOCKET)))"
t_profile_not_has "repoA: wtB の socket guard に OR 形式を使わない" "$ROOT/profA.sbpl" "(deny file-read* (subpath \"$WT_B\") (vnode-type SOCKET))"
t_profile_has "repoA: wtB の network-outbound guard" "$ROOT/profA.sbpl" "(deny network-outbound (subpath \"$WT_B\"))"
t_profile_has "repoA: wtB の network-bind guard" "$ROOT/profA.sbpl" "(deny network-bind (subpath \"$WT_B\"))"
t_profile_has "repoA: wtB の .ssh を deny" "$ROOT/profA.sbpl" "(deny file-read* (subpath \"$WT_B/.ssh\"))"
t_profile_has "repoA: wtB の .docker を deny" "$ROOT/profA.sbpl" "(deny file-read* (subpath \"$WT_B/.docker\"))"
_WT_LINE="$(line_no "$ROOT/profA.sbpl" "(subpath \"$WT_B\")")"
_DOT_LINE="$(line_no "$ROOT/profA.sbpl" ';; --- dotenv protection ---')"
if [ -n "$_WT_LINE" ] && [ -n "$_DOT_LINE" ] && [ "$_WT_LINE" -lt "$_DOT_LINE" ]; then
  ok "repoA: worktree read allow は dotenv deny より前に挿入される"
else
  ng "repoA: worktree read allow の挿入位置が不正"
fi
audit_profile "$P_BASE_A" "$ROOT/profA.sbpl" "repoA"

# 実行時の境界（read-only worktree / dotenv / 親）
t "repoA: workspace 内に書き込める" probe "$ROOT/profA.sbpl" /bin/bash -c "echo ok > '$REPO_A/probe.txt'"
t_not "repoA: workspace 外（親）に書き込めない" probe "$ROOT/profA.sbpl" /bin/bash -c "echo x > '$ROOT/outside2.txt'"
t_not "repoA: /etc に書き込めない" probe "$ROOT/profA.sbpl" /bin/bash -c 'echo x > /etc/.omps_probe'
t "repoA: workspace の .env.example を読める" probe "$ROOT/profA.sbpl" /bin/cat "$REPO_A/.env.example"
t_not "repoA: workspace の .env を読めない" probe "$ROOT/profA.sbpl" /bin/cat "$REPO_A/.env"
t "repoA: wtB の通常ファイルを読める（registered worktree read）" probe "$ROOT/profA.sbpl" /bin/cat "$WT_B/b.txt"
t_not "repoA: wtB に書き込めない（read-only）" probe "$ROOT/profA.sbpl" /bin/bash -c "echo x > '$WT_B/probe.txt'"
t_not "repoA: wtB の .env は読めない" probe "$ROOT/profA.sbpl" /bin/cat "$WT_B/.env"
t "repoA: wtB の .env.example は読める" probe "$ROOT/profA.sbpl" /bin/cat "$WT_B/.env.example"
t "repoA: 親 AGENTS.md を読める" probe "$ROOT/profA.sbpl" /bin/cat "$ROOT/AGENTS.md"
t_not "repoA: 親の兄弟ファイルは読めない" probe "$ROOT/profA.sbpl" /bin/cat "$ROOT/outside.txt"
t_not "repoA: 親の .env は読めない" probe "$ROOT/profA.sbpl" /bin/cat "$ROOT/.env"
t_not "repoA: 親ディレクトリの readdir は不可" probe "$ROOT/profA.sbpl" /bin/ls "$ROOT"
t "repoA: 親ディレクトリの stat は可能" probe "$ROOT/profA.sbpl" /usr/bin/stat -f %Su "$ROOT"
t "repoA: sandboxed git status が成功（通常 repo）" probe_git "$ROOT/profA.sbpl" /usr/bin/git -C "$REPO_A" status --porcelain
t_eq "repoA: HEAD が sandbox 外と一致" "$(GITX -C "$REPO_A" rev-parse HEAD)" \
  "$(probe_git "$ROOT/profA.sbpl" /usr/bin/git -C "$REPO_A" rev-parse HEAD)"

# =================================================== 3. linked worktree を current に
printf '\n== 3. linked worktree をカレントにする（wtB）==\n'
COMMON_REAL="$(cd "$REPO_A/.git" && pwd -P)"
# 共通 Git 管理ディレクトリは「既存の Git 読み取り」。追加 worktree の scoped deny
# （秘密鍵名 regex 等）がこれを狭めないことを、key 名の合成 canary で確認する。
# 基礎ポリシー（workspace=wtB）は $HOME 配下の $COMMON_REAL を読めないため、
# 「基礎=deny / 候補=allow」の差分対照になる。
CANARY_GIT_KEY="$COMMON_REAL/omps-canary.key"
printf 'synthetic canary\n' > "$CANARY_GIT_KEY"
P_BASE_B="$ROOT/baseB.sbpl"; base_prof "$WT_B" > "$P_BASE_B" || ng "基礎ポリシー生成（wtB）"
run_cand_plan "$WT_B" "$ROOT/planB.txt" "$ROOT/planB.err"; RC=$?
t_eq "wtB: --print-plan が exit 0" "0" "$RC"
PLAN_B="$(cat "$ROOT/planB.txt")"
t_contains "wtB: GIT_LAYOUT=linked-worktree" "GIT_LAYOUT=linked-worktree" "$PLAN_B"
t_contains "wtB: GIT_DIR_OUTSIDE_WORKSPACE=1" "GIT_DIR_OUTSIDE_WORKSPACE=1" "$PLAN_B"
t_plan_has "wtB: GIT_READ_ROOT に共通管理ディレクトリ" "$PLAN_B" GIT_READ_ROOT "$COMMON_REAL"
t_plan_has "wtB: WORKTREE_READ にメイン worktree repoA" "$PLAN_B" WORKTREE_READ "$REPO_A"
t_plan_skip "wtB: current はスキップ" "$PLAN_B" "$WT_B:current"
t_plan_has "wtB: METADATA_LITERAL に親" "$PLAN_B" METADATA_LITERAL "$ROOT"

run_cand_profile "$WT_B" "$ROOT/profB.sbpl" "$ROOT/profB.err"; RC=$?
t_eq "wtB: --print-profile が exit 0" "0" "$RC"
t_profile_has "wtB: 共通管理ディレクトリの subpath" "$ROOT/profB.sbpl" "(subpath \"$COMMON_REAL\")"
t_profile_has "wtB: repoA の read subpath" "$ROOT/profB.sbpl" "(subpath \"$REPO_A\")"
t_profile_has "wtB: repoA の socket guard は require-all 交差" "$ROOT/profB.sbpl" "(deny file-read* (require-all (subpath \"$REPO_A\") (vnode-type SOCKET)))"
t_profile_not_has "wtB: repoA の socket guard に OR 形式を使わない" "$ROOT/profB.sbpl" "(deny file-read* (subpath \"$REPO_A\") (vnode-type SOCKET))"
t_profile_has "wtB: repoA の network-outbound guard" "$ROOT/profB.sbpl" "(deny network-outbound (subpath \"$REPO_A\"))"
t_profile_has "wtB: repoA の network-bind guard" "$ROOT/profB.sbpl" "(deny network-bind (subpath \"$REPO_A\"))"
t_profile_has "wtB: git root の socket 既存許可を復元 (file-read, require-all)" "$ROOT/profB.sbpl" "(allow file-read* (require-all (subpath \"$COMMON_REAL\") (vnode-type SOCKET)))"
t_profile_not_has "wtB: git root の socket 復元に OR 形式を使わない" "$ROOT/profB.sbpl" "(allow file-read* (subpath \"$COMMON_REAL\") (vnode-type SOCKET))"
t_profile_has "wtB: git root の socket 既存許可を復元 (outbound)" "$ROOT/profB.sbpl" "(allow network-outbound (subpath \"$COMMON_REAL\"))"
t_profile_has "wtB: git root の socket 既存許可を復元 (bind)" "$ROOT/profB.sbpl" "(allow network-bind (subpath \"$COMMON_REAL\"))"
# 既存 Git 読み取り（共通管理ディレクトリ）の保存: key 名 canary の差分対照。
t_not "wtB: 基礎ポリシーは共通 Git 管理ディレクトリの canary を読めない（対照）" \
  probe "$P_BASE_B" /bin/cat "$CANARY_GIT_KEY"
t "wtB: key 名 canary を読める（scoped deny が既存 Git 読み取りを狭めない）" \
  probe "$ROOT/profB.sbpl" /bin/cat "$CANARY_GIT_KEY"
t "wtB: 共通管理ディレクトリの Git メタデータを読める" \
  probe "$ROOT/profB.sbpl" /bin/cat "$COMMON_REAL/HEAD"
# 復元 allow は scoped deny の後・dotenv deny の前（dotenv が最後に勝つ）。
_GCALLOW_LAST="$(/usr/bin/grep -nF -e "(allow file-read* (subpath \"$COMMON_REAL\"))" "$ROOT/profB.sbpl" \
  | /usr/bin/tail -1 | /usr/bin/cut -d: -f1)"
_NESTED_LINE="$(line_no "$ROOT/profB.sbpl" "(require-all (subpath \"$REPO_A\") (regex #")"
_DOTB_LINE="$(line_no "$ROOT/profB.sbpl" ';; --- dotenv protection ---')"
if [ -n "$_GCALLOW_LAST" ] && [ -n "$_NESTED_LINE" ] && [ "$_GCALLOW_LAST" -gt "$_NESTED_LINE" ]; then
  ok "wtB: Git root の read 復元 allow は scoped deny より後"
else
  ng "wtB: Git root の read 復元 allow が scoped deny より前/欠落 (restore='$_GCALLOW_LAST' nested='$_NESTED_LINE')"
fi
if [ -n "$_GCALLOW_LAST" ] && [ -n "$_DOTB_LINE" ] && [ "$_GCALLOW_LAST" -lt "$_DOTB_LINE" ]; then
  ok "wtB: Git root の read 復元 allow は dotenv deny より前"
else
  ng "wtB: Git root の read 復元 allow の位置が不正 (restore='$_GCALLOW_LAST' dotenv='$_DOTB_LINE')"
fi
audit_profile "$P_BASE_B" "$ROOT/profB.sbpl" "wtB"
t "wtB: sandboxed git status が成功" probe_git "$ROOT/profB.sbpl" /usr/bin/git -C "$WT_B" status --porcelain
t "wtB: sandboxed git log が成功" probe_git "$ROOT/profB.sbpl" /usr/bin/git -C "$WT_B" log --oneline -1
t_eq "wtB: HEAD が sandbox 外と一致" "$(GITX -C "$WT_B" rev-parse HEAD)" \
  "$(probe_git "$ROOT/profB.sbpl" /usr/bin/git -C "$WT_B" rev-parse HEAD)"
t "wtB: repoA の通常ファイルを読める" probe "$ROOT/profB.sbpl" /bin/cat "$REPO_A/a.txt"
t_not "wtB: repoA に書き込めない" probe "$ROOT/profB.sbpl" /bin/bash -c "echo x > '$REPO_A/probe.txt'"
t_not "wtB: repoA の .env は読めない" probe "$ROOT/profB.sbpl" /bin/cat "$REPO_A/.env"
t_not "wtB: 共通管理領域に書き込めない" probe "$ROOT/profB.sbpl" /bin/bash -c "echo x > '$COMMON_REAL/omps_probe'"
t "wtB: 自身の workspace に書き込める" probe "$ROOT/profB.sbpl" /bin/bash -c "echo ok > '$WT_B/probe.txt'"
t_not "wtB: 中間ディレクトリの readdir は不可" probe "$ROOT/profB.sbpl" /bin/ls "$ROOT"
t "wtB: 中間ディレクトリの stat は可能" probe "$ROOT/profB.sbpl" /usr/bin/stat -f %Su "$ROOT"
t_not "wtB: git add は失敗する（write を増やさない）" probe_git "$ROOT/profB.sbpl" /usr/bin/git -C "$WT_B" add probe.txt

# =================================================== 4. worktree 候補の skip / guard
printf '\n== 4. registered worktree の検証・skip・sensitive/socket guard ==\n'
GITX -C "$REPO_A" worktree add -q -b wtClean "$WT_CLEAN"
printf 'clean\n' > "$WT_CLEAN/clean.txt"
GITX -C "$REPO_A" worktree add -q -b wtSecret "$WT_SECRET"
printf 'normal\n' > "$WT_SECRET/normal.txt"
mkdir -p "$WT_SECRET/.ssh" "$WT_SECRET/.aws" "$WT_SECRET/.docker"
printf 'synthetic ssh\n' > "$WT_SECRET/.ssh/id_synthetic"
printf 'synthetic aws\n' > "$WT_SECRET/.aws/credentials_synthetic"
printf '{}\n' > "$WT_SECRET/.docker/config_synthetic.json"
mkdir -p "$WT_SECRET/nested/.ssh"
printf 'synthetic key\n' > "$WT_SECRET/nested/id_ed25519"
printf 'synthetic key\n' > "$WT_SECRET/nested/server.key"
printf 'synthetic public key\n' > "$WT_SECRET/nested/id_ed25519.pub"
printf 'synthetic credential\n' > "$WT_SECRET/nested/.ssh/secret"
GITX -C "$REPO_A" worktree add -q -b wtSock "$WT_SOCK"
printf 'sock worktree\n' > "$WT_SOCK/normal.txt"
GITX -C "$REPO_A" worktree add -q -b wtGone "$WT_GONE"
/bin/rm -rf "$WT_GONE"
chmod 700 "$WT_SECRET/.ssh" "$WT_SECRET/.aws" "$WT_SECRET/.docker" 2>/dev/null || true

run_cand_plan "$REPO_A" "$ROOT/planC.txt" "$ROOT/planC.err"; RC=$?
t_eq "worktree 群: --print-plan が exit 0" "0" "$RC"
PLAN_C="$(cat "$ROOT/planC.txt")"
t_contains "worktree 群: WORKTREE_ENUM=ok" "WORKTREE_ENUM=ok" "$PLAN_C"
t_plan_has "worktree 群: WORKTREE_READ に wtClean" "$PLAN_C" WORKTREE_READ "$WT_CLEAN"
t_plan_has "worktree 群: WORKTREE_READ に wtSecret" "$PLAN_C" WORKTREE_READ "$WT_SECRET"
t_plan_has "worktree 群: WORKTREE_READ に wtSock" "$PLAN_C" WORKTREE_READ "$WT_SOCK"
t_plan_not_has "worktree 群: prunable wtGone は read しない" "$PLAN_C" WORKTREE_READ "$WT_GONE"
t_plan_skip "worktree 群: wtGone は prunable で skip" "$PLAN_C" "$WT_GONE:prunable"
t_contains "worktree 群: skip 警告を stderr に出す" "worktree をスキップ" "$(cat "$ROOT/planC.err")"
t_plan_count "worktree 群: SOCKET_GUARD は read 数と一致" "$PLAN_C" SOCKET_GUARD "$(plan_count "$PLAN_C" WORKTREE_READ)"

run_cand_profile "$REPO_A" "$ROOT/profC.sbpl" "$ROOT/profC.err"; RC=$?
t_eq "worktree 群: --print-profile が exit 0" "0" "$RC"
t_profile_has "worktree 群: wtSecret の通常ファイル allow" "$ROOT/profC.sbpl" "(subpath \"$WT_SECRET\")"
t_profile_has "worktree 群: wtSecret/.ssh deny" "$ROOT/profC.sbpl" "(deny file-read* (subpath \"$WT_SECRET/.ssh\"))"
t_profile_has "worktree 群: wtSecret/.aws deny" "$ROOT/profC.sbpl" "(deny file-read* (subpath \"$WT_SECRET/.aws\"))"
t_profile_has "worktree 群: wtSecret/.docker deny" "$ROOT/profC.sbpl" "(deny file-read* (subpath \"$WT_SECRET/.docker\"))"
t_profile_has "worktree 群: wtSock の socket guard は require-all 交差" "$ROOT/profC.sbpl" "(deny file-read* (require-all (subpath \"$WT_SOCK\") (vnode-type SOCKET)))"
t_profile_not_has "worktree 群: wtSock の socket guard に OR 形式を使わない" "$ROOT/profC.sbpl" "(deny file-read* (subpath \"$WT_SOCK\") (vnode-type SOCKET))"
t_profile_not_has "worktree 群: wtGone は profile に現れない" "$ROOT/profC.sbpl" "$WT_GONE"
t "worktree 群: wtSecret の通常ファイルは読める" probe "$ROOT/profC.sbpl" /bin/cat "$WT_SECRET/normal.txt"
t_not "worktree 群: wtSecret/.ssh のファイルは読めない" probe "$ROOT/profC.sbpl" /bin/cat "$WT_SECRET/.ssh/id_synthetic"
t_not "worktree 群: wtSecret/.aws のファイルは読めない" probe "$ROOT/profC.sbpl" /bin/cat "$WT_SECRET/.aws/credentials_synthetic"
t_not "worktree 群: wtSecret/.docker のファイルは読めない" probe "$ROOT/profC.sbpl" /bin/cat "$WT_SECRET/.docker/config_synthetic.json"
t_not "ネストされた .ssh は読めない" probe "$ROOT/profC.sbpl" /bin/cat "$WT_SECRET/nested/.ssh/secret"
t_not "秘密鍵 id_ed25519 は読めない" probe "$ROOT/profC.sbpl" /bin/cat "$WT_SECRET/nested/id_ed25519"
t_not ".key は読めない" probe "$ROOT/profC.sbpl" /bin/cat "$WT_SECRET/nested/server.key"
t "公開鍵 .pub は読める" probe "$ROOT/profC.sbpl" /bin/cat "$WT_SECRET/nested/id_ed25519.pub"

# ---------------------------------------- 5. extra read（合成パスのみ）
printf '\n== 5. OMPS_EXTRA_READ（起動時限定の追加読み取り）==\n'
run_cand_plan "$WT_B" "$ROOT/planR1.txt" "$ROOT/planR1.err" OMPS_EXTRA_READ="$DOCS1"; RC=$?
t_eq "extra read: --print-plan が exit 0" "0" "$RC"
PLAN_R1="$(cat "$ROOT/planR1.txt")"
t_plan_has "extra read: EXTRA_READ_PATH に docs1" "$PLAN_R1" EXTRA_READ_PATH "$DOCS1"
if plan_has "$PLAN_R1" SOCKET_GUARD "$DOCS1"; then ok "extra read: docs1 に SOCKET_GUARD がある"; else note "extra read: docs1 に SOCKET_GUARD が無い（socket 拡大の有無を実行時比較で確認）"; fi
run_cand_profile "$WT_B" "$ROOT/profR1.sbpl" "$ROOT/profR1.err" OMPS_EXTRA_READ="$DOCS1"; RC=$?
t_eq "extra read: --print-profile が exit 0" "0" "$RC"
t_profile_has "extra read: docs1 の subpath" "$ROOT/profR1.sbpl" "(subpath \"$DOCS1\")"
if plan_has "$PLAN_R1" SOCKET_GUARD "$DOCS1"; then
  t_profile_has "extra read: docs1 の socket guard は require-all 交差" "$ROOT/profR1.sbpl" "(deny file-read* (require-all (subpath \"$DOCS1\") (vnode-type SOCKET)))"
  t_profile_not_has "extra read: docs1 の socket guard に OR 形式を使わない" "$ROOT/profR1.sbpl" "(deny file-read* (subpath \"$DOCS1\") (vnode-type SOCKET))"
  t_profile_has "extra read: docs1 の network-outbound guard" "$ROOT/profR1.sbpl" "(deny network-outbound (subpath \"$DOCS1\"))"
fi
t "extra read: docs1 を実際に読める" probe "$ROOT/profR1.sbpl" /bin/cat "$DOCS1/note.md"
t_not "extra read: 指定外の docs2 は読めない" probe "$ROOT/profR1.sbpl" /bin/cat "$DOCS2/note.md"
t_not "extra read: docs1 に書き込めない" probe "$ROOT/profR1.sbpl" /bin/bash -c "echo x > '$DOCS1/probe.txt'"
printf 'SECRET=3\n' > "$DOCS1/.env"
t_not "extra read: docs1 の .env も読めない" probe "$ROOT/profR1.sbpl" /bin/cat "$DOCS1/.env"
/bin/rm -f "$DOCS1/.env"
t_not "extra read: docs1 の親 readdir は不可" probe "$ROOT/profR1.sbpl" /bin/ls "$ROOT"

run_cand_profile "$WT_B" "$ROOT/profR2.sbpl" "$ROOT/profR2.err" OMPS_EXTRA_READ="$DOCS1:$DOCS2"; RC=$?
t_eq "extra read: 複数指定の --print-profile が exit 0" "0" "$RC"
t "extra read: 複数指定 docs1" probe "$ROOT/profR2.sbpl" /bin/cat "$DOCS1/note.md"
t "extra read: 複数指定 docs2" probe "$ROOT/profR2.sbpl" /bin/cat "$DOCS2/note.md"

# 既存の guard と重なる extra read は worktree 側を自動追加しない
run_cand_plan "$REPO_A" "$ROOT/planOverlap.txt" "$ROOT/planOverlap.err" OMPS_EXTRA_READ="$WT_B"; RC=$?
t_eq "overlap: --print-plan が exit 0" "0" "$RC"
PLAN_OV="$(cat "$ROOT/planOverlap.txt")"
t_plan_has "overlap: EXTRA_READ_PATH に wtB" "$PLAN_OV" EXTRA_READ_PATH "$WT_B"
t_plan_skip "overlap: wtB は extra-read-overlap で skip" "$PLAN_OV" "$WT_B:extra-read-overlap"
t_plan_not_has "overlap: wtB を WORKTREE_READ に重複させない" "$PLAN_OV" WORKTREE_READ "$WT_B"
t_eq "overlap: SOCKET_GUARD 数は read 数と一致" "$(plan_count "$PLAN_OV" WORKTREE_READ)" "$(plan_count "$PLAN_OV" SOCKET_GUARD)"

# ---------------------------------------- 6. 異常指定は fail closed
printf '\n== 6. 異常指定・機密パスは fail closed ==\n'
bad() { local d="$1"; shift; ( cd "$d" && /usr/bin/env PATH="$TEST_PATH" "$@" "$L" --print-profile >/dev/null 2>"$ROOT/bad.err" ); echo $?; }
mkdir -p "$ROOT/.ssh" "$ROOT/.aws" "$ROOT/Keychains"
RC="$(bad "$WT_B" OMPS_EXTRA_READ="$ROOT/.ssh")"; t_eq "合成 .ssh を拒否" "1" "$RC"
t_contains "  理由が機密判定" "機密パス" "$(cat "$ROOT/bad.err")"
RC="$(bad "$WT_B" OMPS_EXTRA_READ="$ROOT/.aws")"; t_eq "合成 .aws を拒否" "1" "$RC"
RC="$(bad "$WT_B" OMPS_EXTRA_READ="$ROOT/Keychains")"; t_eq "合成 Keychains を拒否" "1" "$RC"
ln -sfn "$ROOT/.ssh" "$ROOT/sshlink"
RC="$(bad "$WT_B" OMPS_EXTRA_READ="$ROOT/sshlink")"; t_eq "シンボリックリンク経由の機密パスを拒否" "1" "$RC"
RC="$(bad "$WT_B" OMPS_EXTRA_READ="$HOME")"; t_eq "\$HOME 自体を拒否" "1" "$RC"
RC="$(bad "$WT_B" OMPS_EXTRA_READ="/")"; t_eq "/ を拒否" "1" "$RC"
RC="$(bad "$WT_B" OMPS_EXTRA_READ="docs1")"; t_eq "相対パスを拒否" "1" "$RC"
RC="$(bad "$WT_B" OMPS_EXTRA_READ="$ROOT/nope")"; t_eq "存在しないパスを拒否" "1" "$RC"
RC="$(bad "$WT_B" OMPS_EXTRA_READ="$DOCS1/../outside.txt")"; t_eq ".. を含むパスを拒否" "1" "$RC"
RC="$(bad "$WT_B" OMPS_EXTRA_READ="$DOCS1"$'\n'"x")"; t_eq "制御文字（改行）を含むパスを拒否" "1" "$RC"
RC="$(bad "$WT_B" OMP_SANDBOX_EXTRA_READ="$HOME/.ssh")"; t_eq "OMP_SANDBOX_EXTRA_READ 直接指定を拒否" "1" "$RC"
RC="$(bad "$WT_B" OMP_SANDBOX_EXTRA_WRITE="$DOCS1")"; t_eq "OMP_SANDBOX_EXTRA_WRITE を拒否" "1" "$RC"
( cd "$WT_B" && /usr/bin/env PATH="$TEST_PATH" OMPS_EXTRA_READ="" "$L" --print-plan > "$ROOT/planEmpty.txt" 2>&1 ); RC=$?
t_eq "空文字は未指定として扱う" "0" "$RC"
t_not_contains "  追加読み取りが増えない" "EXTRA_READ_PATH=" "$(cat "$ROOT/planEmpty.txt")"

# ---------------------------------------- 7. 親 AGENTS.md の追加ケース
printf '\n== 7. 親 AGENTS.md（symlink / skip）==\n'
GITX init -q "$ROOT/symParent/repoS"
printf 's\n' > "$ROOT/symParent/repoS/s.txt"
GITX -C "$ROOT/symParent/repoS" add s.txt && GITX -C "$ROOT/symParent/repoS" commit -qm "s"
run_cand_plan "$ROOT/symParent/repoS" "$ROOT/planSym.txt" "$ROOT/planSym.err"; RC=$?
t_eq "AGENTS symlink: --print-plan が exit 0" "0" "$RC"
PLAN_SYM="$(cat "$ROOT/planSym.txt")"
t_plan_not_has "AGENTS symlink: 祖先パスを許可しない" "$PLAN_SYM" PARENT_AGENTS "$ROOT/symParent/AGENTS.md"
t_plan_not_has "AGENTS symlink: 解決先を許可しない" "$PLAN_SYM" PARENT_AGENTS "$ROOT/agents-real.md"
run_cand_profile "$ROOT/symParent/repoS" "$ROOT/profSym.sbpl" "$ROOT/profSym.err"; RC=$?
t_eq "AGENTS symlink: --print-profile が exit 0" "0" "$RC"
t_not "AGENTS symlink: 祖先パスから読めない" probe "$ROOT/profSym.sbpl" /bin/cat "$ROOT/symParent/AGENTS.md"
t_not "AGENTS symlink: 解決先も読めない" probe "$ROOT/profSym.sbpl" /bin/cat "$ROOT/agents-real.md"
t_not "AGENTS symlink: 兄弟ファイルは読めない" probe "$ROOT/profSym.sbpl" /bin/cat "$ROOT/agents-other.md"

GITX init -q "$ROOT/parentSkip/repoD"
printf 'd\n' > "$ROOT/parentSkip/repoD/d.txt"
GITX -C "$ROOT/parentSkip/repoD" add d.txt && GITX -C "$ROOT/parentSkip/repoD" commit -qm "d"
run_cand_plan "$ROOT/parentSkip/repoD" "$ROOT/planSkip.txt" "$ROOT/planSkip.err"; RC=$?
t_eq "AGENTS skip: --print-plan が exit 0" "0" "$RC"
PLAN_SKIP="$(cat "$ROOT/planSkip.txt")"
t_contains "AGENTS skip: PARENT_AGENTS_SKIP にディレクトリ" "PARENT_AGENTS_SKIP=$ROOT/parentSkip/AGENTS.md:" "$PLAN_SKIP"
t_contains "AGENTS skip: stderr に親 AGENTS 警告" "親 AGENTS.md をスキップ" "$(cat "$ROOT/planSkip.err")"
run_cand_profile "$ROOT/parentSkip/repoD" "$ROOT/profSkip.sbpl" "$ROOT/profSkip.err"; RC=$?
t_eq "AGENTS skip: --print-profile が exit 0" "0" "$RC"
t_profile_not_has "AGENTS skip: ディレクトリの literal を出さない" "$ROOT/profSkip.sbpl" "(literal \"$ROOT/parentSkip/AGENTS.md\")"

# ---------------------------------------- 8. 列挙失敗時の全体フォールバック
printf '\n== 8. Git worktree 列挙失敗時の全体フォールバック ==\n'
REPO_FAIL="$ROOT/repoFail"
WT_FAIL="$ROOT/wtFail"
GITX init -q "$REPO_FAIL"
printf 'f\n' > "$REPO_FAIL/f.txt"
GITX -C "$REPO_FAIL" add f.txt && GITX -C "$REPO_FAIL" commit -qm "f"
GITX -C "$REPO_FAIL" worktree add -q -b wtFail "$WT_FAIL"
printf 'wf\n' > "$WT_FAIL/wf.txt"
/bin/chmod 000 "$REPO_FAIL/.git/worktrees" 2>/dev/null || true
( cd "$REPO_FAIL" && /usr/bin/env PATH="$TEST_PATH" "$L" --print-plan > "$ROOT/planFail.txt" 2>"$ROOT/planFail.err" ); RC=$?
( cd "$REPO_FAIL" && /usr/bin/env PATH="$TEST_PATH" "$L" --print-profile > "$ROOT/profFail.sbpl" 2>"$ROOT/profFail.ex.err" ); RC_PROF=$?
/bin/chmod 700 "$REPO_FAIL/.git/worktrees" 2>/dev/null || true
t_eq "enum failure: --print-plan は exit 0（停止しない）" "0" "$RC"
PLAN_FAIL="$(cat "$ROOT/planFail.txt")"
ENUM_FAIL="$(plan_vals "$PLAN_FAIL" WORKTREE_ENUM)"
case "$ENUM_FAIL" in
  untrusted)
    ok "enum failure: WORKTREE_ENUM=untrusted"
    t_plan_count "enum failure: WORKTREE_AUTO_ROOTS=0" "$PLAN_FAIL" WORKTREE_AUTO_ROOTS "0"
    t_plan_count "enum failure: WORKTREE_READ なし" "$PLAN_FAIL" WORKTREE_READ "0"
    t_contains "enum failure: 全体警告を stderr に出す" "登録 worktree の自動読み取りをすべて無効化" "$(cat "$ROOT/planFail.err")" ;;
  ok)
    note "enum failure: git が列挙を継続できたため untrusted には至らない（自動 root が無いことを確認）"
    t_plan_count "enum failure: WORKTREE_READ なし" "$PLAN_FAIL" WORKTREE_READ "0" ;;
  *)
    ng "enum failure: WORKTREE_ENUM が想定外 ('$ENUM_FAIL')" ;;
esac
t_plan_not_has "enum failure: wtFail を read しない" "$PLAN_FAIL" WORKTREE_READ "$WT_FAIL"
t_eq "enum failure: --print-profile は exit 0" "0" "$RC_PROF"
t_profile_not_has "enum failure: profile に wtFail を追加しない" "$ROOT/profFail.sbpl" "$WT_FAIL"
t "enum failure: workspace 自身は従来どおり読み書きできる" probe "$ROOT/profFail.sbpl" /bin/bash -c "echo ok > '$REPO_FAIL/probe.txt'"

# ---------------------------------------- 9. 合成 Unix / TCP socket 比較
printf '\n== 9. 合成 Unix / TCP socket: baseline vs candidate（実 Docker 不使用）==\n'
cat > "$ROOT/socket_server.py" <<'PY'
import os, socket, sys
kind, arg, ready = sys.argv[1], sys.argv[2], sys.argv[3]
if kind == "unix":
    try:
        os.unlink(arg)
    except OSError:
        pass
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.bind(arg)
    s.listen(64)
    with open(ready, "w") as f:
        f.write("unix")
else:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("127.0.0.1", 0))
    s.listen(64)
    with open(ready, "w") as f:
        f.write(str(s.getsockname()[1]))
s.settimeout(0.2)
while True:
    try:
        c, _ = s.accept()
    except socket.timeout:
        continue
    except OSError:
        break
    try:
        c.close()
    except OSError:
        pass
PY
/bin/chmod 700 "$ROOT/socket_server.py"

start_server() { # kind arg ready
  local kind="$1" arg="$2" ready="$3" pid
  /usr/bin/python3 "$ROOT/socket_server.py" "$kind" "$arg" "$ready" >>"$ROOT/socket-server.log" 2>&1 &
  pid=$!
  SERVER_PIDS="$SERVER_PIDS $pid"
  local i=0
  while [ "$i" -lt 100 ]; do
    [ -s "$ready" ] && return 0
    /bin/sleep 0.1
    i=$((i + 1))
  done
  return 1
}

SOCK_WS="$REPO_A/sock-workspace.sock"
SOCK_OUT="$ROOT/sock-outside.sock"
SOCK_WTSOCK="$WT_SOCK/sock-synthetic.sock"
SOCK_RACE="$WT_CLEAN/sock-race.sock"
SOCK_DOCS="$DOCS1/sock-extra.sock"
TCP_READY="$ROOT/tcp.ready"

TCP_OK=0; UNIX_OK=0; UNIX_COMPARE_OK=0; TCP_COMPARE_OK=0
if start_server tcp "" "$TCP_READY"; then
  TCP_PORT="$(cat "$TCP_READY")"
  # macOS の nc は TCP なら -z も使えるが、Unix socket と同じ接続方式に統一する。
  if /usr/bin/nc -w 2 127.0.0.1 "$TCP_PORT" </dev/null >/dev/null 2>&1; then TCP_OK=1; else ng "合成 TCP リスナーに sandbox 外から接続できない"; fi
else
  ng "合成 TCP リスナーを起動できない"
fi
if start_server unix "$SOCK_WS" "$ROOT/ws.ready" && start_server unix "$SOCK_OUT" "$ROOT/out.ready" \
   && start_server unix "$SOCK_WTSOCK" "$ROOT/wtsock.ready"; then
  UNIX_OK=1
else
  ng "合成 Unix リスナーを起動できない"
fi

# macOS の /usr/bin/nc は Unix socket に対して -z を併用できない（接続できても
# rc=1 になる）。そのため「接続して stdin の EOF で終了する」方式で判定する。
# これが旧 harness の Unix socket 比較が常に SKIP していた原因。
unix_probe() { local p="$1" path="$2"
  /usr/bin/env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin TMPDIR="$TMPDIR_CANON" \
    /usr/bin/sandbox-exec -f "$p" /usr/bin/nc -U -w 2 "$path" </dev/null >/dev/null 2>&1; }
tcp_probe() { local p="$1" port="$2"
  /usr/bin/env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin TMPDIR="$TMPDIR_CANON" \
    /usr/bin/sandbox-exec -f "$p" /usr/bin/nc -w 2 127.0.0.1 "$port" </dev/null >/dev/null 2>&1; }
outcome() { if "$@" >/dev/null 2>&1; then echo allow; else echo deny; fi; }

# probe の対照: 同じコマンドを実行できるポリシーで network-outbound の
# 許可と拒否を比較する。制御が成立しなければ SKIP（exit 2）にする。
P_CTRL_ALLOW="$ROOT/ctl-allow.sbpl"
P_CTRL_DENY="$ROOT/ctl-deny.sbpl"
printf '(version 1)\n(allow default)\n' > "$P_CTRL_ALLOW"
printf '(version 1)\n(allow default)\n(deny network-outbound)\n' > "$P_CTRL_DENY"

if [ "$UNIX_OK" = 1 ]; then
  if /usr/bin/nc -U -w 2 "$SOCK_WS" </dev/null >/dev/null 2>&1; then
    ok "sandbox 外から合成 Unix socket (workspace) に接続できる"
  else
    skip "合成 Unix socket の sandbox 外接続が不可（nc -U 非対応等）"
    UNIX_OK=0
  fi
fi
if [ "$UNIX_OK" = 1 ]; then
  CTL_U_ALLOW="$(outcome unix_probe "$P_CTRL_ALLOW" "$SOCK_WS")"
  CTL_U_DENY="$(outcome unix_probe "$P_CTRL_DENY" "$SOCK_WS")"
  if [ "$CTL_U_ALLOW" = allow ] && [ "$CTL_U_DENY" = deny ]; then
    ok "Unix socket probe の対照（network allow / deny）"
    UNIX_COMPARE_OK=1
  else
    skip "Unix socket probe の対照が不成立（allow=${CTL_U_ALLOW} / deny=${CTL_U_DENY}）のため比較をスキップ"
  fi
fi
if [ "$TCP_OK" = 1 ]; then
  CTL_T_ALLOW="$(outcome tcp_probe "$P_CTRL_ALLOW" "$TCP_PORT")"
  CTL_T_DENY="$(outcome tcp_probe "$P_CTRL_DENY" "$TCP_PORT")"
  if [ "$CTL_T_ALLOW" = allow ] && [ "$CTL_T_DENY" = deny ]; then
    ok "TCP loopback probe の対照（network allow / deny）"
    TCP_COMPARE_OK=1
  else
    skip "TCP loopback probe の対照が不成立（allow=${CTL_T_ALLOW} / deny=${CTL_T_DENY}）のため比較をスキップ"
  fi
fi

if [ "$UNIX_COMPARE_OK" = 1 ]; then
  # profile 生成時点で既に存在する socket と、生成後に作る socket（race）を分離
  P_SOCK="$ROOT/profSock.sbpl"
  run_cand_profile "$REPO_A" "$P_SOCK" "$ROOT/profSock.err"; RC=$?
  t_eq "socket: 既存 socket 込みの --print-profile が exit 0" "0" "$RC"
  P_RACE="$ROOT/profRace.sbpl"
  run_cand_profile "$REPO_A" "$P_RACE" "$ROOT/profRace.err"; RC=$?
  t_eq "socket: race 用 --print-profile が exit 0" "0" "$RC"
  # race 用 profile を作った後に socket を作成（起動時スキャンでは見えない）
  if start_server unix "$SOCK_RACE" "$ROOT/race.ready"; then
    ok "race 用合成 Unix socket を profile 生成後に作成"
  else
    ng "race 用合成 Unix socket を作成できない"
  fi
  P_EXTRA_SOCK="$ROOT/profExtraSock.sbpl"
  run_cand_profile "$REPO_A" "$P_EXTRA_SOCK" "$ROOT/profExtraSock.err" OMPS_EXTRA_READ="$DOCS1"; RC=$?
  t_eq "socket: extra-read 用 --print-profile が exit 0" "0" "$RC"
  P_BASE_EXTRA="$ROOT/baseExtra.sbpl"
  base_prof "$REPO_A" "$DOCS1" > "$P_BASE_EXTRA" || ng "socket: extra-read 基礎ポリシー生成"
  if start_server unix "$SOCK_DOCS" "$ROOT/docs.ready"; then
    ok "extra-read 用合成 Unix socket を profile 生成後に作成"
  else
    ng "extra-read 用合成 Unix socket を作成できない"
  fi

  # 実ポリシー下で workspace socket が allow にならなければ、probe が接続を
  # 観測できていない（deny==deny の空比較になる）ため比較を打ち切る。
  B_WS="$(outcome unix_probe "$P_BASE_A" "$SOCK_WS")"
  if [ "$B_WS" = allow ]; then
    ok "Unix workspace socket: 基礎ポリシーで接続できる（probe 有効）"
  else
    skip "Unix workspace socket: 基礎ポリシーで接続できず比較不能（probe 無効）"
    UNIX_COMPARE_OK=0
  fi
fi

if [ "$UNIX_COMPARE_OK" = 1 ]; then
  C_WS="$(outcome unix_probe "$P_SOCK" "$SOCK_WS")"
  t_eq "Unix workspace socket: 既存挙動を変えない" "$B_WS" "$C_WS"
  note "Unix workspace socket: baseline=$B_WS candidate=$C_WS"

  B_OUT="$(outcome unix_probe "$P_BASE_A" "$SOCK_OUT")"
  C_OUT="$(outcome unix_probe "$P_SOCK" "$SOCK_OUT")"
  if [ "$B_OUT" = deny ] && [ "$C_OUT" = allow ]; then ng "Unix HOME 外側 socket: candidate が接続を拡大した"; else ok "Unix HOME 外側 socket: 拡大しない (baseline=$B_OUT candidate=$C_OUT)"; fi

  B_WTS="$(outcome unix_probe "$P_BASE_A" "$SOCK_WTSOCK")"
  C_WTS="$(outcome unix_probe "$P_SOCK" "$SOCK_WTSOCK")"
  if [ "$B_WTS" = deny ] && [ "$C_WTS" = allow ]; then ng "Unix worktree socket（既存）: candidate が接続を拡大した"; else ok "Unix worktree socket（既存）: 拡大しない (baseline=$B_WTS candidate=$C_WTS)"; fi

  # SOCKET_GUARD は path 述語（require-all）なので、profile 生成後に作られた
  # socket にも適用されるはず。scan 依存の実装ならここで allow に転ぶ。
  B_RACE="$(outcome unix_probe "$P_BASE_A" "$SOCK_RACE")"
  C_RACE="$(outcome unix_probe "$P_RACE" "$SOCK_RACE")"
  if [ "$B_RACE" = deny ] && [ "$C_RACE" = allow ]; then
    ng "Unix worktree socket（profile 生成後の race）: candidate が接続を拡大した（path 述語でない）"
  else
    ok "Unix worktree socket（race）: 拡大しない (baseline=$B_RACE candidate=$C_RACE)"
  fi

  B_DOCS="$(outcome unix_probe "$P_BASE_EXTRA" "$SOCK_DOCS")"
  C_DOCS="$(outcome unix_probe "$P_EXTRA_SOCK" "$SOCK_DOCS")"
  if [ "$B_DOCS" = deny ] && [ "$C_DOCS" = allow ]; then
    ng "Unix extra-read socket: 同一 extra-read の基礎ポリシーより接続を拡大した"
  else
    ok "Unix extra-read socket: 既存の extra-read 挙動を拡大しない (baseline=$B_DOCS candidate=$C_DOCS)"
  fi
  note "extra-read 内の Unix socket は user 指定パスの既存挙動。SOCKET_GUARD は worktree 自動追加ルート限定"
  note "Unix socket 比較は合成 socket のみ。実 Docker socket の全経路を保証しない"
fi

if [ "$TCP_COMPARE_OK" = 1 ]; then
  P_TCP="$ROOT/profTcp.sbpl"
  run_cand_profile "$REPO_A" "$P_TCP" "$ROOT/profTcp.err"; RC=$?
  t_eq "TCP: --print-profile が exit 0" "0" "$RC"
  B_TCP="$(outcome tcp_probe "$P_BASE_A" "$TCP_PORT")"
  if [ "$B_TCP" = allow ]; then
    ok "TCP loopback: 基礎ポリシーで接続できる（probe 有効）"
  else
    skip "TCP loopback: 基礎ポリシーで接続できず比較不能（probe 無効）"
    TCP_COMPARE_OK=0
  fi
fi
if [ "$TCP_COMPARE_OK" = 1 ]; then
  C_TCP="$(outcome tcp_probe "$P_TCP" "$TCP_PORT")"
  t_eq "TCP loopback: 既存のネットワーク挙動を変えない" "$B_TCP" "$C_TCP"
  note "TCP 127.0.0.1 合成リスナー: baseline=${B_TCP} candidate=${C_TCP}（実 Docker TCP は未検証）"
fi
stop_servers

# ---------------------------------------- 10. 起動（スタブ omp）と環境
printf '\n== 10. 起動・引数転送・クリーン環境（スタブ omp）==\n'
run_stub() { local d="$1"; shift; /bin/rm -f "$STUB_OUT"
  ( cd "$d" && /usr/bin/env PATH="$TEST_PATH" "$@" ) 2>>"${STUB_ERR:-$ROOT/stub-stderr.log}"; }
STUB_CONTENT() { cat "$STUB_OUT" 2>/dev/null || true; }

run_stub "$REPO_A" OMP_SANDBOX_YOLO=1 "$L" --foo bar --baz=1 --version
t "スタブ omp が起動した（sandbox-exec 経由）" test -f "$STUB_OUT"
t_contains "自動承認 --auto-approve が付与される" "ARG --auto-approve" "$(STUB_CONTENT)"
t_contains "--config が転送される" "ARG --config" "$(STUB_CONTENT)"
t_contains "sandbox.yml が指定される" "ARG $OMP_CONFIG" "$(STUB_CONTENT)"
t_contains "CLI 引数 --foo が転送される" "ARG --foo" "$(STUB_CONTENT)"
t_contains "CLI 引数 'bar' が転送される" "ARG bar" "$(STUB_CONTENT)"
t_contains "CLI 引数 --baz=1 が転送される" "ARG --baz=1" "$(STUB_CONTENT)"
t_contains "引数順序は auto-approve -> config -> user" "ARG --auto-approve.ARG --config.ARG $OMP_CONFIG.ARG --foo" \
  "$(/usr/bin/tr '\n' '.' < "$STUB_OUT")"
t_contains "Seatbelt が実効（\$HOME 直下への書き込み拒否）" "SEATBELT=on" "$(STUB_CONTENT)"
t_contains "sandbox marker (OMP_SANDBOX=seatbelt)" "OMP_SANDBOX=seatbelt" "$(STUB_CONTENT)"
t_contains "PI_SANDBOX=seatbelt" "PI_SANDBOX=seatbelt" "$(STUB_CONTENT)"
t_contains "AWS 認証情報を遮断 (AWS_SHARED_CREDENTIALS_FILE=/dev/null)" "AWS_SHARED_CREDENTIALS_FILE=/dev/null" "$(STUB_CONTENT)"
t_contains "AWS 認証情報を遮断 (AWS_CONFIG_FILE=/dev/null)" "AWS_CONFIG_FILE=/dev/null" "$(STUB_CONTENT)"
t_contains "git は \$HOME の gitconfig を読まない (GIT_CONFIG_GLOBAL=/dev/null)" "GIT_CONFIG_GLOBAL=/dev/null" "$(STUB_CONTENT)"

run_stub "$REPO_A" OMP_SANDBOX_YOLO=0 "$L" --version
t_not_contains "YOLO=0 では --auto-approve を付けない" "ARG --auto-approve" "$(STUB_CONTENT)"

run_stub "$REPO_A" OMP_SANDBOX_YOLO=1 HERDR_ENV=zellij HERDR_PANE_ID=pane-1 HERDR_SOCKET_PATH=/tmp/h.sock "$L" --version
t_contains "HERDR_ENV を引き継ぐ" "HERDR_ENV=zellij" "$(STUB_CONTENT)"
t_contains "HERDR_PANE_ID を引き継ぐ" "HERDR_PANE_ID=pane-1" "$(STUB_CONTENT)"
t_contains "HERDR_SOCKET_PATH を引き継ぐ" "HERDR_SOCKET_PATH=/tmp/h.sock" "$(STUB_CONTENT)"
t_not_contains "未設定の HERDR_* は作られない" "HERDR_TAB_ID=" "$(STUB_CONTENT)"

run_stub "$REPO_A" OMP_SANDBOX_YOLO=1 OMPS_TEST_CANARY=super-secret-123 "$L" --version
t_not_contains "クリーン環境: canary が漏れない" "OMPS_TEST_CANARY" "$(STUB_CONTENT)"
t_contains "クリーン環境: HOME は実ホーム" "HOME=$HOME" "$(STUB_CONTENT)"
t_contains "クリーン環境: 構文済み TMPDIR" "TMPDIR=$TMPDIR_CANON" "$(STUB_CONTENT)"

run_stub "$REPO_A" OMP_SANDBOX_YOLO=1 OMPS_TEST_CANARY=super-secret-123 OMP_SANDBOX_PASS_ENV=OMPS_TEST_CANARY "$L" --version
t_not_contains "呼び出し元 OMP_SANDBOX_PASS_ENV は置き換えられる" "OMPS_TEST_CANARY" "$(STUB_CONTENT)"

run_stub "$REPO_A" OMP_SANDBOX_YOLO=1 OMPS_AWS_MODE=1 "$L" --version
t_not_contains "AWS モード: AWS_* を /dev/null に潰さない" "AWS_SHARED_CREDENTIALS_FILE=/dev/null" "$(STUB_CONTENT)"
run_cand_plan "$REPO_A" "$ROOT/planAWS.txt" "$ROOT/planAWS.err" OMPS_AWS_MODE=1; RC=$?
t_eq "AWS モード: --print-plan が exit 0" "0" "$RC"
PLAN_AWS="$(cat "$ROOT/planAWS.txt")"
t_contains "AWS モード: CONFIRM_SENSITIVE_READ=1" "CONFIRM_SENSITIVE_READ=1" "$PLAN_AWS"
run_cand_profile "$REPO_A" "$ROOT/profAWS.sbpl" "$ROOT/profAWS.err" OMPS_AWS_MODE=1; RC=$?
t_eq "AWS モード: --print-profile が exit 0" "0" "$RC"
AWS_REAL="$(/usr/bin/readlink -f "$HOME/.aws" 2>/dev/null || echo "$HOME/.aws")"
t_profile_has "AWS モード: ~/.aws の読み取り許可" "$ROOT/profAWS.sbpl" "(subpath \"$AWS_REAL\")"
note "AWS モードの ~/.aws は実データを読まず、profile 上の許可だけを検証"

# 旧来の inherit env 抜け道（警告付き）
STUB_ERR="$ROOT/inherit.err" run_stub "$REPO_A" OMP_SANDBOX_YOLO=1 OMP_SANDBOX_INHERIT_ENV=1 OMPS_TEST_CANARY=super-secret-456 "$L" --version
t_contains "INHERIT_ENV=1: 親環境を渡す（非推奨）" "OMPS_TEST_CANARY=super-secret-456" "$(STUB_CONTENT)"
t_contains "INHERIT_ENV=1: 警告する" "OMP_SANDBOX_INHERIT_ENV=1" "$(cat "$ROOT/inherit.err")"

# 旧来の HOME 検証スキップ（実ホームへフォールバック）
( cd "$REPO_A" && /usr/bin/env -i HOME=/nonexistent PATH="$TEST_PATH" OMP_SANDBOX_SKIP_HOME_VERIFY=1 "$L" --print-plan > "$ROOT/planSkipHome.txt" 2>"$ROOT/skipHome.err" ); RC=$?
t_eq "SKIP_HOME_VERIFY=1: --print-plan が exit 0" "0" "$RC"
t_contains "SKIP_HOME_VERIFY=1: 警告する" "継承 HOME" "$(cat "$ROOT/skipHome.err")"
( cd "$REPO_A" && /usr/bin/env -i HOME=/nonexistent PATH="$TEST_PATH" "$L" --print-plan >/dev/null 2>"$ROOT/noSkipHome.err" ); RC=$?
t_eq "HOME 不一致は既定で拒否" "1" "$RC"
t_contains "  HOME 不一致の理由を出す" "HOME" "$(cat "$ROOT/noSkipHome.err")"

# ---------------------------------------- 11. 実データ非改変・後片付け
printf '\n== 11. 実データ非改変の確認 ==\n'
t_eq "稼働中ランチャーは未変更" "$BEFORE_DEPLOYED" "$(hash_of "$DEPLOYED")"
t_eq "既存ラッパーは未変更" "$BEFORE_WRAPPER" "$(hash_of "$SANDBOXED")"
t_eq "OmP 設定は未変更" "$BEFORE_CONFIG" "$(hash_of "$OMP_CONFIG")"

} # run_dynamic_suite

# helper definitions used by run_dynamic_suite (defined before call)
run_cand_plan() { local d="$1" out="$2" err="$3"; shift 3
  ( cd "$d" && /usr/bin/env PATH="${TEST_PATH:-/usr/bin:/bin:/usr/sbin:/sbin}" "$@" "$L" --print-plan ) >"$out" 2>"$err"; }
run_cand_profile() { local d="$1" out="$2" err="$3"; shift 3
  ( cd "$d" && /usr/bin/env PATH="${TEST_PATH:-/usr/bin:/bin:/usr/sbin:/sbin}" "$@" "$L" --print-profile ) >"$out" 2>"$err"; }

if [ "$SANDBOX_USABLE" = 1 ] && [ -x "$SANDBOXED" ] && [ -f "$OMP_CONFIG" ] && [ -x "$L" ]; then
  run_dynamic_suite
else
  [ "$SANDBOX_USABLE" = 1 ] && skip "既存ラッパーまたは OmP 設定が無いため動的検証をスキップ"
fi

printf '\n== 結果 ==\nPASS=%d FAIL=%d SKIP=%d NOTE=%d\n' "$PASS" "$FAIL" "$SKIP" "$NOTES"
printf '候補: %s\n' "$L"
[ "$FAIL" -eq 0 ] || exit 1
[ "$SKIP" -eq 0 ] && exit 0 || exit 2
