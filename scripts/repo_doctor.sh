#!/usr/bin/env bash
set -e
echo "== git =="; git fetch origin; git status -sb
echo "== workspace =="; test -f pnpm-workspace.yaml && echo '✓ workspace file'
test -f apps/server/src/index.ts && echo '✓ server entry'
echo "== docker db =="; docker compose ps
echo "== server smoke =="
PORT=${PORT:-3001}
kill -0 $(lsof -ti :$PORT) 2>/dev/null && kill -9 $(lsof -ti :$PORT) 2>/dev/null || true
( PORT=$PORT pnpm --filter ./apps/server dev > /tmp/pgm.dev.log 2>&1 & echo $! > /tmp/pgm.dev.pid )
sleep 2
curl -fsS "http://127.0.0.1:$PORT/health" && echo " ✓ /health"
kill "$(cat /tmp/pgm.dev.pid)" 2>/dev/null || true
