# oh-my-opencode の停止と設定整理

## 目的

oh-my-opencode の利用を停止し、専用設定と再生成可能なキャッシュを削除する。

## 変更内容

- OpenCode の plugin 設定から oh-my-opencode を削除する。
- oh-my-opencode 専用設定とシンボリックリンク設定を削除する。
- Pencil MCP を管理対象の `opencode.jsonc` に統合する。
- oh-my-opencode のキャッシュ依存とパッケージキャッシュを削除する。

## 保持対象

- OpenCode の標準モデル、small model、Playwright MCP、Pencil MCP、Herdr plugin
- バックアップファイル、DB バックアップ、`.sisyphus`、既存の履歴仕様
- Antigravity の依存パッケージ、アカウント情報、関連ロック情報

## 完了条件

- OpenCode の有効設定に oh-my-opencode が存在しない。
- Pencil、Playwright、Herdr、モデル設定が有効設定に残っている。
- 通常設定と再生成可能なキャッシュに oh-my-opencode が残っていない。
- 保持対象が削除されていない。
