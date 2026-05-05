# ~/.codex/agents dotfiles management

## Summary

`~/.codex/agents` を dotfiles の管理対象に追加する。既存の Codex 設定と同じく、repo 側に `codex/agents/` を持ち、`symlink.sh` で `~/.codex/agents` へ symlink する。

## Requirements

- 現在の `~/.codex/agents` 配下にある agent TOML を `codex/agents/` に追加する。
- `symlink.sh` の Codex セクションで `codex/agents` を `~/.codex/agents` に symlink する。
- `README.md` に Codex agents の管理パスを追記する。
- `auth.json`、履歴、ログ、キャッシュ、セッション、plugins、skills などは管理対象に含めない。
- 既存の `codex/AGENTS.md` と `codex/config.toml` の未コミット変更は変更しない。

## Verification

- `./symlink.sh --dry-run` で `~/.codex/agents` の symlink 作成または更新予定が表示されること。
- `codex/agents/` に5つの TOML が存在すること。
- `git status --short` で今回の追加・変更範囲が確認できること。
