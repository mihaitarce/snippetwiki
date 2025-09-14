import {pgTable, real, varchar, uuid, timestamp} from 'drizzle-orm/pg-core';

export const snippetsTable = pgTable('snippets', {
	id: uuid('id').primaryKey(),
	name: varchar('name').notNull(),
	value: real('value'),
	modified: timestamp('modified', { mode: 'string'}).notNull().defaultNow(),
});
