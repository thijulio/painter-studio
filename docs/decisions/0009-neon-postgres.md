# ADR-0009 — Neon as the application Postgres provider

Status: **accepted**

## Context

Painter Studio needs relational, user-scoped data for images, paint inventory,
palettes and mix recipes. The infrastructure handover requires the data model
to follow the useful structural conventions from Thiago Smart Library without
copying its book-domain tables. The project runs its server-side endpoints as
Netlify Functions, so database connections must tolerate short-lived,
concurrent execution.

## Decision

Use Neon Postgres, in AWS Europe West 2 (London), with the pooled connection
string supplied to Netlify as the secret `DATABASE_URL`.

The initial schema is plain PostgreSQL migration SQL. It uses surrogate bigint
keys plus immutable external `stable_id`s, normalized joins, lifecycle fields,
optimistic `row_version`s, soft deletion, import audit, field provenance and
an append-only event log for saved/voided mix recipes.

## Consequences

- Netlify Functions use the pooled URL; browser and Expo clients never receive
  database credentials.
- The database layer remains portable PostgreSQL rather than coupled to a
  provider client SDK.
- `pg_trgm` supports catalog search. `pgvector` is intentionally deferred until
  a concrete retrieval workload and evaluation justify it.
- London is the nearest available Neon region to Bordeaux. Netlify Functions
  retain Netlify's account-selected execution region; cross-region latency
  should be measured before a latency-sensitive backend feature is introduced.
