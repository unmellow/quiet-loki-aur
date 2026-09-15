# Maintainer: Unmellow <Amazingminecrafter2015@gmail.com>
# shellcheck shell=bash disable=SC2034,SC2154
pkgname=quiet-loki-git
_pkgname=quiet-loki
_nodever=20.20.1
pkgver=9.0.2.r0.g60e81232
pkgrel=2
pkgdesc="Quiet desktop chat with dual Tor + Lokinet overlay (.onion and .loki)"
arch=('x86_64')
url="https://github.com/unmellow/quiet-loki"
license=('GPL-3.0-or-later')
depends=('libxss' 'nss' 'gtk3' 'alsa-lib')
makedepends=('git' 'python' 'python-setuptools' 'gcc' 'make' 'patch' 'pnpm')
optdepends=(
  'lokinet: required to dial and publish .loki SNApp addresses'
)
provides=("quiet-loki")
conflicts=("quiet-loki")
source=(
  "git+https://github.com/unmellow/quiet-loki.git#branch=develop"
  "https://nodejs.org/dist/v${_nodever}/node-v${_nodever}-linux-x64.tar.xz"
  "quiet-loki.desktop"
  "quiet-loki.sh"
)
sha256sums=('SKIP'
            'SKIP'
            'SKIP'
            'SKIP')

pkgver() {
  cd "${srcdir}/${_pkgname}"
  printf "r%s.g%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short=8 HEAD)"
}

prepare() {
  cd "${srcdir}/${_pkgname}"

  # Recorded SHAs only. Do NOT use --remote / npm run pull:submodules:
  # qss nests TryQuiet/auth on branch auth/main-baseline, and --no-fetch --remote
  # looks for refs/remotes/origin/auth/main-baseline which is not fetched.
  git submodule sync
  git submodule update --init --jobs 4

  # Recurse into nested modules using the commits their parents recorded.
  git submodule update --init --recursive --jobs 4 || {
    echo "warning: nested submodule recurse failed; continuing with first-level checkouts" >&2
    # qss expects 3rd-party/auth on auth/main-baseline — fetch that ref explicitly
    if [[ -d 3rd-party/qss/.git || -f 3rd-party/qss/.git ]]; then
      git -C 3rd-party/qss submodule sync || true
      git -C 3rd-party/qss fetch --recurse-submodules origin 'auth/main-baseline:refs/remotes/origin/auth/main-baseline' || true
      git -C 3rd-party/qss submodule update --init --recursive || true
    fi
  }
}

build() {
  local nodehome="${srcdir}/node-v${_nodever}-linux-x64"
  export PATH="${nodehome}/bin:${PATH}"
  export HOME="${srcdir}/.home"
  export npm_config_cache="${srcdir}/.npm"
  mkdir -p "$HOME" "$npm_config_cache"

  echo "Using $(node -v) / npm $(npm -v)"

  cd "${srcdir}/${_pkgname}"

  npm i --ignore-scripts lerna@6.6.2 typescript@4.9.5
  npm i --ignore-scripts

  # Build first-level 3rd-party libs. Skip pull:submodules (broken --remote).
  # Skip build:qss docker bootstrap; desktop does not need a running QSS.
  npm run build:auth || true
  npm run build:noise || true
  npm run build:orbitdb || true

  npx lerna bootstrap --ignore-scripts || npx lerna bootstrap

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
    unpacked=$(find "${srcdir}/${_pkgname}/packages/desktop" -type d -name 'linux-unpacked' | head -n1 || true)
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
  icon=$(find "${srcdir}/${_pkgname}/packages/desktop" -name 'icon.png' | head -n1 || true)
  if [[ -n "$icon" ]]; then
    install -Dm644 "$icon" "${pkgdir}/usr/share/pixmaps/quiet-loki.png"
  fi

  install -Dm644 "${srcdir}/${_pkgname}/LICENSE.md" \
    "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
