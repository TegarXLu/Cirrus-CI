#!/usr/bin/env bash

# Logging functions
function _err() {
  echo "[ERROR] $*"
  exit 1
}

function err() {
  echo "[ERROR] $*"
  send_file "$HOME/build.log" "$*"
  exit 1
}

function log() {
  echo "[LOG] $*"
}
