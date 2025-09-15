import {revisionsTable, snippetsTable} from './db/schema.ts';
import {db} from './db/index.ts';

import {reset, seed} from 'drizzle-seed';

await reset(db, {snippetsTable, revisionsTable});

await seed(db, {snippetsTable, revisionsTable});
