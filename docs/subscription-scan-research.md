# Gmail連携サブスクスキャン 実現性・コスト調査（2026-08-08）

節約スイッチに「Googleアカウント連携でGmailからサブスク課金メールを検出する」機能を入れる場合の調査結果。

## 結論サマリ

| 段階 | 可否 | コスト |
|---|---|---|
| デモ（ハッカソン） | 今すぐ可能（テストモード） | 0円 |
| 小規模公開（100人まで） | テストユーザー手動登録で可能 | 0円 |
| 一般公開 | OAuth検証+CASA Tier 2必須 | 約$540〜1,000 + 審査4〜12週間 |

## 1. 必要スコープと分類

Gmail関連スコープは**すべて restricted scope**（sensitiveより厳格な区分）。
本文を読まない `gmail.metadata`（ヘッダー・ラベルのみ）でも restricted 扱いで、検証プロセスは回避できない。

- 出典: [Restricted Scopes一覧](https://support.google.com/cloud/answer/13464325?hl=en) / [Restricted scope verification](https://developers.google.com/identity/protocols/oauth2/production-readiness/restricted-scope-verification)

## 2. OAuthアプリ検証（一般公開時）

- プライバシーポリシー（アプリと同一ドメイン、Limited Use準拠明記、同意画面にリンク）
- OAuth同意フロー全体のデモ動画
- スコープごとの正当化説明
- Google審査自体は無料、通常2〜4週間（不備で時計リセット）

## 3. CASA（セキュリティ審査）

restricted scopeでサーバー側にデータを保存・送信する場合は必須。

- Tier 2 セルフサーブ（承認ラボの自動スキャン）: **$540〜1,000** が相場（ラボにより$3,000超もあり）
- 初回申請から承認まで合計 **4〜12週間以上**
- クライアントサイドのみで処理・即破棄ならCASA免除の可能性あり（**免除条件の厳密な範囲は未検証**）
- 出典: [DeepStrike CASA解説](https://deepstrike.io/blog/google-casa-security-assessment-2025) / [Truto CASA Tier 2体験記](https://truto.one/blog/our-google-oauth-app-is-live-and-casa-tier-2-certified/)

## 4. 検証なし（テストモード）の制限

- テストユーザー上限**100人**（事前にメールアドレス登録・上限は恒久でリセット不可）
- 「このアプリは確認されていません」警告画面が出る
- 外部ユーザータイプ+テスト中は**リフレッシュトークンが7日で失効**（当日デモなら影響なし）
- 出典: [Manage App Audience](https://support.google.com/cloud/answer/15549945?hl=en)

## 5. 代替手段

- **(a) Google Pay/Playの定期購入一覧API**: 外部アプリから読むAPIは存在しないと見られる（自社アプリ課金管理用APIのみ）
- **(b) メール転送方式**: 専用アドレスに領収書メールを転送してもらいパース（SendGrid Inbound Parse / Cloudflare Email Workers）。審査不要だがユーザーの手間が増える
- **(c) 明細アグリゲータ**: Moneytree LINK（国内2,370機関対応）はBtoB契約前提の可能性が高く個人セルフサーブ未確認。Plaidは日本非対応。銀行APIは電子決済等代行業登録の論点あり（未深掘り）
- **(d) スクショ/CSVアップロード+AI解析**: 審査・契約一切不要で最も低コスト。自動性は下がる

## 6. Gmail API 料金・クォータ

- 利用無料。1日10億クォータ単位（一覧取得5ユニット/回）
- 2026-05-01以降の新規プロジェクトは新クォータ体系。超過課金は2026年内開始予定（8月時点で未開始と見られる）
- 出典: [Usage limits](https://developers.google.com/workspace/gmail/api/reference/quota)

## 推奨方針

1. デモ〜披露: Gmail連携をテストモードで実装（0円）
2. 需要確認後の公開版: CSV/スクショ+AI解析を主軸に先行リリース
3. Gmail自動スキャンは検証+CASA（約10万円+1〜3ヶ月）を払う価値が確認できてから

## 未検証事項

- クライアントサイド処理のみの場合のCASA免除条件の厳密な範囲
- Moneytree LINKの個人開発者向けプランの有無と料金
- 日本の銀行API利用に伴う電子決済等代行業登録の要否
