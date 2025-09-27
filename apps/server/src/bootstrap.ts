import { pool } from './db';

export async function ensureSchema() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS memories (
      id BIGSERIAL PRIMARY KEY,
      owner_id TEXT,
      kind TEXT,
      content TEXT NOT NULL,
      embedding vector(1536),
      created_at TIMESTAMPTZ DEFAULT now()
    );
  `);
}
