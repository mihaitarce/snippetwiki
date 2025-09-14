import 'dotenv/config';
import { eq } from 'drizzle-orm';
import { scoresTable } from './db/schema';

import { serve } from '@hono/node-server'
import { Hono } from 'hono'
import { cors } from 'hono/cors'
import {db, generateTxId} from "./db/index";


const app = new Hono()

app.use('/snippets/*', cors())

app.get('/snippets/', async (c) => {
	const scores = await db.select().from(scoresTable);
	return c.json(scores);
})

app.post('/snippets/', async (c) => {
		const score = await c.req.json()

		let result = {}
		await db.transaction(async (tx) => {
			result.snippet = await tx.insert(scoresTable).values(score).returning();
			result.txid = await generateTxId(tx);
		})

		return c.json(result);
	})

app.put('/snippets/:id', async (c) => {
	const { id } = c.req.param()
	const score = await c.req.json()

	let result = {}
	await db.transaction(async (tx) => {
		result.snippet = await tx.update(scoresTable).set(score).where(eq(scoresTable.id, id)).returning();
		result.txid = await generateTxId(tx);
	})

	return c.json(result);
})

app.delete('/snippets/:id', async (c) => {
	const { id } = c.req.param()

	let result = {}
	await db.transaction(async (tx) => {
		await tx.delete(scoresTable).where(eq(scoresTable.id, id));
		result.txid = await generateTxId(tx)
	})
	return c.json(result);
})

serve({
  fetch: app.fetch,
  port: 5000
}, (info) => {
  console.log(`Server is running on http://localhost:${info.port}`)
})
