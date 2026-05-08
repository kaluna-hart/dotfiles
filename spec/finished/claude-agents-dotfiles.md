# ~/.claude/agents dotfiles management

## Summary

`~/.claude/agents` を dotfiles の管理対象に追加する。既存の Claude 設定と同じく、repo 側に `claude/agents/` を持ち、`symlink.sh` で `~/.claude/agents` へ symlink する。

## Requirements

- `claude/agents/` を `~/.claude/agents` に symlink する。
- `README.md` に Claude settings、CLAUDE.md、agents の管理パスを追記する。
- 履歴、ログ、キャッシュ、セッション、plugins、skills、統計、telemetry などは管理対象に含めない。
- 既存の `claude/CLAUDE.md`、`codex/AGENTS.md`、`codex/config.toml` の未コミット変更は変更しない。

## Verification

- `./symlink.sh --dry-run` で `~/.claude/agents` の symlink 作成または更新予定が表示されること。
- 必要に応じて `~/.claude/agents` が `~/dotfiles/claude/agents` を指す symlink として作成されること。
- `git status --short` で今回の追加・変更範囲が確認できること。
