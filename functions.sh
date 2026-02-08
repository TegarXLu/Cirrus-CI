#!/usr/bin/env bash

# ==============================
# Basic logging helpers
# ==============================

function log() {
  echo "[LOG] $*"
}

function _err() {
  echo "[ERROR] $*"
  exit 1
}

# ==============================
# Safe stub for send_file
# ==============================
# This prevents CI failure if send_file is not implemented.
# You can later replace this with a real uploader (GitHub / Cirrus artifacts).

function send_file() {
  local file="$1"
  local msg="$2"

  echo "[WARN] send_file is not implemented, skipping upload"
  echo "[WARN] File: $file"
  echo "[WARN] Message: $msg"
}

# ==============================
# Error handler used by CI
# ==============================

function err() {
  echo "[ERROR] $*"

  # Only try to send build.log if it exists
  if [ -f "$HOME/build.log" ]; then
    send_file "$HOME/build.log" "$*"
  else
    echo "[WARN] build.log not found, skipping send_file"
  fi

  exit 1
}
