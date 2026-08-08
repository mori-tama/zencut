# ZenCut（ゼンカット）

Builders Weekend - Shipaton Special Edition (2026-08-08, 渋谷) で1日で作ったPWA。

**サブスクを、物理で解約する。**
サブスクごとにビルが建ち、高さ＝月額×継続月数（払ってきた総額）。ビルを選んでスマホを振りかぶって叩きつけると大爆発。跡地と中央広場の「金の木」が、壊すたびに育っていく。

## デモ

https://setsuyaku-switch.pages.dev

iPhone Safariで開く → 「はじめる」→ モーション許可 → ビルをタップ → 叩きつける。
PCはビルをダブルクリックで爆破（開発用フォールバック）。

## 構成

- `pwa/index.html` — 本体（単一HTML・three.js同梱・依存ゼロ・ビルド不要）
- `pwa/motion-test.html` — 叩きつけ検出の実機検証シェル（閾値25 m/s²・実機検証済み）
- `concept/` — コンセプトアート（AI生成・実在ブランドなし）
- `PLAN-setsuyaku-switch.md` — 当日の計画書・ピッチ脚本

## ローカル実行

```
npx serve pwa
```

DeviceMotionはHTTPS必須のため、叩きつけはデプロイ先の実機でのみ動作。

## デプロイ

```
npx wrangler pages deploy pwa --project-name=setsuyaku-switch
```

## クレジット

効果音: [効果音ラボ](https://soundeffect-lab.info/)（利用規約に基づき作品の一部として同梱）
