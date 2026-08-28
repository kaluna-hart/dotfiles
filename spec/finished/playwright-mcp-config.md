# Playwright MCP 設定の安定化

## 目的

Playwright MCP の起動設定を特定の Node インストール先から切り離し、利用するパッケージバージョンを固定する。

## 変更内容

- Playwright MCP の実行コマンドを PATH 経由の `npx` にする。
- `@playwright/mcp` を `0.0.79` に固定する。
- Playwright MCP の `enabled` を明示する。

## 保持対象

- Pencil MCP
- 標準モデルと small model

## 完了条件

- OpenCode の有効設定に変更後の Playwright MCP コマンドが現れる。
- Pencil と Playwright の両 MCP が接続できる。
