---
tags: [ANSEM, database, feature, bulk-import, memo]
created: 2026-02-12
updated: 2026-02-12
status: draft
related: "[[ANSEM-ER図]], [[ANSEM-データ投入運用方針]], [[ANSEM-追加機能ロードマップ]]"
---

# ANSEM 一括登録機能メモ

> [!NOTE]
> DB設計（v5.4.0）は完了済み。ここから先は**アプリ機能**の話。
> 依頼元: 一括登録用スプシフォーマット作成 + 重複防止の仕組み検討

---

## 現状の課題

- 既存スプシのIFマスタに乖離・重複が多い
- 非エンジニアがDBに直接データ投入するのは現実的でない（ID参照・FK依存順など）
- スプシからの移行にあたり「やさしいフォーマット」＋「変換の仕組み」が必要

---

## 方針

```
運用担当が書くスプシ（人間語）
    ↓ CSVダウンロード
Python スクリプト（バリデーション + ID変換 + 重複チェック）
    ↓
DB投入（INSERT SQL生成 / 直接投入）
```

| フェーズ | 方式 | 対象者 |
|---------|------|--------|
| Phase 1（初期投入） | エンジニアが直接SQL投入 | エンジニア |
| Phase 2（MVP運用） | やさしいスプシ＋変換スクリプト | 運用担当 |
| Phase 3（本番） | 管理画面（WebUI）で登録 | 全員 |

> [!TIP]
> gogcli（Google Workspace CLI）の認証設定が済めば、スプシ直接読み取りも可能。
> → [[gogcli導入ガイド]] 参照

---

## 1. 一括登録の対象テーブル一覧と投入順

### 投入順序（FK依存順）

| 順番 | テーブル | 日本語名 | 投入方式 | 備考 |
|------|---------|---------|---------|------|
| ① | m_countries | 国マスタ | エンジニア初期投入 | ISO準拠、変更なし |
| ② | m_departments | 部署マスタ | エンジニア初期投入 | 社内組織、少量 |
| ③ | m_categories | カテゴリマスタ | エンジニア初期投入 | ジャンル分類、少量 |
| ④ | m_agent_role_types | 役割マスタ | エンジニア初期投入 | 固定値、少量 |
| ⑤ | m_sns_platforms | SNSプラットフォーム | エンジニア初期投入 | YouTube/Instagram等、固定 |
| ⑥ | m_agents | エージェント | エンジニアor管理画面 | 社内メンバー、少量 |
| ⑦ | m_clients | クライアント | **一括登録対象** | 広告主企業 |
| ⑧ | m_ad_groups | 広告グループ | **一括登録対象** | 広告の大分類 |
| ⑨ | **m_influencers** | **インフルエンサー** | **一括登録対象（最優先）** | 最大データ量。既存スプシからの移行 |
| ⑩ | m_partners | パートナー | **一括登録対象** | ASP・配信パートナー |
| ⑪ | m_ad_contents | 広告コンテンツ | **一括登録対象** | 広告素材 |
| ⑫ | m_partners_division | パートナー区分 | エンジニアorスクリプト | IF卸/TM区分。m_partnersと同時 |
| ⑬ | t_partner_sites | パートナーサイト | **一括登録対象** | パートナーのサイト |
| ⑭ | t_influencer_sns_accounts | SNSアカウント | **一括登録対象** | IFのSNS情報 |
| ⑮ | m_campaigns | キャンペーン | **一括登録対象** | site×IF×platform |

> [!IMPORTANT]
> 最優先は **m_influencers**。既存スプシからの移行で乖離が多いため、バリデーション＋重複チェック付きで対応。

---

## 2. 現行スプシとの対応（カラムマッピング）

### 現行スプシの問題点

- 1シートに全情報がフラットに並んでいる（IF基本情報・SNS・口座・請求先・住所が混在）
- 不要列がある（ロボ番号、請求部屋番号）
- 列の並びに論理的なグループ分けがない
- ドロップダウンが少なく、自由入力でブレが発生しやすい
- SNS列に「Error: Unsupported provider」が表示されるバグあり

### 現行列 → 新DB マッピング

#### IF基本情報 → m_influencers

| 現行スプシ | 新DB | 備考 |
|-----------|------|------|
| マスター名 | influencer_name | |
| コンプラチェック | compliance_check | BOOLEAN |
| 区分 / 事務所個人 | affiliation_type_id | 1:事務所 / 2:フリーランス / 3:企業専属 |
| 所属 (正式名称) | affiliation_name | |
| 様/御中 | honorific | |
| メールアドレス | email_address | |

#### SNS → t_influencer_sns_accounts

| 現行スプシ | 新DB | 備考 |
|-----------|------|------|
| Instagram | account_url + platform_id=1 | |
| youtube | account_url + platform_id=2 | |
| twitter | account_url + platform_id=3 | |
| tiktok | account_url + platform_id=4 | |
| 任意 | account_url + platform_id=? | その他SNS |

#### 銀行口座 → t_bank_accounts

| 現行スプシ | 新DB | 備考 |
|-----------|------|------|
| 銀行名 | bank_name | |
| 支店 | branch_name | |
| 口座種別 | account_type | 普通/当座/貯蓄 |
| 口座番号 | account_number | 半角数字7桁 |
| 口座名義 | account_holder_name | 全角カタカナ |

#### 請求先 → t_billing_info

| 現行スプシ | 新DB | 備考 |
|-----------|------|------|
| 適格請求書番号 (T+13桁) | invoice_registration_number | |
| 請求先名 | billing_name | |
| 請求部署名 | billing_department | |

#### 住所 → t_addresses

| 現行スプシ | 新DB | 備考 |
|-----------|------|------|
| 郵便番号 | postal_code | |
| お届け先住所 | address_line1 | |
| お届け先名称 | recipient_name | |
| お届け先名称２ | recipient_name（2件目） | 2つ目の住所として登録 |
| お届け先電話番号 | phone_number | |

#### 担当・部署

| 現行スプシ | 新DB | 備考 |
|-----------|------|------|
| 担当者 | t_influencer_agent_assignments.agent_id | m_agentsと紐付け |
| 第一〜第五 | m_departments 参照 | 担当部署 |
| ジャンル | t_account_categories.category_id | m_categoriesと紐付け |

#### 除外した列

| 現行スプシ | 理由 |
|-----------|------|
| id | 新規自動採番（GENERATED ALWAYS AS IDENTITY） |
| エビデンス / 発注書 | ファイル管理（t_files）で将来対応 |
| ロボ番号 | 不要 |
| 請求部屋番号 | 不要 |

---

## 3. 新スプシテンプレート設計

### 基本方針

- **1シート・フラット構造**（運用担当がわかりやすいことを最優先）
- 色分けセクションで論理グループを視覚的に区別
- ドロップダウンで入力ブレを防止
- 変換スクリプトが裏でテーブルごとに振り分ける

### テンプレート列構成

```
🟦 基本情報          🟩 SNS            🟨 銀行口座        🟪 請求先・住所
┌───────────────┬──────────────┬──────────────┬─────────────────┐
│ A: 担当者      │ J: Instagram │ O: 銀行名    │ T: 適格請求書番号│
│ B: 担当部署    │ K: YouTube   │ P: 支店名    │ U: 請求先名     │
│ C: マスター名  │ L: Twitter/X │ Q: 口座種別  │ V: 請求部署名   │
│ D: コンプラ    │ M: TikTok    │ R: 口座番号  │ W: 郵便番号     │
│ E: 区分       │ N: その他SNS  │ S: 口座名義  │ X: 住所         │
│ F: 所属名     │              │              │ Y: 届け先名称   │
│ G: 様/御中    │              │              │ Z: 電話番号     │
│ H: メールアドレス│             │              │                │
│ I: ジャンル    │              │              │                │
└───────────────┴──────────────┴──────────────┴─────────────────┘
```

**合計26列**（A〜Z）

### 各列の詳細定義

#### 🟦 基本情報（A〜I列）

| 列 | 列名 | 入力方式 | バリデーション | DB先 |
|----|------|---------|-------------|------|
| A | 担当者 | ドロップダウン | m_agents一覧から選択 | t_influencer_agent_assignments |
| B | 担当部署 | ドロップダウン | 第一〜第五 | m_departments |
| C | マスター名 | 自由入力 | 必須。空白不可 | m_influencers.influencer_name |
| D | コンプラチェック | ドロップダウン | ○ / × | m_influencers.compliance_check |
| E | 区分 | ドロップダウン | 事務所所属 / フリーランス / 企業専属 | m_influencers.affiliation_type_id |
| F | 所属名(正式名称) | 自由入力 | 区分が「事務所」の場合は必須 | m_influencers.affiliation_name |
| G | 様/御中 | ドロップダウン | 様 / 御中 / さん | m_influencers.honorific |
| H | メールアドレス | 自由入力 | メール形式チェック | m_influencers.email_address |
| I | ジャンル | ドロップダウン | m_categories一覧から選択 | t_account_categories |

#### 🟩 SNS（J〜N列）

| 列 | 列名 | 入力方式 | バリデーション | DB先 |
|----|------|---------|-------------|------|
| J | Instagram | 自由入力 | URL形式 or アカウント名 | t_influencer_sns_accounts (platform=1) |
| K | YouTube | 自由入力 | URL形式 or チャンネル名 | t_influencer_sns_accounts (platform=2) |
| L | Twitter/X | 自由入力 | URL形式 or @ユーザー名 | t_influencer_sns_accounts (platform=3) |
| M | TikTok | 自由入力 | URL形式 or @ユーザー名 | t_influencer_sns_accounts (platform=4) |
| N | その他SNS | 自由入力 | 任意 | t_influencer_sns_accounts (platform=5) |

#### 🟨 銀行口座（O〜S列）

| 列 | 列名 | 入力方式 | バリデーション | DB先 |
|----|------|---------|-------------|------|
| O | 銀行名 | 自由入力 | 「銀行」不要 | t_bank_accounts.bank_name |
| P | 支店名 | 自由入力 | 「支店」不要。ゆうちょは漢数字3桁 | t_bank_accounts.branch_name |
| Q | 口座種別 | ドロップダウン | 普通 / 当座 / 貯蓄 | t_bank_accounts.account_type |
| R | 口座番号 | 自由入力 | 半角数字7桁 | t_bank_accounts.account_number |
| S | 口座名義 | 自由入力 | 全角カタカナ（小文字不可） | t_bank_accounts.account_holder_name |

#### 🟪 請求先・住所（T〜Z列）

| 列 | 列名 | 入力方式 | バリデーション | DB先 |
|----|------|---------|-------------|------|
| T | 適格請求書番号 | 自由入力 | T+13桁の形式チェック | t_billing_info.invoice_registration_number |
| U | 請求先名 | 自由入力 | 様/御中をつける | t_billing_info.billing_name |
| V | 請求部署名 | 自由入力 | 任意 | t_billing_info.billing_department |
| W | 郵便番号 | 自由入力 | XXX-XXXX形式 | t_addresses.postal_code |
| X | 住所 | 自由入力 | | t_addresses.address_line1 |
| Y | 届け先名称 | 自由入力 | | t_addresses.recipient_name |
| Z | 電話番号 | 自由入力 | 数字+ハイフン | t_addresses.phone_number |

### ドロップダウン値の対応表

```
【担当部署】（B列）
  第一 → department_id（m_departmentsから）
  第二 → 〃
  第三 → 〃
  第四 → 〃
  第五 → 〃

【区分】（E列）
  事務所所属 → affiliation_type_id = 1
  フリーランス → affiliation_type_id = 2
  企業専属 → affiliation_type_id = 3

【口座種別】（Q列）
  普通 → 1
  当座 → 2
  貯蓄 → 3
```

---

## 4. Google Sheets テンプレート作成手順

### Step 1: スプレッドシート作成

1. Google Sheets で新規スプレッドシートを作成
2. ファイル名: `【ANSEM】IFマスタ一括登録テンプレート`
3. シート名: `IF登録`

### Step 2: ヘッダー行の設定（1行目）

1. A1〜Z1 に列名を入力（上記テンプレート列構成の通り）
2. 1行目を **固定**（表示 → 行1まで固定）
3. 1行目を **太字 + 背景色** で視覚的に区別:
   - A〜I: 🟦 青系（#D0E0FF）— 基本情報
   - J〜N: 🟩 緑系（#D0FFD0）— SNS
   - O〜S: 🟨 黄系（#FFFFD0）— 銀行口座
   - T〜Z: 🟪 紫系（#E8D0FF）— 請求先・住所

### Step 3: ドロップダウン設定

1. **「選択肢」シートを追加**（非表示にする）
   - 担当者一覧（m_agentsの名前リスト）
   - 部署一覧（第一、第二、第三、第四、第五）
   - 区分（事務所所属、フリーランス、企業専属）
   - コンプラ（○、×）
   - 敬称（様、御中、さん）
   - 口座種別（普通、当座、貯蓄）
   - ジャンル一覧（m_categoriesの名前リスト）

2. **データの入力規則を設定**（各ドロップダウン列）
   - A列: データ → データの入力規則 → リスト（「選択肢」シートから）
   - B列: 同上
   - D, E, G, I, Q 列: 同上

### Step 4: 入力規則（バリデーション）

| 列 | ルール |
|----|-------|
| H（メール） | テキスト → 有効なメールアドレス |
| R（口座番号） | テキスト → カスタム数式 `=AND(LEN(R2)=7, ISNUMBER(VALUE(R2)))` |
| T（請求書番号） | テキスト → カスタム数式 `=REGEXMATCH(T2, "^T[0-9]{13}$")` |
| W（郵便番号） | テキスト → カスタム数式 `=REGEXMATCH(W2, "^[0-9]{3}-[0-9]{4}$")` |

### Step 5: 補助機能

1. **サンプルデータ行**（2行目）
   - 全列にサンプル値を入力し、薄いグレー背景に
   - 運用担当が入力イメージを掴みやすくする

2. **注意書きシート**を追加
   - 入力ルールの説明
   - ドロップダウンの意味
   - 「わからなかったら空欄でOK、後で確認します」の一言

3. **条件付き書式**
   - C列（マスター名）が空 → 赤背景（必須項目の強調）
   - H列がメール形式でない → 赤背景

### Step 6: 共有設定

1. 運用担当に「編集者」権限で共有
2. テンプレートは「コピーして使う」運用
   - 元テンプレートは編集不可（閲覧のみ）
   - 各担当者がコピーして自分のIFデータを入力

---

## 5. 変換スクリプトの流れ（Python）

```
CSV読み込み
    ↓
Step 1: 基本バリデーション
    - 必須列の空チェック（C: マスター名）
    - 形式チェック（メール、口座番号、郵便番号、請求書番号）
    - ドロップダウン値の妥当性チェック
    ↓
Step 2: ID変換
    - 担当者名 → agent_id（m_agents参照）
    - 部署名 → department_id（m_departments参照）
    - 区分名 → affiliation_type_id
    - ジャンル名 → category_id（m_categories参照）
    - ○/× → TRUE/FALSE
    ↓
Step 3: 重複チェック
    - マスター名の完全一致チェック（既存DB照合）
    - メールアドレスの重複チェック
    - SNS URLの重複チェック
    ↓
Step 4: テーブル振り分け
    - 1行のフラットデータを正規化して各テーブル用に分割
    - m_influencers / t_influencer_sns_accounts / t_bank_accounts /
      t_billing_info / t_addresses / t_influencer_agent_assignments /
      t_account_categories
    ↓
Step 5: 出力
    - DRY RUN: INSERT SQL をファイル出力（目視確認用）
    - 本番: DB直接INSERT（psycopg2等）
    - エラーレポート: バリデーションNG行の一覧をCSV出力
```

---

## 6. 重複防止アイデア

### 現状の問題

- 同一IFが複数レコードとして登録されている（会議で確認済み）
- 原因: 請求先変更、SNS違い、所属変更などで新規登録してしまう
- 完全自動統合は困難（グループYouTuber問題等）→ **手動削除方針**に決定済み

### アイデア一覧

#### A. DB層（既に実装済み）

| 対策 | 実装状況 | 効果 |
|------|---------|------|
| login_id UNIQUE制約 | ✅ 実装済み | 同一login_idの重複を完全防止 |
| is_primary 部分UNIQUE | ✅ 実装済み | メイン住所・口座の重複防止 |

#### B. インポート時バリデーション（変換スクリプトに組み込み）

| 対策 | 実装コスト | 効果 |
|------|-----------|------|
| **名前完全一致チェック** | 低 | 同名の既存IFがいたら警告 |
| **メールアドレス重複チェック** | 低 | 同一メールの既存IFがいたら警告 |
| **電話番号重複チェック** | 低 | 同一電話番号の既存IFがいたら警告 |
| **SNS URL重複チェック** | 中 | t_influencer_sns_accountsと照合 |
| **名前あいまい検索** | 中 | カナ揺れ・半角全角・スペース有無を正規化して比較 |
| **口座情報重複チェック** | 中 | 同一口座の既存IFがいたら警告（事務所所属者は除外） |

#### C. アプリ機能（管理画面に実装）

| 対策 | 実装コスト | 効果 |
|------|-----------|------|
| **登録前サジェスト** | 中 | 名前入力中に類似IFを表示 |
| **重複候補リスト画面** | 中 | 定期的に重複候補を一覧表示→管理者が確認 |
| **承認フロー** | 高 | 新規登録→管理者承認→本登録の2段階 |
| **マージUI** | 高 | 重複レコードを選択→統合先を選んで手動マージ |

#### D. 運用プロセス（ルールで防ぐ）

| 対策 | 実装コスト | 効果 |
|------|-----------|------|
| **登録前チェックシート** | なし | 「この人は既に登録済みですか？」の確認項目 |
| **週次重複チェックバッチ** | 低 | SQLで重複候補を抽出→Slack通知 |
| **命名規則の統一** | なし | 「田中 花子」の入力ルール（スペースの有無等） |

### おすすめの優先順位

```
【Phase 2（MVP）で実装】
  1. インポート時の名前・メール・電話番号重複チェック（B案）
  2. 週次重複チェックバッチ（D案）
  3. 登録前チェックシート（D案）

【Phase 3（本番）で実装】
  4. 登録前サジェスト（C案）
  5. 重複候補リスト画面（C案）
  6. マージUI（C案）← 最も工数大、後回し
```

---

## TODO

- [ ] Google Sheets テンプレート作成（Step 1-6 に沿って）
- [ ] 「選択肢」シートのマスタ値を確定（担当者一覧、ジャンル一覧）
- [ ] サンプルデータ作成（2行目）
- [ ] 変換スクリプト（Python）作成
- [ ] DRY RUNテスト
- [ ] 他テーブルの入力フォーマット定義
- [ ] 運用マニュアル作成

---

_作成: 2026-02-12_
_ステータス: ドラフト（チーム内レビュー待ち）_
