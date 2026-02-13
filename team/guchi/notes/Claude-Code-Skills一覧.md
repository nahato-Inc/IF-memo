---
date: 2026-02-12
tags: [Claude Code, Skills, ツール]
status: active
---

# Claude Code Skills 一覧

## インストール済み（23個）

### オブ関連
| スキル | 内容 | ソース |
|--------|------|--------|
| obsidian-markdown | Obsidian Markdown記法のベスプラ | kepano（Obsidian公式） |
| obsidian-bases | Bases機能の使い方 | kepano（Obsidian公式） |

### DB関連
| スキル | 内容 | ソース |
|--------|------|--------|
| postgres-pro | PostgreSQLのベスプラ | jeffallan/claude-skills |
| neon-postgres | Neon（サーバーレスPostgres）連携 | neondatabase（公式） |

### 動画・アニメーション
| スキル | 内容 | ソース |
|--------|------|--------|
| remotion-best-practices | Remotionのベスプラ | プリインストール |
| remotion-animation | Remotionアニメーション特化 | ncklrs/startup-os-skills |
| video-motion-graphics | モーショングラフィックス全般 | dylantarre/animation-principles |
| motion-designer | アニメーション原則・モーションデザイン | dylantarre/animation-principles |
| ffmpeg | FFmpegでの動画処理・変換 | digitalsamba/claude-code-video-toolkit |

### デザイン・クリエイティブ
| スキル | 内容 | ソース |
|--------|------|--------|
| marketing-visual-design | マーケティング用ビジュアルデザイン | vasilyu1983/ai-agents-public |
| creative-coder | クリエイティブコーディング全般 | mae616/design-skills |
| mermaid-visualizer | Mermaidダイアグラム作成 | axtonliu/axton-obsidian-visual-skills |

### 開発ツール
| スキル | 内容 | ソース |
|--------|------|--------|
| git-advanced-workflows | Git高度なワークフロー | wshobson/agents |
| slack-bot-builder | Slackボット構築 | sickn33/antigravity-awesome-skills |
| keybindings-help | キーボードショートカットカスタマイズ | プリインストール |
| find-skills | スキル検索・インストール | プリインストール |

---

### セキュリティ
| スキル | 内容 | ソース |
|--------|------|--------|
| security-review | コードの脆弱性チェック | getsentry（Sentry公式） |

### コード品質
| スキル | 内容 | ソース |
|--------|------|--------|
| code-refactoring | リファクタリングのベスプラ | supercent-io/skills-template |
| typescript-best-practices | TypeScriptのベスプラ | 0xbigboss/claude-code |

### テスト
| スキル | 内容 | ソース |
|--------|------|--------|
| webapp-testing | Webアプリテスト | anthropics（Anthropic公式） |
| test-quality-analysis | テスト品質分析 | secondsky/claude-skills |

### インフラ
| スキル | 内容 | ソース |
|--------|------|--------|
| docker-expert | Docker構築・運用 | personamanagmentlayer/pcl |

---

## スキル管理コマンド

```bash
# スキル検索
npx skills find [キーワード]

# インストール
npx skills add <owner/repo@skill> -g -y

# アップデート確認
npx skills check

# 全スキルアップデート
npx skills update
```

---

_最終更新: 2026-02-12_
