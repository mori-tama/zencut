# ZenCut（旧称: 節約スイッチ） 本体実装スペック（PWA版・Sol委譲用）

アプリ表示名は **ZenCut**（`<title>`・Paywall見出し・manifest name すべてこれ。日本語サブコピーに「全カット」の掛詞を使ってよい）。

12:30のビルド開始でこのままSolに渡す。テストシェル（pwa/index.html）で実機検証済みの許可フロー・検出ロジックを流用する。

## なぜやるか
Builders Weekend当日ビルド。1分ピッチ脚本（PLAN-setsuyaku-switch.md）をそのまま実演できるPWAを16:00までに完成させる。

## 非目標
- 実課金・RevenueCat SDKは入れない（Paywallは演出。Shipaton応募時にExpo版へ移植）
- Service Workerは入れない（イテレーション中のキャッシュ事故防止。発表直前に検討）
- 横画面・Android対応は捨てる。iPhone Safari縦画面のみ
- ビルドステップ・フレームワーク・npm依存なし。素のHTML/CSS/JS

## 何を変えるか
| パス | 操作 | 内容 |
|---|---|---|
| `pwa/index.html` | 全面置換 | 本体アプリ（テストシェルは `pwa/test.html` に退避） |
| `pwa/assets/` | コピー | `app/assets/room/` 全15点 + `app/assets/se/` 全7点 |
| `pwa/manifest.json` | 新規 | standalone表示・ホーム追加用（アイコンはkakejiku流用可） |

## 画面フロー（3シーン・1ファイル内で切替）

### シーン1: Paywall（開幕）
- 見出し「ZenCut 本体 ¥1,000」・サブコピー「浪費、全カット。10回やる気を出せば実質無料」
- 大きな購入ボタン「¥1,000 支払って浪費を止める」。**このタップが唯一のユーザー操作起点**: DeviceMotion許可要求+音声解錠+太鼓SE(drum-japanese1)を全部ここで行う
- 購入演出（1秒程度のロード→チェックマーク）→シーン2へ。Appleの実シートを模倣しない（独自デザインのPaywall風）
- 許可deniedでも進める（隠し手動モードで完走可能にする）

### シーン2: 和室（メイン）
- `bg-washitsu.png` を全画面背景に、浪費オブジェ12点を配置（重なりすぎない散らし配置・各オブジェに「名前 ¥金額/月」の小さな値札）
- 上部に2つのカウンタ: **貯金箱（累計節約額/月）** と **残高（¥1,000スタート、1叩きごと-¥100）**
- 叩きつけ検出（テストシェルと同一: acceleration magnitude>閾値・既定25・不応期500ms）でヒット→ **決められた順序で** オブジェが1つ消える:
  - 消滅演出: オブジェが弾けて縮む/フェード+チャリンSE(money1/money-drop1交互)+金額が貯金箱へ飛ぶ数字演出+画面フラッシュ
  - 貯金箱カウンタはカウントアップアニメ（amount-display1）
- 12点の消える順序と金額（合計¥30,000ちょうど・脚本の「動画980円」が先頭・地味画像は序盤・ガチャをオチに）:
  1. sub-video 動画サブスク ¥980
  2. garake-hoken 謎の保険 ¥1,200
  3. gym 幽霊ジム ¥6,980
  4. sub-music 音楽サブスク ¥1,080
  5. manga-app 漫画アプリ ¥960
  6. coffee コンビニコーヒー ¥1,800
  7. conbini コンビニ間食 ¥2,400
  8. sake 晩酌 ¥2,600
  9. taxi 深夜タクシー ¥2,800
  10. delivery 出前 ¥3,600
  11. fuku 服の衝動買い ¥4,100
  12. gacha ガチャ ¥1,500
- 12点目を斬った瞬間: 貯金箱が¥30,000に到達→カウンタ跳ね+花火(CSS/canvasどちらでも軽い方)+levelup1→2秒後にシーン3へ

### シーン3: 禅の間（フィナーレ）
- 和室から浪費が全部消え、`kakejiku.png`（掛け軸「節約」）と `zabuton.png` だけが残る静かな画面+koto-glissando1
- 中央に「月¥30,000の節約が完了しました」・下に小さく「このアプリだけが、私が解約しない唯一のサブスクです」

## 隠し操作（ステージ保険・必須）
- **手動ヒット**: 画面のどこかを2本指同時タップ=ヒット1回（観客には見えない）
- **感度調整**: 左上角を3連続タップで設定パネル（閾値スライダー5〜40・現在magnitude/ピーク表示・リセットボタン）
- **リセット**: 設定パネル内。全オブジェ復活・カウンタ初期化・シーン1へ（リハ用）

## 技術メモ
- 許可フロー・検出・音声解錠はテストシェル `pwa/index.html`（退避後は test.html）の実装をそのまま流用
- 効果音の連打は `currentTime=0` 巻き戻しで対応済みパターンを流用
- `<meta name="apple-mobile-web-app-capable" content="yes">` 等を入れ、ホーム画面追加でフルスクリーン動作できるようにする
- 画像はすべて相対パス。プリロード（`new Image()` で先読み）してステージでのカクつきを防ぐ

## 受入基準と検証方法（Codex自身が実行する）
```bash
ls -la pwa/index.html pwa/test.html pwa/manifest.json
ls pwa/assets | wc -l    # 22（画像15+SE7）
grep -c "requestPermission" pwa/index.html   # 1以上
node -e "const html=require('fs').readFileSync('pwa/index.html','utf8');const m=[...html.matchAll(/<script>([\s\S]*?)<\/script>/g)];if(!m.length)throw new Error('no script');m.forEach(x=>new Function(x[1]));console.log('JS syntax OK')"
node -e "const html=require('fs').readFileSync('pwa/index.html','utf8');const prices=[980,1200,6980,1080,960,1800,2400,2600,2800,3600,4100,1500];for(const p of prices){if(!html.includes(String(p)))throw new Error('missing price '+p)};console.log('12 items OK, sum='+prices.reduce((a,b)=>a+b,0))"
```
すべてexit 0で合格（最後のsumは30000であること）。

## 判断が割れたときのデフォルト方針
迷ったら「16:00のステージで確実に動く方」。演出の豪華さよりデモ完走率。コードが短い方。

## リスク・既知の罠
- iOSの許可要求と音声解錠はユーザー操作ハンドラ内のみ（購入ボタンに集約済み）
- 効果音直リンはReferer必須の素材元だが、ローカル複製済みなので問題なし
- 花火演出が重いとmagnitude表示が跳ねる→requestAnimationFrameで軽く

Do not start any dev servers, watch processes, or background daemons.
完了後、変更した全ファイルの一覧と、検証コマンドの生の出力(実行したコマンド行・出力・exit code込み)をそのまま貼付して報告せよ。指定された検証コマンドを別のコマンドに差し替えることは禁止。
スペック外の判断が必要になったら、勝手に決めずに「未決事項」として報告末尾に列挙して完走せよ。
