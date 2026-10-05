#!/bin/bash

DIR="$1"
TYPE="$2"
OUTDIR="$DIR/_compressed"

if [ -z "$DIR" ] || [ -z "$TYPE" ]; then
  echo "Usage: shrink.sh /path/to/folder jpg|png|mp4|pdf|all"
  exit 1
fi

if [ ! -d "$DIR" ]; then
  echo "Error: folder not found"
  exit 1
fi

mkdir -p "$OUTDIR"

case "$TYPE" in

  jpg|jpeg)
    find "$DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -exec bash -c '
      OUTDIR="$1"
      shift
      for file; do
        jpegoptim --max=70 --dest="$OUTDIR" "$file"
      done
    ' bash "$OUTDIR" {} +
    ;;

  png)
    find "$DIR" -type f -iname "*.png" -exec bash -c '
      OUTDIR="$1"
      shift
      for file; do
        pngquant --force --output "$OUTDIR/$(basename "$file")" "$file"
      done
    ' bash "$OUTDIR" {} +
    ;;

  mp4)
    find "$DIR" -type f -iname "*.mp4" -exec bash -c '
      OUTDIR="$1"
      shift
      for file; do
        base=$(basename "${file%.*}")
        ffmpeg -i "$file" -vcodec libx264 -crf 28 "$OUTDIR/${base}_small.mp4"
      done
    ' bash "$OUTDIR" {} +
    ;;

  pdf)
    find "$DIR" -type f -iname "*.pdf" -exec bash -c '
      OUTDIR="$1"
      shift
      for file; do
        base=$(basename "${file%.*}")
        out="$OUTDIR/${base}_small.pdf"

        gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
        -dPDFSETTINGS=/ebook \
        -dNOPAUSE -dQUIET -dBATCH \
        -sOutputFile="$out" "$file"
      done
    ' bash "$OUTDIR" {} +
    ;;

  all)
    find "$DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -exec bash -c '
      OUTDIR="$1"
      shift
      for file; do
        jpegoptim --max=70 --dest="$OUTDIR" "$file"
      done
    ' bash "$OUTDIR" {} +

    find "$DIR" -type f -iname "*.png" -exec bash -c '
      OUTDIR="$1"
      shift
      for file; do
        pngquant --force --output "$OUTDIR/$(basename "$file")" "$file"
      done
    ' bash "$OUTDIR" {} +

    find "$DIR" -type f -iname "*.mp4" -exec bash -c '
      OUTDIR="$1"
      shift
      for file; do
        base=$(basename "${file%.*}")
        ffmpeg -i "$file" -vcodec libx264 -crf 28 "$OUTDIR/${base}_small.mp4"
      done
    ' bash "$OUTDIR" {} +

    find "$DIR" -type f -iname "*.pdf" -exec bash -c '
      OUTDIR="$1"
      shift
      for file; do
        base=$(basename "${file%.*}")
        out="$OUTDIR/${base}_small.pdf"

        gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
        -dPDFSETTINGS=/ebook \
        -dNOPAUSE -dQUIET -dBATCH \
        -sOutputFile="$out" "$file"
      done
    ' bash "$OUTDIR" {} +
    ;;

  *)
    echo "Supported types: jpg | png | mp4 | pdf | all"
    exit 1
    ;;
esac
