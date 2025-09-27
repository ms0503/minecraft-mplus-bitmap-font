# Minecraft Mplus Bitmap Font

このリソースパックはMinecraftのフォントをMplus Bitmap Fontに置き換えるものです。

## 対応バージョン

動作確認は1.20.1で行っています。それ以外のバージョンは未検証です。\
少なくとも同じパックフォーマット(15)の1.20は動くと思います。

## 導入方法

- [幅10dot]
- [幅12dot]

ベースのフォントサイズに応じたリソースパックをダウンロードして来ます。

このファイルをプロファイル内の`resourcepacks`ディレクトリに移動させれば完了です。\
例えば、デフォルトのままであれば`%appdata%\.minecraft\resourcepacks`(Windows)・`~/.minecraft/resourcepacks`(Linux・Mac)の中に入れます。

## ビルド方法

ビルドには`nix-command`と`flakes`の`experimental-features`が有効化されたNixが必要です。

リポジトリルートで以下のコマンドを叩くと生成されます。

```shell
nix develop -c ./build.sh
```

## ライセンス

リソースパック・ビルドツールは[MITライセンス]で配布します。\
ただし、同梱するM<sup>+</sup> BITMAP FONTSは[M<sup>+</sup> FONTS License]が適用されます。

[m<sup>+</sup> fonts license]: LICENSE-Mplus_J
[mitライセンス]: LICENSE.md
[幅10dot]: https://github.com/ms0503/minecraft-mplus-bitmap-font/raw/HEAD/Minecraft%20Mplus%20Bitmap%20Font%2010x11.zip
[幅12dot]: https://github.com/ms0503/minecraft-mplus-bitmap-font/raw/HEAD/Minecraft%20Mplus%20Bitmap%20Font%2012x13.zip
