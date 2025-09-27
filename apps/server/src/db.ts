import { Pool } from 'pg';

const url = process.env.DATABASE_URL ?? 'postgres://postgres:postgres@localhost:5432/pocketgm';
export const pool = new Pool({ connectionString: url });
