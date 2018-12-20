# [WIP] Simple STG for NES

NESのプログラミングを勉強するためシンプルなSTGを作ってみる。

<img src="screenshot.png" width="320"/>

## WIP status

- [x] スプライトで自機を表示
- [x] ジョイパッドのカーソルで自機を左右に移動
- [ ] 画面レイアウト（ギャラガ風にする）
- [x] ジョイパッドのAボタンでショットを発射 (最大4連射)
- [ ] 敵機を登場させる
- [ ] 敵機をショットで破壊できるようにする
- [ ] スコアを表示
- [ ] 敵機と自機が衝突するとゲームオーバー
- [ ] 背景に星を表示して縦スクロールさせる
- [ ] 残機

## Prerequest
- GNU make
- [cc65](https://cc65.github.io/) 
- [bmp2chr](https://github.com/suzukiplan/bmp2chr)

## How to build

```
make
```

## Usage of WRAM area

### ZERO page

```
$00: プレイヤのX座標
$01: プレイヤのY座標
$02: ショットのindex (0, 4, 8, 12, 0...)
$03: ショットの発射禁止フラグ (0なら発射許可)
$04〜$07: ショット構造体 (f: 発射中, x: 座標, y: 座標, i: 未使用)
$08〜$0b: ショット構造体 (f: 発射中, x: 座標, y: 座標, i: 未使用)
$0c〜$0f: ショット構造体 (f: 発射中, x: 座標, y: 座標, i: 未使用)
$10〜$13: ショット構造体 (f: 発射中, x: 座標, y: 座標, i: 未使用)
```

> ショット構造体は0ページではなく別のWRAMに移すかも

### Sprite (DMA: $0300〜$03FF)

```
$0300: sp_player1: プレイヤの左上
$0304: sp_player2: プレイヤの右上
$0308: sp_player3: プレイヤの左下
$030c: sp_player4: プレイヤの右下
```

## License

[GPLv3](LICENSE.txt)

