#!/usr/bin/env bash

set -eo pipefail
exec > >(tee "$HOME/build.log") 2>&1

# ==============================
# Load helper functions
# ==============================
source functions.sh

# Trap any error
trap 'err "Failed to execute command: $BASH_COMMAND"' ERR

# ==============================
# Workspace
# ==============================
mkdir -p workspace
cd workspace

# ==============================
# Install dependencies
# ==============================
log "Installing build dependencies..."
curl -LSs https://raw.githubusercontent.com/akhilnarang/scripts/master/setup/android_build_env.sh | bash -

# ==============================
# Sync OrangeFox manifest
# ==============================
log "Syncing OrangeFox manifest..."
git config --global user.name "bintang774"
git config --global user.email "108184157+bintang774@users.noreply.github.com"

git clone --depth=1 "$FOX_SYNC" sync
cd sync
./orangefox_sync.sh \
  --branch "$FOX_BRANCH" \
  --path "$(realpath ../fox_${FOX_BRANCH})"
cd ..

# ==============================
# Clone device tree
# ==============================
cd "fox_${FOX_BRANCH}"

log "Cloning device tree..."
git clone --depth=1 -q "$DT_REPO" -b "$DT_BRANCH" "$DT_PATH"

# ==============================
# Build OrangeFox
# ==============================
log "Building OrangeFox..."
source build/envsetup.sh || true
export ALLOW_MISSING_DEPENDENCIES=true

lunch "${DEVICE_MAKEFILE}-eng"

mka adbd "${BUILD_TARGET}image" -j"$(nproc --all)"

# ==============================
# Output files
# ==============================
OUT_PATH="out/target/product/$DEVICE_NAME"

OUTPUT_FILES=$(ls "$OUT_PATH"/OrangeFox*.img 2>/dev/null || true)

if [ -z "$OUTPUT_FILES" ]; then
  err "No OrangeFox image generated!"
fi

# ==============================
# GitHub Release
# ==============================
log "Creating GitHub release..."

export GITHUB_TOKEN="$GH_TOKEN"

DATE=$(TZ="$TIMEZONE" date +"%Y%m%d-%H%M")
RELEASE_TAG="Fox-${DEVICE_NAME}-${DATE}"
RELEASE_NAME="OrangeFox ${DEVICE_NAME} ${DATE}"

gh release create "$RELEASE_TAG" \
  $OUTPUT_FILES \
  --title "$RELEASE_NAME" \
  -R "$RELEASE_REPO" || \
log "GitHub release skipped or already exists"

log "Build & release completed successfully 🎉"
exit 0
