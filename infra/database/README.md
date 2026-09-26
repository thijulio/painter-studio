# Database migrations

Painter Studio uses Neon Postgres. Migrations are plain, transactional SQL so
they are provider-neutral Postgres artifacts rather than application code.

## Apply

Use a transaction-aware migration runner with `DATABASE_URL` set to the Neon
**pooled** connection string. Do not add that URL to git or echo it to a
terminal log. Apply migrations in lexical order, once per database.

`migrations/0001_initial.sql` establishes the bounded initial domain:

- identity-mapped users, images and canvas sizes;
- paint inventory, palettes and palette items;
- stored mix recipes plus an append-only mix event log;
- import audit and current field provenance;
- lifecycle fields, immutable `stable_id`s and optimistic `row_version`s.

The migration deliberately does not add `pgvector`: Painter Studio has no
semantic-retrieval workload yet. Add it in a dedicated, evaluated migration if
that need materializes.
