#!/usr/bin/env bash
set -euo pipefail

base_dir=$(dirname "$(realpath "$0")")

table_orig=http://www.unicode.org/Public/MAPPINGS/OBSOLETE/EASTASIA/JIS/JIS0208.TXT
font_json=assets/minecraft/font/include/unifont.json
extra_table=extra-jis0208.tsv

table=jis0208.tsv

# $1: フォントサイズ(幅), $2: フォントサイズ(WxH)
_build() {
    local font_width=$1
    local font_size=$2
    local source_dir=$base_dir/src/$font_width
    local build_dir=$base_dir/build/$font_width
    local font_texture_dir=$build_dir/assets/minecraft/textures/font
    local font
    font=$(printf "mplus_bitmap_fonts-2.2.4/fonts_j/mplus_j%dr.bdf" "$font_width")
    local font_atlas
    font_atlas=$(printf "%s/mplus_j%dr.png" "$font_texture_dir" "$font_width")
    local output_name
    output_name=$(printf "Minecraft Mplus Bitmap Font %s.zip" "$font_size")
    # 前回生成結果を削除
    rm -f "$base_dir/$output_name"
    # ソースディレクトリからコピー
    mkdir -p "$build_dir" "$font_texture_dir"
    cp -ar "$source_dir/"* "$build_dir"
    # JIS X 0208 -> Unicode変換テーブルを変形
    # col1: JIS X 0208, col2: Unicode
    curl -fsSL "$table_orig" | sed '/^#/d' | cut -f2,3 | cat - <(sed '/^#/d' "$extra_table") >"$table"
    # BDFをPNGに変換
    bdftoimg "$font" "$font_atlas"
    # BDFから収録文字一覧を作成
    mcfontcharsfrombdf "$table" "$font" "$source_dir/$font_json" "$build_dir/$font_json"
    # リソースパック作成
    pushd "$build_dir"
    zip -r "$base_dir/$output_name" ./*
    popd
}

_build 10 "10x11"
_build 12 "12x13"
