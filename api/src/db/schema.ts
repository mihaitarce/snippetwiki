import {pgTable, real, varchar, uuid} from 'drizzle-orm/pg-core';

export const snippetsTable = pgTable('scores', {
	id: uuid('id').primaryKey(),
	name: varchar('name').notNull(),
	value: real('value'),
});
