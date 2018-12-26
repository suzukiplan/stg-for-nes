# [WIP] Simple STG for NES

NESのプログラミングを勉強するためシンプルなSTGを作ってみる。

<img src="screenshot.png" width="320"/>

## WIP status

- [x] スプライトで自機を表示
- [x] ジョイパッドのカーソルで自機を上下左右に移動
- [x] 画面レイアウト（ギャラガ風にする）
- [x] ジョイパッドのAボタンでショットを発射 (最大4連射)
- [x] 敵を登場させる (最大8匹)
- [x] 敵をショットで破壊できるようにする
- [x] 敵を破壊した時に爆発モーションを表示
- [x] 敵が弾を打てるようにする (最大8発)
- [x] 敵を破壊するとスコアを加算
- [x] メダル（ボーナスアイテム）を追加
- [x] メダルと自機が衝突するとメダル獲得
- [x] 敵機と自機が衝突するとゲームオーバー
- [x] ゲームオーバー後の表示（STARTボタンでリトライできるようにする）
- [x] 敵ショットと自機が衝突するとゲームオーバー
- [ ] メダルを利用したスコアリングの実装
  - メダル獲得ボーナス = 100点
  - メダル獲得で敵撃破時の基礎点を10点上げる
  - メダル獲得に失敗すると基礎点を10点下げる
  - 撃破得点: 初期値10点 〜 最大2550点
- [ ] ハイスコアの更新に対応
- [ ] 効果音を鳴らす
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

## TIPS

### ポエム

私が最初にプログラミングを覚えたのは、16bit機のPC-9801のN88日本語BASIC（以下、BASIC）でした。
当時、電波新聞社のマイコンBASICマガジン（ベーマガ）に掲載されているゲームプログラムを打ち込んで遊び、言語仕様を理解したら自分でゲームを作って遊んでました。BASICはシンプルなので、ベーマガの誌面を見ながらプログラムを打ち込んでいくだけでプログラミングのやり方を理解できます。
しかし、ベーマガの誌面には時々、理解不能な数値の羅列（ダンプリスト）だけ掲載しているオールマシン語のゲームが掲載されていて、それはBASICでは到底実現不可能なレベルの動きを実現していました。

マシン語を理解してゲームを作れることは、BASIC全盛のあの頃であれば大きなアドバンテージでした。
現在では単なる過去の遺物でしかないかもしれません。
ただし、Swift、Kotlin、Phytonといった最新の高級言語であっても最終的にはマシン語に変換されてコンピュータ上で動きます。
なので、高級言語でプログラミングする場合であっても、マシン語を全く理解せずに組むよりもマシン語を理解した上で組んだ方が良いかもしれません。
つまり、実用面では使い所がないものの知識としては必要なことかもしれません。

私は中学生の頃、PC-9801のTurbo Assemblerでマシン語プログラミングの基礎を身につけたのですが、実際のところかなり苦労しました。マシン語を身につければ魔法が掛かったようなすごいゲームが簡単に作れるという幻想を抱いていたのですが、全然そんなことはありません。むしろ、拡張メモリなどが使えて処理性能も良いPC-98であれば、C言語で作ってもオールマシン語とそんなに遜色がないレベルのプログラムを作ることができます。
当時は知る由もなかったのですが、16bitのマシン語は結構難しいので、当時の私の環境がPC-98（16bit）ではなくPC-88（8bit）ならもっと簡単にマスターできた筈です。
現代のプログラマが自分のPC（恐らく64bit CPU）でマシン語を勉強すると、異次元のレベルで（16bitよりも遥かに）難しいと思われます。

マシン語を勉強するには8bit CPUで動くプログラムを書くことが一番楽なので、最も普及した8bitコンピュータではないかと考えられる任天堂のファミリーコンピュータを題材として、マシン語ゲームプログラミングの解説をしようと思い、このリポジトリを公開してみることにしました。

以下、ファミコンゲームプログラミングの技術情報を書いていきますが、ファミコンの場合、既に解析し尽くされていて、基礎的な技術情報であればWeb上に溢れているので、各々ググって調べれば良いかと思います。ここでは、（私が調べた限り）Webでは得られなかったもっと実戦寄りの知見を書いていこうと思います。

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

### 複数オブジェクトの構造体は4byteが望ましい

自機のショット、敵機、敵弾などの複数登場するオブジェクトは 4byteの構造体 で定義するのが望ましい。4byteにすることで __同じインデックス・レジスタ(X/Y)を使ってスプライトDMAにもアクセスできる__ ので処理効率が良くなる。

高性能なCPUを使ったプログラミングに慣れていると「たった4byteとか何もできないじゃん」と思われるかもしれないが、8bitのCPUならそれで割と何とかなる。

具体的には, 全ての構造体は以下のようなデータ構成になるのではないかと思われる。

- 生存フラグ（兼種別判定）で1byte
- 座標で2byte
- 汎用変数で1byte

### サブルーチンの使い所

サブルーチンの呼び出しによる処理分岐は、ロジックを構造化して見やすくできる反面メチャクチャ重い。
具体的にはJSR(呼び出し)で6サイクル、RTS(復帰)で6サイクルなので合計12サイクルも使ってしまう。

ファミコンのCPU (RP2A03) の性能は1.7MHzなので、1秒に約170万サイクル実行できる。
1フレーム（1/60秒）では約28333サイクル実行できる。
この中でメインループの全ての処理を実行しなければならないので、たった12サイクルされど12サイクルである。

なので、サブルーチン呼び出しで処理を構造化しようとするとイタイ目を見る。
もちろん、実装をキレイに構造化しないと後から手を入れるのが困難なスパゲッティプログラムになってしまうので、それはそれで困りモノであるが。処理速度的に問題ない内はキレイに構造化しておき、性能が足りなくなったら構造化を崩しながら最適化に努めるという手も無くはない。

なお、そんな「なるべく使わない方が良いサブルーチン」だが、ブランチ命令は最大でも255バイト先までしかジャンプできないので、その問題に引っかかる場合には使わざるを得ない。インデックスを複数回す２重ループとかを実装すると、外側のループがブランチで飛べなくなるので内側のループ処理をサブルーチン化する必用が出てくる。[stg.asm](stg.asm)では、敵キャラと自機ショットの当たり判定をするため、敵キャラの移動ループ内で自機ショットとの当たり判定処理（sub_moveEnemy_hitCheck）をサブルーチンとして呼び出すようにしている。

> 余談だが、6502にはindexレジスタがxとyの２つあるが、ゲームを作る上では2つのindexがあることがかなり便利だと当たり判定のロジックを組んでみて実感できた。

## 性能限界との付き合い方

このサンプルゲームの場合, 自機と敵ショットの当たり判定を入れた [このcommit](https://github.com/suzukiplan/stg-for-nes/commit/5e0a6c376607ee9166ea8eac3521c52a657a8ef6) でついにファミコンの性能限界を超えて処理落ちが発生するようになった。そこで、以下2点の修正を入れて何とか限界回避することにした。

- 敵ショットの上限数を16→8に下方修正 ([commit](https://github.com/suzukiplan/stg-for-nes/commit/d9af0c70d0d22e6c33ae81e8ad64bbc77b284cdd))
- 変数を全部ゼロページに移す ([commit](https://github.com/suzukiplan/stg-for-nes/commit/674129675178007bb47db20e1a9249801315b95a))

幸い、ゲームの仕様上敵ショットを半減させても鬼畜難度を保てるので、敵ショットを半減させた。16じゃなくて10とかで良いかもしれないが、オブジェクト数を原則2のn乗にしたかったので8にした（※コレについては別トピックで後述するが実用的な理由は特に無い) 。

変数についても、全部の変数の総サイズを計算してみたところ余裕をもって全部ゼロページに収まるので、全部ゼロページに移した。（ゼロページに移すことでload/storeに要するサイクルを1サイクル削ることができる）

> ゼロページはWRAMの $0000〜$00FF の範囲で、この範囲内なら他（$0100〜$1FFF）と比べてフェッチ数を1削ってアクセスできるのでアクセス性能が良い反面、最大256バイトしか使えないので無闇に使うことができない。（全変数のサイズ合計が256バイト以下であれば無闇に使っても良い）

## オブジェクト数は2のn乗にすべきか？

このゲームでは、自機ショット、敵ショット、敵機などの複数オブジェクトの上限数を全て2のn乗にしているが、これには実のところ実用的な理由はない。

例えば2のn乗ではない場合、レジスタに余裕があれば以下のようにindexを使って回すことができ、この時はそもそも2のn乗にする必要はない。

```
    ldx #$05 ; x = 5
loop:
    (loop procedure)
    dex      ; x--
    bne loop ; branch if x != 0
```

ただし、レジスタに余裕が無い状況では、ループを回すのに一つのレジスタを潰すのが惜しいケースがままある。その場合、レジスタにループフラグと構造体の要素添字を兼用させることで、ループ専用にレジスタを潰さなくても良くなる。

サイズ4 & 要素数16 の構造体であれば以下のように実装できる。

```
    ldx #$00 ; x = 0
loop:
    (loop procedure)
    txa      ; a = x
    clc      ; キャリーをクリア
    adc #$04 ; a = a + 4
    tax      ; x = a
    and #$3f ; a = a and $3f (%00111111)
    bne loop ; branch if x != 0
```

オブジェクト数（と構造体サイズ）が2のn乗であれば, `オブジェクト数（×構造体サイズ）- 1` で論理積（AND）することで、上限値を超えた時に0に戻るので `bne` でループ継続判定ができる。

これが仮にオブジェクト数の上限が10だとすると以下のようになる。

```
    ldx #$00 ; x = 0
loop:
    (loop procedure)
    txa      ; a = x
    clc      ; キャリーをクリア
    adc #$04 ; a = a + 4
    tax      ; x = a
    cmp #$28 ;
    bcc loop ; branch if x < 40 ($28 = 4 * 10)
```

上記2つのコードの違いは `and -> cmp` + `bne -> bcc` しかない。
そして、and、cmp、bne、bccは全て(and+cmpは即値計算なら) 2サイクルの命令なので、どちらの処理も性能面での違いは無い。（なんとなく、cmpよりもandの方が早そうな気もするが）

メリットとしてはandの方が実装的には見やすい（キャリーよりゼロフラグでのブランチが見やすい）ぐらいのものではないだろうか。

なので、この部分はお好みで実装すれば良いというのが私見。

> このトピックのタイトルはどちらかというと、「1つのレジスタでループ判定とオブジェクト要素の添字を兼用させるテクニック」だったかもしれない。

## License

[GPLv3](LICENSE.txt)

