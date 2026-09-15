# quiet-loki-git

AUR sources for [unmellow/quiet-loki](https://github.com/unmellow/quiet-loki).
Packaging follows:

- [AUR submission guidelines](https://wiki.archlinux.org/title/AUR_submission_guidelines)
- [Electron package guidelines](https://wiki.archlinux.org/title/Electron_package_guidelines)
- [Node.js package guidelines](https://wiki.archlinux.org/title/Node.js_package_guidelines)
- [VCS package guidelines](https://wiki.archlinux.org/title/VCS_package_guidelines)

## What this does *not* do

It does **not** ship a private Electron binary. `electron-builder --dir` is pointed at Arch `electron32`; `package()` keeps `resources/app` (or `app.asar`) plus bundled Tor under `/usr/lib/quiet-loki`. The launcher is:

```sh
exec electron32 /usr/lib/quiet-loki "$@"
```

Node 20.20.1 is only a **build** dependency, installed via `nvm` from Quiet's `.nvmrc`. It is not a runtime dep.

## Build

```bash
sudo pacman -S --needed base-devel git npm nvm python python-setuptools pnpm electron32
git pull
makepkg -Csi
```

## Publish to aur.archlinux.org

AUR only accepts the `master` branch. Package sources in this GitHub repo are licensed 0BSD (`LICENSE`) so they stay eligible for later [official repo promotion rules](https://rfc.archlinux.page/0040-license-package-sources/#aur).

```bash
git -c init.defaultBranch=master clone ssh://aur@aur.archlinux.org/quiet-loki-git.git
cp PKGBUILD .SRCINFO LICENSE quiet-loki.desktop quiet-loki.sh quiet-loki-git/
cd quiet-loki-git
makepkg --printsrcinfo > .SRCINFO
git add PKGBUILD .SRCINFO LICENSE quiet-loki.desktop quiet-loki.sh
git commit -m "initial import: quiet-loki-git"
git push
```
