import { eq } from 'drizzle-orm';
import { snippetsTable } from './db/schema.ts';
import {db, generateTxId} from "./db/index.ts";

import { serve } from '@hono/node-server'
import { Hono } from 'hono'
import { cors } from 'hono/cors'


const app = new Hono()

app.use('/snippets/*', cors())

app.get('/snippets/', async (c) => {
	const scores = await db.select().from(snippetsTable);
	return c.json(scores);
})

app.post('/snippets/', async (c) => {
		const score = await c.req.json()

		let result = {}
		await db.transaction(async (tx) => {
			result.snippet = await tx.insert(snippetsTable).values(score).returning();
			result.txid = await generateTxId(tx);
		})

		return c.json(result);
	})

app.put('/snippets/:id', async (c) => {
	const { id } = c.req.param()
	const score = await c.req.json()

	let result = {}
	await db.transaction(async (tx) => {
		result.snippet = await tx.update(snippetsTable).set(score).where(eq(snippetsTable.id, id)).returning();
		result.txid = await generateTxId(tx);
	})

	return c.json(result);
})

app.delete('/snippets/:id', async (c) => {
	const { id } = c.req.param()

	let result = {}
	await db.transaction(async (tx) => {
		await tx.delete(snippetsTable).where(eq(snippetsTable.id, id));
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
