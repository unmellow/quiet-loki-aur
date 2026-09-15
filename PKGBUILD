# Maintainer: Unmellow <Amazingminecrafter2015@gmail.com>
# shellcheck shell=bash disable=SC2034,SC2154
pkgname=quiet-loki-git
_pkgname=quiet-loki
pkgver=9.0.2.r0.g60e81232
pkgrel=1
pkgdesc="Quiet desktop chat with dual Tor + Lokinet overlay (.onion and .loki)"
arch=('x86_64')
url="https://github.com/unmellow/quiet-loki"
license=('GPL-3.0-or-later')
depends=('libxss' 'nss' 'gtk3' 'alsa-lib')
makedepends=('git' 'nodejs' 'npm' 'python' 'python-setuptools' 'gcc' 'make' 'patch')
optdepends=(
  'lokinet: required to dial and publish .loki SNApp addresses'
)
provides=("quiet-loki")
conflicts=("quiet-loki")
source=(
  "git+https://github.com/unmellow/quiet-loki.git#branch=develop"
  "quiet-loki.desktop"
  "quiet-loki.sh"
)
sha256sums=('SKIP'
            'SKIP'
            'SKIP')

pkgver() {
  cd "${srcdir}/${_pkgname}"
  local ver
  ver=$(git describe --tags --long --always 2>/dev/null || true)
  if [[ -n "$ver" ]]; then
    echo "$ver" | sed 's/^v//;s/-/.r/;s/-/./g'
  else
    printf "r%s.g%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short=8 HEAD)"
  fi
}

prepare() {
  cd "${srcdir}/${_pkgname}"
  git submodule update --init --recursive --depth 1 || true
}

build() {
  cd "${srcdir}/${_pkgname}"
  export HOME="${srcdir}/.home"
  export npm_config_cache="${srcdir}/.npm"
  mkdir -p "$HOME" "$npm_config_cache"

  npm i --ignore-scripts lerna@6.6.2 typescript@4.9.5
  npm i --ignore-scripts
  npm run pull:submodules || true
  npm run bootstrap

  cd packages/desktop
  npm run copyBinaries || true
  npm run build:prod
  npx electron-builder --linux --x64 --dir -p never
}

package() {
  local unpacked=""
  for d in \
    "${srcdir}/${_pkgname}/packages/desktop/dist/linux-unpacked" \
    "${srcdir}/${_pkgname}/packages/desktop/release/linux-unpacked"; do
    [[ -d "$d" ]] && unpacked="$d" && break
  done
  if [[ -z "$unpacked" ]]; then
    unpacked=$(find "${srcdir}/${_pkgname}/packages/desktop" -type d -name 'linux-unpacked' | head -n1)
  fi
  if [[ -z "$unpacked" ]]; then
    echo "electron-builder linux-unpacked output not found" >&2
    return 1
  fi

  install -d "${pkgdir}/usr/lib/${_pkgname}"
  cp -a "${unpacked}/." "${pkgdir}/usr/lib/${_pkgname}/"

  install -Dm755 "${srcdir}/quiet-loki.sh" "${pkgdir}/usr/bin/quiet-loki"
  install -Dm644 "${srcdir}/quiet-loki.desktop" "${pkgdir}/usr/share/applications/quiet-loki.desktop"

  local icon
  icon=$(find "${srcdir}/${_pkgname}/packages/desktop" -name 'icon.png' | head -n1)
  if [[ -n "$icon" ]]; then
    install -Dm644 "$icon" "${pkgdir}/usr/share/pixmaps/quiet-loki.png"
  fi

  install -Dm644 "${srcdir}/${_pkgname}/LICENSE.md" \
    "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
