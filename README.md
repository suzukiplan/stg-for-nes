# [WIP] Simple STG for NES

NESのプログラミングを勉強するためシンプルなSTGを作ってみる。

<img src="screenshot.png" width="320"/>

## WIP status

- [x] スプライトで自機を表示
- [x] ジョイパッドのカーソルで自機を左右に移動
- [ ] 画面レイアウト（ギャラガ風にする）
- [ ] ジョイパッドのA/Bボタンでショットを発射
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
```

### Sprite (DMA: $0300〜$03FF)

```
+$0000: sp_player1: プレイヤの左上
+$0004: sp_player2: プレイヤの右上
+$0008: sp_player3: プレイヤの左下
+$000c: sp_player4: プレイヤの右下
```

## License

[GPLv3](LICENSE.txt)

