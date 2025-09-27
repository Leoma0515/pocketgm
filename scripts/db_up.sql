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
-- Optional later, after you have data:
-- CREATE INDEX IF NOT EXISTS idx_memories_embedding
--   ON memories USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
