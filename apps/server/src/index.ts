import Fastify from 'fastify';
import * as dotenv from 'dotenv';
dotenv.config();

import { pool } from './db';
import { ensureSchema } from './bootstrap';

const app = Fastify({ logger: true });

app.get('/health', async () => ({ ok: true }));

app.post('/memories', async (req) => {
  const body = req.body as { content: string; kind?: string; ownerId?: string };
  if (!body?.content || typeof body.content !== 'string') {
    throw app.httpErrors.badRequest('content (string) is required');
  }
  const { rows } = await pool.query(
    'INSERT INTO memories (owner_id, kind, content) VALUES ($1,$2,$3) RETURNING id, owner_id, kind, content, created_at',
    [body.ownerId ?? 'local', body.kind ?? 'note', body.content]
  );
  return rows[0];
});

app.get('/memories', async () => {
  const { rows } = await pool.query(
    'SELECT id, owner_id, kind, content, created_at FROM memories ORDER BY id DESC LIMIT 20'
  );
  return rows;
});

const port = Number(process.env.PORT ?? 3001);
await ensureSchema();
await app.listen({ port, host: '0.0.0.0' });
