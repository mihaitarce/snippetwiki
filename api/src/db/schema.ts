import {pgTable, varchar, uuid, timestamp, text, integer, boolean, pgEnum, serial} from 'drizzle-orm/pg-core';
import {relations} from "drizzle-orm";

export const snippetsTable = pgTable('snippets', {
    id: uuid().primaryKey(),
    title: varchar().notNull(),

    // tags: json<string[]>().optional(),

    modified: timestamp({mode: 'string'}).notNull().defaultNow(),

    draft_title: varchar(),
    draft_created: timestamp({mode: 'string'}),
});

export const snippetsRelations = relations(snippetsTable, ({many}) => ({
    revisions: many(revisionsTable)
}));

export const contentTypeEnum = pgEnum('content_type', ['text/markdown'])

export const revisionsTable = pgTable('revisions', {
    id: uuid('id').primaryKey(),
    snippet_id: uuid('snippet_id').references(
        () => snippetsTable.id,
        {onDelete: 'cascade'}
    ).notNull(),
    author: varchar('author').notNull(),
    content: text().notNull(),
    content_type: contentTypeEnum().default('text/markdown').notNull(),
    version: serial().notNull(),
    file: boolean().default(false),
    created: timestamp({mode: 'string'}).notNull().defaultNow(),
})

export const revisionsRelations = relations(revisionsTable, ({one}) => ({
    snippet: one(snippetsTable, {
        fields: [revisionsTable.snippet_id],
        references: [snippetsTable.id]
    })
}));