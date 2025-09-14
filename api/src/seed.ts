import {snippetsTable} from './db/schema.ts';
import {db} from './db/index.ts';

import {reset, seed} from 'drizzle-seed';

await reset(db, {snippetsTable});

await seed(db, {snippetsTable});
