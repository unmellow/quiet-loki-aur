# quiet-loki-git (AUR)

Arch package sources for [unmellow/quiet-loki](https://github.com/unmellow/quiet-loki).

## Local build

```bash
sudo pacman -S --needed base-devel git python python-setuptools pnpm
git clone https://github.com/unmellow/quiet-loki-aur.git
cd quiet-loki-aur
makepkg -si
```

The PKGBUILD downloads **Node 20.20.1** (Quiet's pinned engine) instead of using Arch's current Node. Do not use system Node 26.

Submodules are checked out at the SHAs recorded in Quiet-Loki. The stock `npm run pull:submodules` (`--remote --no-fetch`) is skipped because `3rd-party/qss` tracks `auth/main-baseline` and that remote ref is not present after a shallow `--no-fetch`.

QSS docker bootstrap is also skipped; the desktop client does not need a running storage service to build.

## Runtime

```bash
quiet-loki
```

Optional: install lokinet for `.loki` peers. Tor stays bundled for `.onion`.
