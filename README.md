PocketGM — Dev Quickstart
Local dev uses pnpm, a Fastify server in apps/server, and Postgres 16 + pgvector via Docker (Colima). This repo is a pnpm workspace (monorepo-style).
0) Prereqs
macOS + Homebrew
pnpm, Docker (via Colima), Compose
brew install pnpm colima docker docker-compose
colima start --cpu 2 --memory 4 --disk 30
docker context use colima
docker version            # should show a running Server
docker compose version    # should print v2.x
1) Clone & install
git clone https://github.com/Leoma0515/pocketgm
cd pocketgm
pnpm install
2) Database (Dockerized Postgres 16 + pgvector)
We run Postgres in a container to avoid Homebrew extension issues.
docker-compose.yml (already in repo):
services:
  db:
    image: pgvector/pgvector:pg16
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: pocketgm
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
volumes:
  pgdata:
Bring it up:
docker compose up -d
docker compose ps
Initialize schema (idempotent):
docker compose exec -T db psql -U postgres -d pocketgm -f /dev/stdin <<'SQL'
CREATE EXTENSION IF NOT EXISTS vector;
CREATE TABLE IF NOT EXISTS memories (
  id BIGSERIAL PRIMARY KEY,
  owner_id TEXT,
  kind TEXT,
  content TEXT NOT NULL,
  embedding vector(1536),
  created_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_memories_created ON memories (created_at DESC);
SQL
3) Environment
Copy the example and edit if needed:
cp apps/server/.env.example apps/server/.env
Defaults (works with the Docker DB):
DATABASE_URL=postgres://postgres:postgres@localhost:5432/pocketgm
PORT=3001   # optional, otherwise defaults to 3000
4) Run the server
From repo root:
pnpm dev:server            # starts Fastify in watch mode via tsx
# or force a port:
PORT=3001 pnpm dev:server
Smoke tests:
curl -s http://127.0.0.1:3001/health
curl -s -X POST http://127.0.0.1:3001/memories \
  -H 'content-type: application/json' \
  -d '{"content":"hello, pocketgm"}'
curl -s http://127.0.0.1:3001/memories | jq .
5) Common commands
# start/stop DB
docker compose up -d
docker compose down

# psql into the container DB
docker compose exec -it db psql -U postgres -d pocketgm

# rebuild deps when pnpm blocks postinstall scripts
pnpm approve-builds --save
pnpm -r rebuild

# run server in background (quick & dirty)
PORT=3001 pnpm --filter ./apps/server dev > /tmp/pocketgm.log 2>&1 &
echo $! > /tmp/pocketgm.pid
# stop:
kill "$(cat /tmp/pocketgm.pid)" 2>/dev/null || true
6) Troubleshooting
“address already in use 0.0.0.0:3000/3001”
lsof -i :3001
kill $(lsof -ti :3001) 2>/dev/null || kill -9 $(lsof -ti :3001)
“role 'postgres' does not exist”
You’re hitting the wrong DB. Point to the Docker DB and stop Homebrew Postgres:
brew services stop postgresql@16 2>/dev/null || true
Docker can’t connect / no server
colima start
docker context use colima
docker version
pnpm warns about workspaces
This repo uses pnpm-workspace.yaml (already present). No workspaces field in root package.json.
7) Project layout
pnpm-workspace.yaml
package.json              # scripts: dev:server, build
docker-compose.yml        # pg16 + pgvector
apps/
  server/
    package.json          # scripts: dev/build/start
    tsconfig.json
    src/
      index.ts            # Fastify server with /health & /memories
    .env.example
scripts/
  db_up.sql               # optional bootstrap (not used when Docker init is used)
  db_down.sql
8) Notes & next steps
Why Docker DB? pgvector on Homebrew can mismatch Postgres version. The pgvector/pgvector:pg16 image keeps it simple.
Embedding search (add after you have data):
CREATE INDEX IF NOT EXISTS idx_memories_embedding
  ON memories USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
ANALYZE memories;
Monorepo growth: add more apps under apps/* and shared libs under packages/*.
9) One-liner setup (for new machines)
git clone https://github.com/Leoma0515/pocketgm && cd pocketgm \
&& brew install pnpm colima docker docker-compose \
&& colima start && docker context use colima \
&& pnpm install \
&& docker compose up -d \
&& docker compose exec -T db psql -U postgres -d pocketgm -f /dev/stdin <<'SQL'
CREATE EXTENSION IF NOT EXISTS vector;
CREATE TABLE IF NOT EXISTS memories (
  id BIGSERIAL PRIMARY KEY,
  owner_id TEXT, kind TEXT, content TEXT NOT NULL,
  embedding vector(1536), created_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_memories_created ON memories (created_at DESC);
SQL
