# Maintainer: Unmellow <amazingminecrafter2015 at gmail dot com>
# shellcheck shell=bash disable=SC2034,SC2154
#
# Electron: system electron32 + resources/app (wiki Electron package guidelines).
# Node for the *build* only: nvm + .nvmrc (wiki Node.js package guidelines).
# Do not vendor a private Electron runtime in the installed package.

pkgname=quiet-loki-git
_pkgname=quiet-loki
_electron=electron32
pkgver=r1.g60e81232
pkgrel=4
pkgdesc="Quiet desktop chat with dual Tor + Lokinet overlay (.onion and .loki)"
arch=('x86_64')
url="https://github.com/unmellow/quiet-loki"
license=('GPL-3.0-or-later')
depends=("$_electron" 'libxss' 'nss' 'gtk3' 'alsa-lib')
makedepends=('git' 'npm' 'nvm' 'python' 'python-setuptools' 'gcc' 'make' 'patch' 'pnpm')
optdepends=('lokinet: dial and publish .loki SNApp addresses')
provides=('quiet-loki')
conflicts=('quiet-loki')
source=(
  "git+https://github.com/unmellow/quiet-loki.git#branch=develop"
  "quiet-loki.desktop"
  "quiet-loki.sh"
)
sha256sums=('SKIP'
            '4615a2a41e4289237d89ce32a263bc3ddfa0e1c134d866c09338e716c3b47a3e'
            '78ec1e5d8e136e28e4d1c1f15e014906d2cdddbab9203d4df7c34c1ef382413f')

_ensure_local_nvm() {
  command -v nvm >/dev/null 2>&1 && nvm deactivate && nvm unload || true
  export NVM_DIR="${srcdir}/.nvm"
  # init-nvm.sh returns 3 when .nvmrc is not installed yet
  # shellcheck source=/usr/share/nvm/init-nvm.sh
  source /usr/share/nvm/init-nvm.sh || [[ $? != 1 ]]
}

pkgver() {
  cd "${srcdir}/${_pkgname}"
  printf "r%s.g%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short=8 HEAD)"
}

prepare() {
  cd "${srcdir}/${_pkgname}"
  git submodule sync
  git submodule update --init --jobs 4
  git submodule update --init --recursive --jobs 4 || true

  _ensure_local_nvm
  nvm install
}

build() {
  _ensure_local_nvm
  nvm use

  export HOME="${srcdir}/.home"
  export HUSKY=0
  export HUSKY_SKIP_INSTALL=1
  mkdir -p "$HOME"

  cd "${srcdir}/${_pkgname}"

  find . -name package.json -print0 | xargs -0 sed -i \
    -e 's/"prepare": "husky[^"]*"/"prepare": "true"/g' || true

  npm install --ignore-scripts --cache "${srcdir}/npm-cache" lerna@6.6.2 typescript@4.9.5
  npm install --ignore-scripts --cache "${srcdir}/npm-cache"

  npm run build:auth || true
  npm run build:noise || true
  npm run build:orbitdb || true

  npx lerna bootstrap --ignore-scripts --ignore '@quiet/mobile' --ignore 'e2e-tests'

  cd packages/desktop
  npm run copyBinaries || true
  npm run build:prod

  local electron_dist="/usr/lib/${_electron}"
  local electron_ver
  electron_ver=$(<"${electron_dist}/version")
  electron_ver=${electron_ver#v}

  ./node_modules/.bin/electron-builder --linux --x64 --dir -p never \
    -c.electronDist="${electron_dist}" \
    -c.electronVersion="${electron_ver}"
}

package() {
  local unpacked=""
  for d in \
    "${srcdir}/${_pkgname}/packages/desktop/dist/linux-unpacked" \
    "${srcdir}/${_pkgname}/packages/desktop/release/linux-unpacked"; do
    [[ -d "$d" ]] && unpacked="$d" && break
  done
  [[ -z "$unpacked" ]] && unpacked=$(find "${srcdir}/${_pkgname}/packages/desktop" -type d -name 'linux-unpacked' | head -n1 || true)
  [[ -n "$unpacked" ]] || { echo "linux-unpacked not found" >&2; return 1; }

  # Keep JS app payload only. Throw away the copied Electron runtime.
  install -d "${pkgdir}/usr/lib/${_pkgname}"
  if [[ -d "${unpacked}/resources/app" ]]; then
    cp -a "${unpacked}/resources/app/." "${pkgdir}/usr/lib/${_pkgname}/"
  elif [[ -f "${unpacked}/resources/app.asar" ]]; then
    install -Dm644 "${unpacked}/resources/app.asar" "${pkgdir}/usr/lib/${_pkgname}/app.asar"
    [[ -d "${unpacked}/resources/app.asar.unpacked" ]] && \
      cp -a "${unpacked}/resources/app.asar.unpacked" "${pkgdir}/usr/lib/${_pkgname}/app.asar.unpacked"
    # asar-only layout: launcher still points at the directory; electron loads app.asar from cwd/resources.
    install -d "${pkgdir}/usr/lib/${_pkgname}/resources"
    mv "${pkgdir}/usr/lib/${_pkgname}/app.asar" "${pkgdir}/usr/lib/${_pkgname}/resources/app.asar"
    [[ -d "${pkgdir}/usr/lib/${_pkgname}/app.asar.unpacked" ]] && \
      mv "${pkgdir}/usr/lib/${_pkgname}/app.asar.unpacked" "${pkgdir}/usr/lib/${_pkgname}/resources/app.asar.unpacked"
  else
    echo "neither resources/app nor app.asar found in ${unpacked}" >&2
    return 1
  fi

  # Bundled Tor bits live next to the app in extraResources
  if [[ -d "${unpacked}/resources/tor" ]]; then
    cp -a "${unpacked}/resources/tor" "${pkgdir}/usr/lib/${_pkgname}/resources/tor"
  fi

  install -Dm755 "${srcdir}/quiet-loki.sh" "${pkgdir}/usr/bin/quiet-loki"
  install -Dm644 "${srcdir}/quiet-loki.desktop" "${pkgdir}/usr/share/applications/quiet-loki.desktop"

  local icon
  icon=$(find "${srcdir}/${_pkgname}/packages/desktop" -name 'icon.png' | head -n1 || true)
  [[ -n "$icon" ]] && install -Dm644 "$icon" "${pkgdir}/usr/share/pixmaps/quiet-loki.png"

  install -Dm644 "${srcdir}/${_pkgname}/LICENSE.md" \
    "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
