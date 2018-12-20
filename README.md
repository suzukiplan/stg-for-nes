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

## TIPS

### 加算命令（ADDではなくADC）

6502の加算命令はADDではなくADC（ADD WITH CARRY）である点を注意する必用がある。

例えば, 

```assembler
    ADC #$10
```

の演算結果は `A = A + #$10(16)` ではなく `A = A + #$10(16) + C` である。

キャリー `C` は, 直前の演算結果でキャリーが立った場合は `1` で立たなかった場合は `0` になる。

```assembler
    LDX #$FF
    INX
    ; この場合, C は 1 になる
```

```assembler
    LDX #$00
    INX
    ; この場合, C は 0 になる
```

キャリーの結果に関係なく単純に加算したい場合 `CLC` 命令 (Clear Carry) を実行して予めキャリーをリセットしなければならない。（そして、6502にはキャリーを使わずに加算する命令は無い）

```assembler
    ADC #$10 ; この場合 a には 16 or 17 が加算される
    CLC
    ADC #$10 ; この場合 a には 16 が加算される
```

> 当初、ADCが単純な加算と勘違いして、計算結果が期待値と違うバグが多発して苦労させられた。（[このcommit](https://github.com/suzukiplan/stg-for-nes/commit/c6750eacc10574ab230a7290cef34441d4fdeef7) でADCの前にCLCを実行する修正を入れいているのはその為である...）

## License

[GPLv3](LICENSE.txt)

