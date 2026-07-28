#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/build-package.sh VERSION ARCHIVE [OUTPUT_DIR]

Build an Arch Linux neovim-bin package from Neovim's official
nvim-linux-x86_64.tar.gz release archive.

  VERSION     Upstream version, with or without a leading "v"
  ARCHIVE     Path to nvim-linux-x86_64.tar.gz
  OUTPUT_DIR  Package output directory (default: dist)
EOF
}

if (( $# < 2 || $# > 3 )); then
  usage >&2
  exit 2
fi

if [[ ${EUID} -eq 0 ]]; then
  echo 'error: makepkg must be run as an unprivileged user' >&2
  exit 1
fi

command -v makepkg >/dev/null || {
  echo 'error: makepkg was not found; install the base-devel group' >&2
  exit 1
}

version=${1#v}
archive=$(realpath "$2")
output_dir=$(realpath -m "${3:-dist}")
repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)

[[ $version =~ ^[0-9]+([.][0-9]+)*([._+-][0-9A-Za-z]+)*$ ]] || {
  echo "error: invalid package version: $version" >&2
  exit 1
}
[[ -f $archive ]] || {
  echo "error: archive does not exist: $archive" >&2
  exit 1
}
tar -tzf "$archive" 'nvim-linux-x86_64/bin/nvim' >/dev/null || {
  echo 'error: archive does not have the expected Neovim layout' >&2
  exit 1
}

work_dir=$(mktemp -d)
trap 'rm -rf -- "$work_dir"' EXIT
sha256=$(sha256sum "$archive" | awk '{print $1}')

sed \
  -e "s/@PKGVER@/${version}/g" \
  -e "s/@SHA256@/${sha256}/g" \
  "$repo_root/packaging/PKGBUILD.in" >"$work_dir/PKGBUILD"
cp -- "$archive" "$work_dir/nvim-linux-x86_64.tar.gz"

mkdir -p -- "$output_dir"
(
  cd "$work_dir"
  PKGDEST="$output_dir" makepkg --clean --cleanbuild --force --noconfirm
)

printf 'Built package(s):\n'
find "$output_dir" -maxdepth 1 -type f -name 'neovim-bin-*.pkg.tar.*' -print
