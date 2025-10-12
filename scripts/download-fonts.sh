#!/bin/bash

# Download Roboto fonts for Czech character support in PDF generation

FONTS_DIR="src/main/resources/fonts"
mkdir -p "$FONTS_DIR"

echo "Downloading Roboto fonts..."

# Download Roboto Regular
curl -L "https://github.com/google/fonts/raw/main/apache/roboto/Roboto-Regular.ttf" \
  -o "$FONTS_DIR/Roboto-Regular.ttf"

# Download Roboto Bold
curl -L "https://github.com/google/fonts/raw/main/apache/roboto/Roboto-Bold.ttf" \
  -o "$FONTS_DIR/Roboto-Bold.ttf"

# Download Roboto Italic
curl -L "https://github.com/google/fonts/raw/main/apache/roboto/Roboto-Italic.ttf" \
  -o "$FONTS_DIR/Roboto-Italic.ttf"

# Download Roboto Medium (for semi-bold)
curl -L "https://github.com/google/fonts/raw/main/apache/roboto/Roboto-Medium.ttf" \
  -o "$FONTS_DIR/Roboto-Medium.ttf"

echo "Fonts downloaded successfully!"
echo "Files created in $FONTS_DIR:"
ls -lh "$FONTS_DIR"

