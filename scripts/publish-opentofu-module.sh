#!/usr/bin/env zsh

set -euo pipefail

SCRIPT_NAME=$(basename "$0")

usage() {
  cat <<EOF
${SCRIPT_NAME} - Package an OpenTofu module and publish to Docker Hub (OCI) using ORAS

Required tools:
  - oras (brew install oras)
  - zip

Usage:
  ${SCRIPT_NAME} -u <username> -m <module_path> -r <repo> -v <version> [-p <password>] [--keep-zip]

Arguments:
  -u, --username       Docker Hub username
  -p, --password       Docker Hub password or token (optional; will prompt if omitted)
  -m, --module-path    Path to the OpenTofu module directory to package
  -r, --repo           Docker Hub repo (e.g., myuser/tofu-network or docker.io/myuser/tofu-network)
  -v, --version        Tag/version to publish (e.g., 1.0.0)
      --keep-zip       Keep the generated ZIP file (for debugging)
  -h, --help           Show this help and exit

Notes:
  - This script logs in to Docker Hub via ORAS and pushes an artifact with
    artifactType application/vnd.opentofu.modulepkg and layer mediaType archive/zip.
  - ZIP excludes: *.git*, */.terraform/*, ../module-package.zip, tests tests/* */tests */tests/*
  - The registry host is used exactly as provided in -r. For Docker Hub, use either
    myuser/repo (defaults host to docker.io) or docker.io/myuser/repo. To target
    registry-1.docker.io explicitly, pass -r registry-1.docker.io/myuser/repo.
EOF
}

# Defaults
DOCKER_USERNAME=""
PASSWORD=""
MODULE_PATH=""
REPO_INPUT=""
VERSION_TAG=""
KEEP_ZIP="false"

# Simple argument parsing for zsh/posix style
while [[ $# -gt 0 ]]; do
  case "$1" in
    -u|--username)
      DOCKER_USERNAME="$2"; shift 2 ;;
    -p|--password)
      PASSWORD="$2"; shift 2 ;;
    -m|--module-path)
      MODULE_PATH="$2"; shift 2 ;;
    -r|--repo)
      REPO_INPUT="$2"; shift 2 ;;
    -v|--version)
      VERSION_TAG="$2"; shift 2 ;;
    --keep-zip)
      KEEP_ZIP="true"; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1 ;;
  esac
done

require() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: '$1' is required but not found in PATH" >&2
    exit 1
  fi
}

require oras
require zip

if [[ -z "$DOCKER_USERNAME" || -z "$MODULE_PATH" || -z "$REPO_INPUT" || -z "$VERSION_TAG" ]]; then
  echo "Error: Missing required arguments." >&2
  usage
  exit 1
fi

# Normalize module path and validate
MODULE_PATH=$(cd "$MODULE_PATH" 2>/dev/null && pwd)
if [[ -z "$MODULE_PATH" || ! -d "$MODULE_PATH" ]]; then
  echo "Error: module path is not a directory" >&2
  exit 1
fi

# Normalize repo to include docker.io if host not provided
if [[ "$REPO_INPUT" == */*/* ]]; then
  FULL_REPO="$REPO_INPUT"
else
  # assume docker hub default host
  FULL_REPO="docker.io/${REPO_INPUT}"
fi

# Extract registry host from FULL_REPO (first path segment)
# Use the host exactly as provided (no automatic rewrite to registry-1.docker.io).
# If you need to target registry-1.docker.io explicitly, pass it in the repo value.
REGISTRY_HOST=${FULL_REPO%%/*}
LOGIN_HOST="$REGISTRY_HOST"

# Basic validation for Docker Hub namespace/repo
REPO_PATH=${FULL_REPO#*/}
if [[ -z "$REPO_PATH" || "$REPO_PATH" != */* ]]; then
  echo "Error: repo should include a namespace and name (e.g., myuser/myrepo)" >&2
  exit 1
fi

# Prepare temp directory for zip
TMPDIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'opentofu-oci')
cleanup() {
  if [[ "$KEEP_ZIP" != "true" ]]; then
    rm -rf "$TMPDIR" || true
  fi
}
trap cleanup EXIT

ZIP_OUT="$TMPDIR/module-package.zip"

echo "Packaging module from: $MODULE_PATH"
(
  cd "$MODULE_PATH"
  # Create zip one directory outside of module to avoid self-inclusion
  zip -r "$ZIP_OUT" . \
    -x "*.git*" \
    -x "*/.terraform/*" \
    -x "../module-package.zip" \
  -x "tests" \
  -x "tests/*" \
  -x "*/tests" \
  -x "*/tests/*"
)

if [[ ! -s "$ZIP_OUT" ]]; then
  echo "Error: ZIP was not created or is empty: $ZIP_OUT" >&2
  exit 1
fi

echo "ZIP created: $ZIP_OUT"

# Prompt for password/token if not provided
if [[ -z "$PASSWORD" ]]; then
  echo -n "Docker Hub password or token for $DOCKER_USERNAME: "
  read -s PASSWORD
  echo
fi

echo "Logging in to registry: $LOGIN_HOST for user $DOCKER_USERNAME"
oras login "$LOGIN_HOST" -u "$DOCKER_USERNAME" -p "$PASSWORD" >/dev/null
echo "Login succeeded."

TARGET_REF="${FULL_REPO}:${VERSION_TAG}"
echo "Pushing OpenTofu module to: $TARGET_REF"

# Push with required artifactType and layer mediaType
(
  # Use relative path for the layer to avoid absolute-path validation errors from ORAS
  cd "$TMPDIR"
  oras push \
    --artifact-type application/vnd.opentofu.modulepkg \
    "$TARGET_REF" \
    "$(basename "$ZIP_OUT"):archive/zip"
)

echo "Push complete: $TARGET_REF"

if [[ "$KEEP_ZIP" == "true" ]]; then
  echo "Kept ZIP at: $ZIP_OUT"
else
  echo "Temporary ZIP removed."
fi
