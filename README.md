# quiet-loki-git (AUR)

Arch package sources for [unmellow/quiet-loki](https://github.com/unmellow/quiet-loki).

## Local build

```bash
sudo pacman -S --needed base-devel git nodejs npm python python-setuptools
git clone https://github.com/unmellow/quiet-loki-aur.git
cd quiet-loki-aur
makepkg -si
```

The first build compiles the Quiet monorepo + Electron app and takes a long time and a lot of disk.

## Runtime

Install [lokinet](https://github.com/oxen-io/lokinet) (AUR/`lokinet` if packaged) if you want `.loki` peers. Tor is still bundled for `.onion`.

```bash
quiet-loki
```

Env overrides: `LOKINET_BIN`, `LOKINET_API`.

## Publish to AUR

```bash
git clone ssh://aur@aur.archlinux.org/quiet-loki-git.git
cp PKGBUILD .SRCINFO quiet-loki.desktop quiet-loki.sh quiet-loki-git/
cd quiet-loki-git
makepkg --printsrcinfo > .SRCINFO
git add PKGBUILD .SRCINFO quiet-loki.desktop quiet-loki.sh
git commit -m "initial import: quiet-loki-git"
git push
```

After a Quiet-Loki commit, bump with `makepkg` so `pkgver()` refreshes, then update `.SRCINFO`.
