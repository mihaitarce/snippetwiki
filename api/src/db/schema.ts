import { pgTable, serial, real, varchar } from 'drizzle-orm/pg-core';

export const scoresTable = pgTable('scores', {
	id: serial('id').primaryKey(),
	name: varchar('name').notNull(),
	value: real('value'),
});
