# Maintainer: Unmellow <amazingminecrafter2015 at gmail dot com>
# shellcheck shell=bash disable=SC2034,SC2154
#
# Electron: system electron32 + resources/app (wiki Electron package guidelines).
# Node for the *build* only: nvm + Node 20.20.1 (Quiet engines).
# Do not vendor a private Electron runtime in the installed package.

pkgname=quiet-loki-git
_pkgname=quiet-loki
_electron=electron32
_nodever=20.20.1
pkgver=r1.g60e81232
pkgrel=10
pkgdesc="Quiet desktop chat with dual Tor + Lokinet overlay (.onion and .loki)"
arch=('x86_64')
url="https://github.com/unmellow/quiet-loki"
license=('GPL-3.0-or-later')
depends=("$_electron" 'libxss' 'nss' 'gtk3' 'alsa-lib')
makedepends=('git' 'npm' 'nvm' 'python' 'python-setuptools' 'pnpm')
optdepends=('lokinet: dial and publish .loki SNApp addresses')
provides=("quiet-loki=${pkgver}")
conflicts=('quiet-loki')
options=('!strip' '!debug')
source=(
  "${_pkgname}::git+https://github.com/unmellow/quiet-loki.git#branch=develop"
  "quiet-loki.desktop"
  "quiet-loki.sh"
)
sha256sums=('SKIP'
            '760a180527a1fe2549f3c12834c26b473970c87f1dbd96f06e4d1dc4ae901e75'
            'a71142372c7b50cffacebf74e91e6b179e215d9e822417b3f2f7eb56e5239a90')

_ensure_local_nvm() {
  command -v nvm >/dev/null 2>&1 && nvm deactivate && nvm unload || true
  export NVM_DIR="${srcdir}/.nvm"
  source /usr/share/nvm/init-nvm.sh || [[ $? != 1 ]]
  nvm install "${_nodever}"
  nvm use "${_nodever}"
}

pkgver() {
  cd "${srcdir}/${_pkgname}"
  printf "r%s.g%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short=8 HEAD)"
}

prepare() {
  cd "${srcdir}/${_pkgname}"
  git fetch origin develop || true
  git checkout develop || true
  git reset --hard origin/develop || true
  git submodule sync --quiet
  git submodule update --init --recursive --jobs "$(nproc)"

  # System electron32 sets process.resourcesPath to /usr/lib/electron32/resources.
  sed -i 's|`${process.resourcesPath}`|`${process.env.QUIET_RESOURCES || process.resourcesPath}`|g' \
    packages/desktop/src/main/main.ts || true

  _ensure_local_nvm
}

build() {
  _ensure_local_nvm

  export HOME="${srcdir}/.home"
  export HUSKY=0
  export HUSKY_SKIP_INSTALL=1
  mkdir -p "$HOME"

  echo "Using $(node -v) / npm $(npm -v)"

  cd "${srcdir}/${_pkgname}"

  find . -name package.json -print0 | xargs -0 sed -i \
    -e 's/"prepare": "husky[^"]*"/"prepare": "true"/g' \
    -e 's/"prepare": "npm run webpack"/"prepare": "true"/g' \
    -e 's/"prepare": "npm run webpack:configtest:dev[^"]*"/"prepare": "true"/g' || true

  if [[ ! -d node_modules/lerna ]]; then
    npm install --ignore-scripts --cache "${srcdir}/npm-cache" lerna@6.6.2 typescript@4.9.5
    npm install --ignore-scripts --cache "${srcdir}/npm-cache"
    npm run build:auth || true
    npm run build:noise || true
    npm run build:orbitdb || true
    npx lerna bootstrap --ignore-scripts --ignore '@quiet/mobile' --ignore 'e2e-tests'
    npx lerna run build --scope '@quiet/types'
    npx lerna run build --scope '@quiet/logger'
    npx lerna run build --scope '@quiet/eslint-config' || true
    npx lerna run build --scope '@quiet/common'
    npx lerna run build --scope '@quiet/identity'
    npx lerna run build --scope '@quiet/node-common' || true
    npx lerna run build --scope '@quiet/state-manager'
  fi

  npx lerna run build --scope '@quiet/backend' || true
  (cd packages/backend && npm run webpack:prod)
  npx lerna run build --scope 'backend-bundle' || true

  mkdir -p packages/desktop/node_modules/@quiet
  for _pkg in common types state-manager node-common logger identity backend; do
    [[ -e "packages/desktop/node_modules/@quiet/${_pkg}" ]] && continue
    ln -sfn "../../${_pkg}" "packages/desktop/node_modules/@quiet/${_pkg}"
  done

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
  [[ -n "$unpacked" ]] || { echo "linux-unpacked not found" >&2; return 1; }

  install -d "${pkgdir}/usr/lib/${_pkgname}"
  if [[ -d "${unpacked}/resources/app" ]]; then
    cp -a "${unpacked}/resources/app/." "${pkgdir}/usr/lib/${_pkgname}/"
  elif [[ -f "${unpacked}/resources/app.asar" ]]; then
    install -d "${pkgdir}/usr/lib/${_pkgname}/resources"
    install -Dm644 "${unpacked}/resources/app.asar" \
      "${pkgdir}/usr/lib/${_pkgname}/resources/app.asar"
    if [[ -d "${unpacked}/resources/app.asar.unpacked" ]]; then
      cp -a "${unpacked}/resources/app.asar.unpacked" \
        "${pkgdir}/usr/lib/${_pkgname}/resources/app.asar.unpacked"
    fi
  else
    echo "neither resources/app nor app.asar found in ${unpacked}" >&2
    return 1
  fi

  local tordir=""
  if [[ -d "${unpacked}/resources/tor" ]]; then
    tordir="${unpacked}/resources/tor"
  elif [[ -d "${srcdir}/${_pkgname}/3rd-party/tor/linux" ]]; then
    tordir="${srcdir}/${_pkgname}/3rd-party/tor/linux"
  fi
  if [[ -n "$tordir" ]]; then
    install -d "${pkgdir}/usr/lib/${_pkgname}/resources/tor"
    cp -a "${tordir}/." "${pkgdir}/usr/lib/${_pkgname}/resources/tor/"
  fi

  install -Dm755 "${srcdir}/quiet-loki.sh" "${pkgdir}/usr/bin/quiet-loki"
  install -Dm644 "${srcdir}/quiet-loki.desktop" \
    "${pkgdir}/usr/share/applications/quiet-loki.desktop"

  local icon="${srcdir}/${_pkgname}/packages/desktop/build/icon.png"
  if [[ -f "$icon" ]]; then
    install -Dm644 "$icon" "${pkgdir}/usr/share/icons/hicolor/512x512/apps/quiet-loki.png"
    install -Dm644 "$icon" "${pkgdir}/usr/share/pixmaps/quiet-loki.png"
  fi

  install -Dm644 "${srcdir}/${_pkgname}/LICENSE.md" \
    "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
