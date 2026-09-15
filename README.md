# quiet-loki-git

AUR sources for [unmellow/quiet-loki](https://github.com/unmellow/quiet-loki).
Packaging follows:

- [AUR submission guidelines](https://wiki.archlinux.org/title/AUR_submission_guidelines)
- [Arch package guidelines](https://wiki.archlinux.org/title/Arch_package_guidelines)
- [Electron package guidelines](https://wiki.archlinux.org/title/Electron_package_guidelines)
- [Node.js package guidelines](https://wiki.archlinux.org/title/Node.js_package_guidelines)
- [VCS package guidelines](https://wiki.archlinux.org/title/VCS_package_guidelines)

Package sources (`PKGBUILD` and helpers) are licensed 0BSD (`LICENSE`, `REUSE.toml`).

## What this does *not* do

It does **not** ship a private Electron binary. `electron-builder --dir` is pointed
at Arch `electron32`; `package()` keeps `resources/app` (or `app.asar`) plus bundled
Tor under `/usr/lib/quiet-loki`. The launcher is:

```sh
exec /usr/bin/electron32 /usr/lib/quiet-loki "$@"
```

Node 20.20.1 is only a **build** dependency, installed via `nvm` from Quiet's
`.nvmrc`. It is not a runtime dep.

`gcc`, `make`, and `patch` are **not** listed in `makedepends`: they come from
`base-devel`, which `makepkg` already requires.

## Build

```bash
sudo pacman -S --needed base-devel git npm nvm python python-setuptools pnpm electron32
makepkg -Csi
```

## Publish to aur.archlinux.org

AUR only accepts the `master` branch. `quiet-loki-git` is a VCS package (`-git`
suffix, `pkgver()` from commit count). Do not commit mere `pkgver` bumps.

```bash
git -c init.defaultBranch=master clone ssh://aur@aur.archlinux.org/quiet-loki-git.git
cp PKGBUILD .SRCINFO LICENSE REUSE.toml quiet-loki.desktop quiet-loki.sh quiet-loki-git/
mkdir -p quiet-loki-git/LICENSES
cp LICENSES/0BSD.txt quiet-loki-git/LICENSES/
cd quiet-loki-git
makepkg --printsrcinfo > .SRCINFO
git add PKGBUILD .SRCINFO LICENSE REUSE.toml LICENSES quiet-loki.desktop quiet-loki.sh
git commit -m "quiet-loki-git: follow AUR submission and Electron/Node guidelines"
git push
```
