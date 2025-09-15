import {pgTable, varchar, uuid, timestamp, text, integer, boolean, pgEnum} from 'drizzle-orm/pg-core';
import {relations} from "drizzle-orm";

export const snippetsTable = pgTable('snippets', {
    id: uuid().primaryKey(),
    title: varchar().notNull(),

    // tags: json<string[]>().optional(),

    modified: timestamp({mode: 'string'}).notNull().defaultNow(),

    draft_title: varchar(),
    draft_created: timestamp(),
});

export const snippetsRelations = relations(snippetsTable, ({many}) => ({
    revisions: many(revisionsTable)
}));

export const contentTypeEnum = pgEnum('content_type', ['text/markdown'])

export const revisionsTable = pgTable('revisions', {
    id: uuid('id').primaryKey(),
    article_id: uuid('article_id').references(
        () => snippetsTable.id,
        {onDelete: 'cascade'}
    ).notNull(),
    author: varchar('author').notNull(),
    content: text().notNull(),
    content_type: contentTypeEnum().default('text/markdown').notNull(),
    revision: integer().notNull(),
    file: boolean().default(false),
    created: timestamp().defaultNow(),
})

export const revisionsRelations = relations(revisionsTable, ({one}) => ({
    article: one(snippetsTable, {
        fields: [revisionsTable.article_id],
        references: [snippetsTable.id]
    })
}));