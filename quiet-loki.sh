#!/bin/sh
export LOKINET_BIN="${LOKINET_BIN:-/usr/bin/lokinet}"
export LOKINET_API="${LOKINET_API:-http://127.0.0.1:1190}"
exec /usr/lib/quiet-loki/quiet "$@"
