#!/bin/sh
# Launch against Arch's electron32 (Electron package guidelines).
export LOKINET_BIN="${LOKINET_BIN:-/usr/bin/lokinet}"
export LOKINET_API="${LOKINET_API:-http://127.0.0.1:1190}"

APP=/usr/lib/quiet-loki
if [ -f "$APP/package.json" ]; then
  exec /usr/bin/electron32 "$APP" "$@"
elif [ -f "$APP/resources/app.asar" ]; then
  exec /usr/bin/electron32 "$APP/resources/app.asar" "$@"
elif [ -d "$APP/resources/app" ]; then
  exec /usr/bin/electron32 "$APP/resources/app" "$@"
fi

echo "quiet-loki: no Electron app payload under $APP" >&2
ls -la "$APP" "$APP/resources" 2>/dev/null >&2 || true
exit 1
