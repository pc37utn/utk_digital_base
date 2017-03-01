#!/bin/bash

echo "Installing Tesseract"

SHARED_DIR=$1

if [ -f "$SHARED_DIR/configs/variables" ]; then
  . "$SHARED_DIR"/configs/variables
fi

yum -y install tesseract tesseact-osd tesseract-langpack-fra
