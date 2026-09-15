#!/bin/sh
# Run Quiet-Loki against Arch's electron32 (Electron package guidelines).
export LOKINET_BIN="${LOKINET_BIN:-/usr/bin/lokinet}"
export LOKINET_API="${LOKINET_API:-http://127.0.0.1:1190}"
exec electron32 /usr/lib/quiet-loki "$@"
