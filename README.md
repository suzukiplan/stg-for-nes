# Cosmic Shooter

NESのプログラミングを勉強するためシンプルなSTGを作ってみたものです。

|タイトル|ゲーム画面|
|---|---|
|![title](screenshot1.png)|![game](screenshot2.png)|

## How to play

- [stg.nes](stg.nes)をダウンロードしてエミュレータでプレイしてください
- Mapper0のカートリッジに焼けば恐らく実機でも動く筈です（未確認）
- [RPGアツマール（ブラウザ）](https://game.nicovideo.jp/atsumaru/games/gm9628)でもプレイできます

### Story

地球がエイリアンの植民地になってから四半世紀が経った20xx年、人類は秘密裏に開発した対エイリアン駆逐船で最後の戦闘に臨もうとしていた。エイリアンは無限に増殖してくるのでこの戦いに勝利は存在しない。エイリアンに個の感情らしきものは存在しない。統率された意識の元で、ただ破壊と資源の略奪をおこなっている。彼等の目的は一体何なのだろうか。そして、人類に未来はあるのか。約束された敗北への最後の戦いが今始まる。

### Rules

- カーソルで自機を上下左右に移動してAボタンでショットを撃てます
- ショットで敵機を破壊してください
- 敵機を破壊するとボーナスアイテムが出てきます
- ボーナスアイテムを取得すると獲得得点が上がり、落とすと獲得得点が落ちます（0以下にはなりません）
- 自機が敵機か敵ショットに衝突するとゲームオーバーです

## How to build

### Pre-requests

以下のツールが必要です。

- GNU make
- [cc65](https://cc65.github.io/)
- [bmp2chr](https://github.com/suzukiplan/bmp2chr)
- ファミコンエミュレータ

### Build command

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

### 性能限界との付き合い方

このサンプルゲームの場合, 自機と敵ショットの当たり判定を入れた [このcommit](https://github.com/suzukiplan/stg-for-nes/commit/5e0a6c376607ee9166ea8eac3521c52a657a8ef6) でついにファミコンの性能限界を超えて処理落ちが発生するようになった。そこで、以下2点の修正を入れて何とか限界回避することにした。

- 敵ショットの上限数を16→8に下方修正 ([commit](https://github.com/suzukiplan/stg-for-nes/commit/d9af0c70d0d22e6c33ae81e8ad64bbc77b284cdd))
- 変数を全部ゼロページに移す ([commit](https://github.com/suzukiplan/stg-for-nes/commit/674129675178007bb47db20e1a9249801315b95a))

幸い、ゲームの仕様上敵ショットを半減させても鬼畜難度を保てるので、敵ショットを半減させた。16じゃなくて10とかで良いかもしれないが、オブジェクト数を原則2のn乗にしたかったので8にした（※コレについては別トピックで後述するが実用的な理由は特に無い) 。

変数についても、全部の変数の総サイズを計算してみたところ余裕をもって全部ゼロページに収まるので、全部ゼロページに移した。（ゼロページに移すことでload/storeに要するサイクルを1サイクル削ることができる）

> ゼロページはWRAMの $0000〜$00FF の範囲で、この範囲内なら他（$0100〜$1FFF）と比べてフェッチ数を1削ってアクセスできるのでアクセス性能が良い反面、最大256バイトしか使えないので無闇に使うことができない。（全変数のサイズ合計が256バイト以下であれば無闇に使っても良い）

### オブジェクト数は2のn乗にすべきか？

このゲームでは、自機ショット、敵ショット、敵機などの複数オブジェクトの上限数を全て2のn乗にしているが、これには実のところ実用的な理由はない。

例えば2のn乗ではない場合、レジスタに余裕があれば以下のようにindexを使って回すことができ、この時はそもそも2のn乗にする必要はない。

```
    ldx #$05 ; x = 5
loop:
    (loop procedure)
    dex      ; x--
    bne loop ; branch if x != 0
```

ただし、レジスタに余裕が無い状況では、ループを回すのに一つのレジスタを潰すのが惜しいケースがままある。その場合、レジスタにループフラグと構造体の要素添字を兼用させることでレジスタを節約できる。

サイズ4 & 要素数16 の構造体であれば以下のように実装できる。

```
    ldx #$00 ; x = 0
loop:
    (loop procedure)
    txa      ; a = x
    clc      ; キャリーをクリア
    adc #$04 ; a = a + 4
    and #$3f ; a = a and $3f (%00111111)
    tax      ; x = a
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
    bcc loop ; branch if a < 40 ($28 = 4 * 10)
```

上記2つのコードの違いは `and -> cmp` + `bne -> bcc` しかない。
そして、and、cmp、bne、bccは全て(and+cmpは即値計算なら) 2サイクルの命令なので、どちらの処理も性能面での違いは無い。（なんとなく、cmpよりもandの方が早そうな気もするが）

andを用いるメリットとしては、

- andの方が実装的には見やすい（キャリーよりゼロフラグでのブランチが見やすい）
- ループ後にレジスタがリセット状態（0）になる（ループ後にクリアが必要なケースでは命令数を節約できる）

ぐらいのものではないだろうか。
なので、この部分はお好みで実装すれば良いレベルというのが私見。

> このトピックのタイトルはどちらかというと、「1つのレジスタでループ判定とオブジェクト要素の添字を兼用させるテクニック」だったかもしれない。

### 当たり判定（衝突判定）

四角形のオブジェクト同士の当たり判定は、例えば `16x16のオブジェクトa` (座標: v_ax, v_ay) と `8x8のオブジェクトb` (座標変数: v_bx, v_by) であれば以下の4つの計算式が全て true なら衝突したと見做すことができます。

- checkX1: aの右端 > bの左端
- checkX2: aの左端 < bの右端
- checkY1: aの下端 > bの上端
- checkY2: aの上端 < bの下端

C言語であれば以下のように計算してあげれば良いです。

```c
if (v_ax + 16 >= v_bx &&    // checkX1 (比較演算は > で良いですがコードをわかりやすくするため >= にします)
    v_ax < v_bx + 8 &&      // checkX2
    v_ay + 16 >= v_by &&    // checkY1 (比較演算は < で良いですがコードをわかりやすくするため <= にします)
    v_ay < v_by + 8) {      // checkY2
    // 衝突した時の処理
}
```

> C言語で変数名のプレフィクスに `v_` なんて付けることはないと思いますが、マシン語だとレジスタ等と混同してしまうのを避けるため、変数名だと分かるようにプレフィクスを付与するコーディングルールとした方が良いです。

これを単純に6502で書くと、以下のようになります。

```assembly
checkX1:
    lda v_ax    ; レジスタa = v_ax
    clc
    adc #16     ; レジスタaに16を加算
    cmp v_bx
    bcc not_hit ; レジスタa(v_ax+16) < v_bx なら衝突しなかったと判定

checkX2:
    lda v_bx    ; レジスタa = v_bx
    clc
    adc #8      ; レジスタaに8を加算
    cmp v_ax
    bcc not_hit ; レジスタa(v_bx+8) < v_ax なら衝突しなかったと判定

checkY1:
    lda v_ay    ; レジスタa = v_ay
    clc
    adc #16     ; レジスタaに16を加算
    cmp v_by
    bcc not_hit ; レジスタa(v_ay+16) < v_by なら衝突しなかったと判定

checkY2:
    lda v_by    ; レジスタa = v_by
    clc
    adc #8      ; レジスタaに8を加算
    cmp v_ay
    bcc not_hit ; レジスタa(v_by+8) < v_ay なら衝突しなかったと判定
```

ただし、上記の当たり判定が画面全体（256x240）で発生する場合、桁あふれ（オーバーフロー）発生に注意しなければなりません。具体的には、サイズ16のオブジェクトaが画面右端240pxにある状態で判定すると、以下のように意図しない判定がされてしまいます。

```assembly
checkX1:
    lda v_ax    ; レジスタa = v_ax (240)
    clc
    adc #16     ; レジスタaに16を加算 → 240 + 16 = 0 (8bitなので)
    cmp v_bx
    bcc not_hit ; 0 < v_bx なら衝突しなかったと判定 (意図しない判定)
```

そこで、以下にv_axが240以上でも正常に判定できる実装例を示します。

```assembly
checkX1:
    lda v_ax    ; レジスタa = v_ax
    cmp #240
    bcs x1ov16  ; v_axが240以上ならx1ov16へ分岐して別の方法でチェック
    clc
    adc #16     ; レジスタaに16を加算
    cmp v_bx
    bcc not_hit ; レジスタa(v_ax+16) < v_bx なら衝突しなかったと判定

checkX2:
    lda v_bx    ; レジスタa = v_bx
    clc
    adc #8      ; レジスタaに8を加算
    cmp v_ax
    bcc not_hit ; レジスタa(v_bx+8) < v_ax なら衝突しなかったと判定
    bcs checkY1 ; x1ov16 を実行しないようにブランチ

x1ov16:
    lda v_bx
    cmp #232
    bcc not_hit ; v_bxが232未満なら衝突しなかったと判定

checkY1:
```

最初にv_axが240以上かチェックして、240以上であれば `x1ov16` という別の判定ロジックにブランチして、そこでv_bxが232（240-8）未満かどうかチェックします。これによりオーバーフローを回避しつつ判定できるようになりました。

ただ、当たり判定はたった1回で上述のようにかなり沢山の命令を実行する必要があり、更に複数オブジェクトを対象に実行する場合、処理の実行数が指数的に増加してしまいます。なので、上記のように厳密なチェックをすべきかはケースバイケースかと思います。

### ファミコンのAPU

ファミコンのCPU（RP2A03）にはオンチップで 矩形波2ch、三角波1ch、ノイズ1ch、DPCM 1ch のAY-3-8910を拡張したと思しき音源を実装していて、そこから数々の名曲が生まれました。私も結構チップチューン音楽が好きです。チップチューン好きが高じて自作のチップチューン音源（VGS）を作り、東方Projectの音楽をVGS用にダウングレード・アレンジして作った楽曲を配信するアプリ（東方BGM on VGS）を以前作っていたぐらいです。

自作のファミコンゲームで音楽を再生するには音源ドライバを実装する必要があって、それは結構敷居が高いのですが、今なら [pently](https://github.com/pinobatch/pently) という素晴らしいライブラリがZLIBライセンスで公開されているので、それを使えば割と簡単に音楽付きのゲームを作ることができます。

しかし、今回の習作では、RP2A03の音源機能を音楽ではなく効果音に全振りしてみることにしました。（習作だからなるべく外部プログラムを前提にしたくなかった事に加え、ドライバも自作するとなるとそれだけで結構大作になってしまい、ファミコンゲームの作り方の勉強用には向かない気がしたという実用的な理由もあります）

RP2A03標準音源は貧弱だと言われていますが、こと「効果音再生音源」と見做した時のRP2A03は割とゴージャスです。同時に4種類の効果音を再生できるのです。また、効果音を再生するのに必要な操作はloadとstoreを4回（つまり4byteのI/Oポート転送を）実行するだけなので、処理負荷への影響も軽微で済みます。

効果音の実装例は、[このcommit](https://github.com/suzukiplan/stg-for-nes/commit/f5e4911d53fb8e764350037bd0c19885143516c7)を見れば分かるようにしておきました。
習作らしく、矩形波2ch、三角波1ch、ノイズ1chの全てを使っていますが、DPCMは残念ながら使ってません。 _(DPCMで「デストロイ・ゼム・オール!!」と鳴らしたかったけど断念)_

### 花の命より短いvBlank期間

ブラウン管テレビは走査線が1秒間に60回の周期（60Hz）で上から下に流れて画面を描画してます。ファミコンのグラフィックは、縦240pxが走査線の流れに従ってテレビに表示されますが、1回の更新周期時に16px分の画面を更新しない周期があり、それをvBlankと呼んでいます。

ファミコンのグラフィックの書き換え処理はそのvBlank期間に行わなければなりません。

> vBlank期間外に更新を行うことで意図的に描画を乱れさせる表現手法も存在します。たぶん、ドラゴンクエストの旅の扉とかがその手法を使っているはず。

このvBlank期間というのがとにかく短い。

スプライトに関しては、DMA転送を使うので240pxを更新中にメモリ更新を済ませるだけで良いのですが、問題になってくるのはBGです。この習作では、背景の星の表示、スコア表示、メダル表示、ゲームオーバー表示の更新をvBlank期間に全て行いたいのですが、全部を同時に行うことはvBlankの期間内ではやや無理があります。（そして、なるべく更新処理を早く切り上げてゲームのメイン処理に割けるCPUリソースを確保したい）

そこで、

- 背景の星を描画（4フレームにつき1回だけ行っている）した時はその他の描画をskip
- スコア表示を更新した時はその他の描画をskip
- メダル表示を更新した時はその他の描画をskip

といった形で描画処理のskipを行うことにしました。
skipされたその他の更新処理は、変数を上手く使って次回のvBlank期間でも出来るようにしておく必要があります。

### アイディアの凝固点

ファミコンと最新のゲーム機の最大の違いは、アイディアを形にするまでのコストです。

ファミコンだとアイディアの全てを形にしようとすると、想像しているよりもずっと早くハードリミットの壁にぶつかります。今回の習作でも割と早い段階で限界が見えてきました。ファミコンだと全てのアイディアを形にすることは出来ないので、出来る範囲で何ができるかを考える「アイディアのやり繰り」みたいなことをする必要があります。

ゲームを作ろうとすると有象無象なアイディアが生まれてくるかと思いますが、ハードリミットがほぼ無い現代のコンピュータならお金と時間さえ掛ければその全てを実現できてしまう一方、ファミコンだとアイディアのやり繰りの過程でよりプリミティブなものを優先していかなければなりません。

最新のゲーム機だと有象無象なものが出来てしまうリスクが高いので、恐らく最新のゲーム開発の現場ではアイディアを煮詰めるために延々と会議を繰り返しているのではないかと想像できます。私は会議が嫌いなので想像するだけで食傷気味になってしまうのですが、アイディアとは凝固点が物凄く高い液体みたいなものだからきっとそれは必要経費なのだろうと思います。

ハードリミットが低いことはデメリットでしかないと思われがちで、消費者視点では実際その通りなのですが、クリエイター視点ではアイディアの凝固点を下げてくれるというかなり大きなメリットがあるといえます。

### ファミコンというゲームエンジンについて

ニコニコ動画などでゲームの縛りプレイ動画が結構人気がありますが、ファミコンでのゲーム開発はゲーム開発における縛りプレイといえるかもしれません。しかし、触ってみると思っていたよりもゲームを作る上で必要十分な機能が全て揃っていて、それでも縛りプレイであることには違いないですが雁字搦めという程のものでもないです。

むしろ、1983年の時点で既にその域に達していた事に驚きます。私は1990年代にファミコンの10倍以上の性能を持つPC-98でゲームプログラミングをしていたのですが、アクションゲームの開発用途としてはファミコンの方がずっと上だったと断言できます。 _何よりPC-98にはスプライトが無いので。_

> _スプライトの事を差し引いても、ゲーム開発のし易さという点ではPC-8801mkIISRとかの方が上だったかも。ただし、後継機であるPC-88VA（16bit）はスプライトを入れたものの無残な結果に終わりましたが（x68kが強すぎた）。次世代機（16bit）の前の段階（8bit）の時点で、88にファミコン相当のスプライト搭載していたら世界は大分違ったかもしれない。98全盛時代でも8bitの88が価格優位性+主にゲームを作りたい人達向けに沢山売れ続け、結果的に98よりも88の方が長く生き残り続けたかもしれません。_

ファミコンはパソコンと違いゲームに特化したコンピュータです。だから、ゲームという限定条件下なら10年近い世代差があるビジネスコンピュータとも張り合えたのだと思います。現代のコンピュータで例えるなら「Unityで作ったしたアプリしか動かないコンピュータ」みたいなものと考えるとわかり易いかもしれません。
Unityの場合、ゲームを作るために必要な機能をソフトウェアのレベルで抽出してゲーム開発者へ提供していますが、ファミコンは単にそれがハードウェアになっただけです。性能は著しく悪いですが。

## あとがき

習作していく内に気づいたTIPSを書き溜めて公開しようと思っていたのですが、思いの外ご紹介できるネタが少なく、後半は主に精神論になってしまったかもしれません。やはり、ゲーム開発は文書を読んで学ぶものではなく、実際に作ってみることが一番かと思います。私は[コチラのサイト](http://hp.vector.co.jp/authors/VA042397/nes/index.html)でファミコン上でHELLO WORLDを表示するプログラムをダウンロードして、それを[cc65](https://cc65.github.io/)でアセンブルして動かすことから始め、表示位置を変えてみたり、色を変えてみたり、スクロールしてみたり、スプライトを表示してみたり、スプライトをジョイパッドで動かしてみたり、Aボタンでスプライトからショットを撃てるようにしてみたり...という風に改造を重ねた結果、このゲームが完成しました。ある程度の完成像は描いていましたが基本行き当たりばったりで作りました。もしもファミコンのゲームを作ってみたくてこのリポジトリに辿り着いた方が居れば、必要十分な環境は既に整っているので、まずはこのゲームのあまりにも鬼畜な難度を何とかするように改造してアセンブルして動かしてみるといったところから始めてみると良いかもしれません。

最後にこの習作のソースコードの読む上で参考になりそうな情報を書いておきます。

- [src/stg.asm](https://github.com/suzukiplan/stg-for-nes/blob/master/src/stg.asm)
  - 最初はこのソースから作り始めたのですが、途中から長いソースを改修するのが大変になったので幾つかのファイルに分離して [include](https://github.com/suzukiplan/stg-for-nes/blob/ff0370ebe3d90056a3d43d4a8bc69e660c8d1e2e/src/stg.asm#L38-L49) して読み込むようにしました
  - 最終的にこのソースは以下のブロックだけが残しました
    - [iNESヘッダの定義](https://github.com/suzukiplan/stg-for-nes/blob/ff0370ebe3d90056a3d43d4a8bc69e660c8d1e2e/src/stg.asm#L5-L12)
    - [スタートアップ処理](https://github.com/suzukiplan/stg-for-nes/blob/ff0370ebe3d90056a3d43d4a8bc69e660c8d1e2e/src/stg.asm#L14-L36)
    - [定数定義](https://github.com/suzukiplan/stg-for-nes/blob/ff0370ebe3d90056a3d43d4a8bc69e660c8d1e2e/src/stg.asm#L53-L116)
      - 8bitコンピュータのメモリは64KBありますが、ファミコンのメモリマップは大雑把に分けると、前半32KB($0000〜$7FFF)がRAMやI/Oポート、後半32KB($8000〜$FFFF)がコードという具合になっています。
      - このゲームのコードサイズはマシン語に変換すると4KBほどありますが、その全部がプログラムという訳ではなく後半領域に文字列やパレットといった固定値のデータを突っ込んでいます。
    - [変数ラベル](https://github.com/suzukiplan/stg-for-nes/blob/ff0370ebe3d90056a3d43d4a8bc69e660c8d1e2e/src/stg.asm#L118-L247)
      - 64KBのメモリの内、プログラム内で書き換え可能な値（変数）をアドレスの何番地に割り当てるか定義しています
      - C言語などのプログラムで言うところのグローバル変数みたいなものです（つまり、全部の変数をグローバル変数で管理しています）
      - 変数として使える領域は決まって `$0000〜$00FF` (0ページ) と `$0200〜$07FF` (2〜7ページ) までの合計 $0700 バイト（1792バイト）です（MAPPER0の場合）
      - このゲームの場合、0ページを一般変数用、3ページをスプライトDMA転送用に使っていて残り5ページは未使用だから、まだまだ戦えます
      - `$0100〜$01FF` の範囲はスタック領域で、PHA/PLAなどでレジスタの値を一時的に保持するためのものです（C言語でプログラムを作る場合たった256バイトだと何もでないレベルかもしれませんが、オールマシン語で組む場合は256バイトも割と持て余すので、領域が足りなくなったら後半128バイトを潰すのもアリかも）
    - [CHARSセグメントへのバイナリ読み込み](https://github.com/suzukiplan/stg-for-nes/blob/ff0370ebe3d90056a3d43d4a8bc69e660c8d1e2e/src/stg.asm#L255-L257)
      - スプライトのパターンデータ（CHRファイル）をCHARSセグメントに読み込むようにしています
      - RPGやアクションゲームのマップなどのタイルパターンもこの `.incbin` というプリプロセッサで読み込んであげれば良さそうです
- [src/stg-00title.asm](https://github.com/suzukiplan/stg-for-nes/blob/ff0370ebe3d90056a3d43d4a8bc69e660c8d1e2e/src/stg-00title.asm)
  - タイトル画面です（一番最後の方で作りました）
- [src/stg-01setup.asm](https://github.com/suzukiplan/stg-for-nes/blob/ff0370ebe3d90056a3d43d4a8bc69e660c8d1e2e/src/stg-01setup.asm)
  - タイトルのループを抜けた後に実行されるゲームの初期化処理です
  - BGの描画や各種変数の初期化を行っています
  - WRAMの領域は初期化しないと不定値が入っていてバグるのでWRAM領域を0クリアする処理を入れた方が良かったかも（実際、0クリア漏れで結構バグったような）
- [src/stg-02mainloop.asm](https://github.com/suzukiplan/stg-for-nes/blob/ff0370ebe3d90056a3d43d4a8bc69e660c8d1e2e/src/stg-02mainloop.asm)
  - ゲームのメインループ処理です
  - このソースの頭から末尾までの処理が1秒間に60回実行されています
  - 特に重要なのがvBlankの同期をしている[このロジック](https://github.com/suzukiplan/stg-for-nes/blob/ff0370ebe3d90056a3d43d4a8bc69e660c8d1e2e/src/stg-02mainloop.asm#L339-L341)です
    - `lda $2002` でPPUの状態を読み込み negative flag がクリアされている間は只管 `lda $2002` を繰り返しています
    - これによりこのループが抜けた時 = vBlankが発生中となります（その間にグラフィックの更新処理ができます）
    - スプライトに関しては[3ページの内容をDMA転送するように指示している](https://github.com/suzukiplan/stg-for-nes/blob/ff0370ebe3d90056a3d43d4a8bc69e660c8d1e2e/src/stg-02mainloop.asm#L342-L343)だけで、これ以降のロジックは全てBGの更新処理です
- その他ソース: サブルーチンです（全てメインループから追いかけることができます）

## License

- 一般向け: [GPLv3](LICENSE.txt)
- カスタムライセンスを希望される場合emailにて個別にご連絡ください
