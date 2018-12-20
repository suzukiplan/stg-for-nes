# [WIP] Simple STG for NES

NESのプログラミングを勉強するためシンプルなSTGを作ってみる。

<img src="screenshot.png" width="320"/>

## WIP status

- [x] スプライトで自機を表示
- [x] ジョイパッドのカーソルで自機を左右に移動
- [x] 画面レイアウト（ギャラガ風にする）
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

### TAXとTXAを間違えない覚え方

TAX と TXA を単純に「タックス（※税金ではない）」「タクサ」みたいな読みで最初覚えていたのだが、この覚え方には問題がある。

これらの命令はAレジスタとXレジスタの代入命令なのだが、どっち方向なのかを混同しがちである。（何処とは言わないが、逆で解説しているウェブサイトがあったりしたので余計に混乱してしまった^^;）

以下のように覚えると間違えなくなったので良い感じである。

```
TAX; Transfer A to X (AをXに代入)
TXA; Transfer X to A (XをAに代入)
```

> `from` ではなく `to` であると覚えればまず間違えない。
> ニーモニックも `A2X` や `X2A` なら間違えなかった訳だが、ニーモニックをアルファベット縛りにしているのって何か理由があるのだろうか?

### カラーコード

いちいちYY-CHRで確認していたが面倒なのでここに載せておく。

<table>
<tr>
<td style="border:0px;background-color:#6D6D6D;width:32px;height:32px;color:#fff;text-align:center">0x00</td><td style="border:0px;background-color:#002491;width:32px;height:32px;color:#fff;text-align:center">0x01</td><td style="border:0px;background-color:#0000DA;width:32px;height:32px;color:#fff;text-align:center">0x02</td><td style="border:0px;background-color:#6D48DA;width:32px;height:32px;color:#fff;text-align:center">0x03</td><td style="border:0px;background-color:#91006D;width:32px;height:32px;color:#fff;text-align:center">0x04</td><td style="border:0px;background-color:#B6006D;width:32px;height:32px;color:#fff;text-align:center">0x05</td><td style="border:0px;background-color:#B62400;width:32px;height:32px;color:#fff;text-align:center">0x06</td><td style="border:0px;background-color:#914800;width:32px;height:32px;color:#fff;text-align:center">0x07</td><td style="border:0px;background-color:#6D4800;width:32px;height:32px;color:#fff;text-align:center">0x08</td><td style="border:0px;background-color:#244800;width:32px;height:32px;color:#fff;text-align:center">0x09</td><td style="border:0px;background-color:#006D24;width:32px;height:32px;color:#fff;text-align:center">0x0A</td><td style="border:0px;background-color:#009100;width:32px;height:32px;color:#fff;text-align:center">0x0B</td><td style="border:0px;background-color:#004848;width:32px;height:32px;color:#fff;text-align:center">0x0C</td><td style="border:0px;background-color:#000000;width:32px;height:32px;color:#fff;text-align:center">0x0D</td><td style="border:0px;background-color:#000000;width:32px;height:32px;color:#fff;text-align:center">0x0E</td><td style="border:0px;background-color:#000000;width:32px;height:32px;color:#fff;text-align:center">0x0F</td></tr><tr><td style="border:0px;background-color:#B6B6B6;width:32px;height:32px;color:#fff;text-align:center">0x10</td><td style="border:0px;background-color:#006DDA;width:32px;height:32px;color:#fff;text-align:center">0x11</td><td style="border:0px;background-color:#0048FF;width:32px;height:32px;color:#fff;text-align:center">0x12</td><td style="border:0px;background-color:#9100FF;width:32px;height:32px;color:#fff;text-align:center">0x13</td><td style="border:0px;background-color:#B600FF;width:32px;height:32px;color:#fff;text-align:center">0x14</td><td style="border:0px;background-color:#FF0091;width:32px;height:32px;color:#fff;text-align:center">0x15</td><td style="border:0px;background-color:#FF0000;width:32px;height:32px;color:#fff;text-align:center">0x16</td><td style="border:0px;background-color:#DA6D00;width:32px;height:32px;color:#fff;text-align:center">0x17</td><td style="border:0px;background-color:#916D00;width:32px;height:32px;color:#fff;text-align:center">0x18</td><td style="border:0px;background-color:#249100;width:32px;height:32px;color:#fff;text-align:center">0x19</td><td style="border:0px;background-color:#009100;width:32px;height:32px;color:#fff;text-align:center">0x1A</td><td style="border:0px;background-color:#00B66D;width:32px;height:32px;color:#fff;text-align:center">0x1B</td><td style="border:0px;background-color:#009191;width:32px;height:32px;color:#fff;text-align:center">0x1C</td><td style="border:0px;background-color:#000000;width:32px;height:32px;color:#fff;text-align:center">0x1D</td><td style="border:0px;background-color:#000000;width:32px;height:32px;color:#fff;text-align:center">0x1E</td><td style="border:0px;background-color:#000000;width:32px;height:32px;color:#fff;text-align:center">0x1F</td></tr><tr><td style="border:0px;background-color:#FFFFFF;width:32px;height:32px;color:#000;text-align:center">0x20</td><td style="border:0px;background-color:#6DB6FF;width:32px;height:32px;color:#000;text-align:center">0x21</td><td style="border:0px;background-color:#9191FF;width:32px;height:32px;color:#000;text-align:center">0x22</td><td style="border:0px;background-color:#DA6DFF;width:32px;height:32px;color:#000;text-align:center">0x23</td><td style="border:0px;background-color:#FF00FF;width:32px;height:32px;color:#000;text-align:center">0x24</td><td style="border:0px;background-color:#FF6DFF;width:32px;height:32px;color:#000;text-align:center">0x25</td><td style="border:0px;background-color:#FF9100;width:32px;height:32px;color:#000;text-align:center">0x26</td><td style="border:0px;background-color:#FFB600;width:32px;height:32px;color:#000;text-align:center">0x27</td><td style="border:0px;background-color:#DADA00;width:32px;height:32px;color:#000;text-align:center">0x28</td><td style="border:0px;background-color:#6DDA00;width:32px;height:32px;color:#000;text-align:center">0x29</td><td style="border:0px;background-color:#00FF00;width:32px;height:32px;color:#000;text-align:center">0x2A</td><td style="border:0px;background-color:#48FFDA;width:32px;height:32px;color:#000;text-align:center">0x2B</td><td style="border:0px;background-color:#00FFFF;width:32px;height:32px;color:#000;text-align:center">0x2C</td><td style="border:0px;background-color:#000000;width:32px;height:32px;color:#f00;text-align:center">0x2D</td><td style="border:0px;background-color:#000000;width:32px;height:32px;color:#fff;text-align:center">0x2E</td><td style="border:0px;background-color:#000000;width:32px;height:32px;color:#fff;text-align:center">0x2F</td></tr><tr><td style="border:0px;background-color:#FFFFFF;width:32px;height:32px;color:#000;text-align:center">0x30</td><td style="border:0px;background-color:#B6DAFF;width:32px;height:32px;color:#000;text-align:center">0x31</td><td style="border:0px;background-color:#DAB6FF;width:32px;height:32px;color:#000;text-align:center">0x32</td><td style="border:0px;background-color:#FFB6FF;width:32px;height:32px;color:#000;text-align:center">0x33</td><td style="border:0px;background-color:#FF91FF;width:32px;height:32px;color:#000;text-align:center">0x34</td><td style="border:0px;background-color:#FFB6B6;width:32px;height:32px;color:#000;text-align:center">0x35</td><td style="border:0px;background-color:#FFDA91;width:32px;height:32px;color:#000;text-align:center">0x36</td><td style="border:0px;background-color:#FFFF48;width:32px;height:32px;color:#000;text-align:center">0x37</td><td style="border:0px;background-color:#FFFF6D;width:32px;height:32px;color:#000;text-align:center">0x38</td><td style="border:0px;background-color:#B6FF48;width:32px;height:32px;color:#000;text-align:center">0x39</td><td style="border:0px;background-color:#91FF6D;width:32px;height:32px;color:#000;text-align:center">0x3A</td><td style="border:0px;background-color:#48FFDA;width:32px;height:32px;color:#000;text-align:center">0x3B</td><td style="border:0px;background-color:#91DAFF;width:32px;height:32px;color:#000;text-align:center">0x3C</td><td style="border:0px;background-color:#000000;width:32px;height:32px;color:#f00;text-align:center">0x3D</td><td style="border:0px;background-color:#000000;width:32px;height:32px;color:#fff;text-align:center">0x3E</td><td style="border:0px;background-color:#000000;width:32px;height:32px;color:#fff;text-align:center">0x3F</td></tr></table>

## License

[GPLv3](LICENSE.txt)

