#!/usr/bin/env bash
set -euo pipefail
umask 022

usage() {
  cat <<'EOF'
Usage: scripts/build-deb-package.sh VERSION ARCHIVE [OUTPUT_DIR]

Build a Debian neovim-bin package from Neovim's official
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

command -v dpkg-deb >/dev/null || {
  echo 'error: dpkg-deb was not found; install dpkg' >&2
  exit 1
}

version=${1#v}
archive=$(realpath "$2")
output_dir=$(realpath -m "${3:-dist}")
repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)

[[ $version =~ ^[0-9][A-Za-z0-9.+:~-]*$ ]] || {
  echo "error: invalid Debian package version: $version" >&2
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
package_root="$work_dir/neovim-bin"
mkdir -p -- "$package_root/DEBIAN" "$package_root/usr"

sed "s/@PKGVER@/${version}/g" \
  "$repo_root/packaging/deb/control.in" >"$package_root/DEBIAN/control"
tar -xzf "$archive" \
  --strip-components=1 \
  --no-same-owner \
  --no-same-permissions \
  -C "$package_root/usr"

mkdir -p -- "$output_dir"
package="$output_dir/neovim-bin_${version}_amd64.deb"
dpkg-deb --build --root-owner-group "$package_root" "$package"

printf 'Built package:\n%s\n' "$package"
