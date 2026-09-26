-- Painter Studio initial schema.
-- Target: Neon Postgres 18. Apply once, through a transaction-aware migration runner.
-- The application uses Netlify Identity IDs as stable external references; all
-- relational joins use surrogate bigint keys.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION public.touch_lifecycle_fields()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.stable_id IS DISTINCT FROM OLD.stable_id THEN
    RAISE EXCEPTION 'stable_id is immutable';
  END IF;

  NEW.updated_at := transaction_timestamp();
  NEW.row_version := OLD.row_version + 1;
  RETURN NEW;
END;
$$;

CREATE TABLE public.app_users (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  stable_id text NOT NULL UNIQUE,
  email text,
  display_name text,
  created_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  updated_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  updated_by text NOT NULL,
  row_version bigint NOT NULL DEFAULT 1,
  archived_at timestamptz,
  CONSTRAINT app_users_stable_id_nonblank CHECK (btrim(stable_id) <> ''),
  CONSTRAINT app_users_email_nonblank CHECK (email IS NULL OR btrim(email) <> ''),
  CONSTRAINT app_users_row_version_positive CHECK (row_version > 0)
);

CREATE TABLE public.canvas_sizes (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  stable_id text NOT NULL UNIQUE,
  owner_id bigint REFERENCES public.app_users(id) ON DELETE RESTRICT,
  label text NOT NULL,
  width_mm numeric(8,2) NOT NULL,
  height_mm numeric(8,2) NOT NULL,
  created_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  updated_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  updated_by text NOT NULL,
  row_version bigint NOT NULL DEFAULT 1,
  archived_at timestamptz,
  CONSTRAINT canvas_sizes_stable_id_nonblank CHECK (btrim(stable_id) <> ''),
  CONSTRAINT canvas_sizes_label_nonblank CHECK (btrim(label) <> ''),
  CONSTRAINT canvas_sizes_dimensions_positive CHECK (width_mm > 0 AND height_mm > 0),
  CONSTRAINT canvas_sizes_row_version_positive CHECK (row_version > 0),
  CONSTRAINT canvas_sizes_standard_or_owned CHECK (owner_id IS NULL OR owner_id > 0)
);

CREATE TABLE public.images (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  stable_id text NOT NULL UNIQUE,
  owner_id bigint NOT NULL REFERENCES public.app_users(id) ON DELETE RESTRICT,
  s3_key text NOT NULL UNIQUE,
  original_filename text,
  content_type text NOT NULL,
  byte_size bigint,
  width_px integer NOT NULL,
  height_px integer NOT NULL,
  created_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  updated_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  updated_by text NOT NULL,
  row_version bigint NOT NULL DEFAULT 1,
  archived_at timestamptz,
  CONSTRAINT images_stable_id_nonblank CHECK (btrim(stable_id) <> ''),
  CONSTRAINT images_s3_key_nonblank CHECK (btrim(s3_key) <> ''),
  CONSTRAINT images_content_type_allowed CHECK (content_type IN ('image/jpeg', 'image/png', 'image/webp')),
  CONSTRAINT images_byte_size_positive CHECK (byte_size IS NULL OR byte_size > 0),
  CONSTRAINT images_dimensions_positive CHECK (width_px > 0 AND height_px > 0),
  CONSTRAINT images_row_version_positive CHECK (row_version > 0)
);

CREATE TABLE public.paints (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  stable_id text NOT NULL UNIQUE,
  owner_id bigint NOT NULL REFERENCES public.app_users(id) ON DELETE RESTRICT,
  name text NOT NULL,
  brand text,
  color_hex text NOT NULL,
  color_family text,
  medium text NOT NULL,
  opacity text,
  is_in_stock boolean NOT NULL DEFAULT true,
  notes text,
  search_document tsvector GENERATED ALWAYS AS (
    to_tsvector('simple', coalesce(name, '') || ' ' || coalesce(brand, '') || ' ' || coalesce(color_family, ''))
  ) STORED,
  created_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  updated_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  updated_by text NOT NULL,
  row_version bigint NOT NULL DEFAULT 1,
  archived_at timestamptz,
  CONSTRAINT paints_stable_id_nonblank CHECK (btrim(stable_id) <> ''),
  CONSTRAINT paints_name_nonblank CHECK (btrim(name) <> ''),
  CONSTRAINT paints_brand_nonblank CHECK (brand IS NULL OR btrim(brand) <> ''),
  CONSTRAINT paints_color_hex_format CHECK (color_hex ~ '^#[0-9A-F]{6}$'),
  CONSTRAINT paints_medium_allowed CHECK (medium IN ('oil', 'acrylic', 'watercolor', 'gouache', 'other')),
  CONSTRAINT paints_opacity_allowed CHECK (opacity IS NULL OR opacity IN ('opaque', 'semi_opaque', 'semi_transparent', 'transparent', 'unknown')),
  CONSTRAINT paints_row_version_positive CHECK (row_version > 0)
);

CREATE INDEX paints_owner_active_idx ON public.paints (owner_id) WHERE archived_at IS NULL;
CREATE INDEX paints_search_document_idx ON public.paints USING gin (search_document);
CREATE INDEX paints_name_trgm_idx ON public.paints USING gin (name gin_trgm_ops);

CREATE TABLE public.palettes (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  stable_id text NOT NULL UNIQUE,
  owner_id bigint NOT NULL REFERENCES public.app_users(id) ON DELETE RESTRICT,
  source_image_id bigint REFERENCES public.images(id) ON DELETE SET NULL,
  name text NOT NULL,
  description text,
  created_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  updated_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  updated_by text NOT NULL,
  row_version bigint NOT NULL DEFAULT 1,
  archived_at timestamptz,
  CONSTRAINT palettes_stable_id_nonblank CHECK (btrim(stable_id) <> ''),
  CONSTRAINT palettes_name_nonblank CHECK (btrim(name) <> ''),
  CONSTRAINT palettes_row_version_positive CHECK (row_version > 0)
);

CREATE INDEX palettes_owner_active_idx ON public.palettes (owner_id) WHERE archived_at IS NULL;

CREATE TABLE public.palette_items (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  palette_id bigint NOT NULL REFERENCES public.palettes(id) ON DELETE CASCADE,
  paint_id bigint REFERENCES public.paints(id) ON DELETE SET NULL,
  color_hex text NOT NULL,
  color_name text,
  coverage_percent numeric(5,2),
  position smallint NOT NULL,
  created_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  CONSTRAINT palette_items_color_hex_format CHECK (color_hex ~ '^#[0-9A-F]{6}$'),
  CONSTRAINT palette_items_coverage_range CHECK (coverage_percent IS NULL OR (coverage_percent >= 0 AND coverage_percent <= 100)),
  CONSTRAINT palette_items_position_nonnegative CHECK (position >= 0),
  CONSTRAINT palette_items_palette_position_unique UNIQUE (palette_id, position)
);

CREATE TABLE public.mix_recipes (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  stable_id text NOT NULL UNIQUE,
  owner_id bigint NOT NULL REFERENCES public.app_users(id) ON DELETE RESTRICT,
  source_palette_item_id bigint REFERENCES public.palette_items(id) ON DELETE SET NULL,
  target_hex text NOT NULL,
  result_hex text,
  delta_e numeric(10,4),
  algorithm_version text NOT NULL,
  note text,
  created_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  updated_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  updated_by text NOT NULL,
  row_version bigint NOT NULL DEFAULT 1,
  archived_at timestamptz,
  CONSTRAINT mix_recipes_stable_id_nonblank CHECK (btrim(stable_id) <> ''),
  CONSTRAINT mix_recipes_target_hex_format CHECK (target_hex ~ '^#[0-9A-F]{6}$'),
  CONSTRAINT mix_recipes_result_hex_format CHECK (result_hex IS NULL OR result_hex ~ '^#[0-9A-F]{6}$'),
  CONSTRAINT mix_recipes_delta_e_nonnegative CHECK (delta_e IS NULL OR delta_e >= 0),
  CONSTRAINT mix_recipes_algorithm_version_nonblank CHECK (btrim(algorithm_version) <> ''),
  CONSTRAINT mix_recipes_row_version_positive CHECK (row_version > 0)
);

CREATE INDEX mix_recipes_owner_active_idx ON public.mix_recipes (owner_id) WHERE archived_at IS NULL;

CREATE TABLE public.mix_recipe_components (
  recipe_id bigint NOT NULL REFERENCES public.mix_recipes(id) ON DELETE CASCADE,
  paint_id bigint NOT NULL REFERENCES public.paints(id) ON DELETE RESTRICT,
  proportion_basis_points integer NOT NULL,
  position smallint NOT NULL,
  PRIMARY KEY (recipe_id, paint_id),
  CONSTRAINT mix_recipe_components_proportion_range CHECK (proportion_basis_points > 0 AND proportion_basis_points <= 10000),
  CONSTRAINT mix_recipe_components_position_nonnegative CHECK (position >= 0),
  CONSTRAINT mix_recipe_components_recipe_position_unique UNIQUE (recipe_id, position)
);

CREATE TABLE public.mix_recipe_events (
  event_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_request_id uuid NOT NULL UNIQUE,
  recipe_id bigint REFERENCES public.mix_recipes(id) ON DELETE RESTRICT,
  event_type text NOT NULL,
  target_event_id uuid REFERENCES public.mix_recipe_events(event_id) ON DELETE RESTRICT,
  occurred_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  actor text NOT NULL,
  algorithm_version text NOT NULL,
  CONSTRAINT mix_recipe_events_type_allowed CHECK (event_type IN ('saved', 'void')),
  CONSTRAINT mix_recipe_events_shape CHECK (
    (event_type = 'saved' AND recipe_id IS NOT NULL AND target_event_id IS NULL)
    OR (event_type = 'void' AND recipe_id IS NULL AND target_event_id IS NOT NULL)
  ),
  CONSTRAINT mix_recipe_events_actor_nonblank CHECK (btrim(actor) <> ''),
  CONSTRAINT mix_recipe_events_algorithm_version_nonblank CHECK (btrim(algorithm_version) <> '')
);

CREATE OR REPLACE FUNCTION public.prevent_mix_recipe_event_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  RAISE EXCEPTION 'mix_recipe_events is append-only';
END;
$$;

CREATE TRIGGER mix_recipe_events_immutable
BEFORE UPDATE OR DELETE ON public.mix_recipe_events
FOR EACH ROW EXECUTE FUNCTION public.prevent_mix_recipe_event_mutation();

CREATE TABLE public.import_runs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_name text NOT NULL,
  source_sha256 text,
  transform_version text NOT NULL,
  started_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  completed_at timestamptz,
  actor text NOT NULL,
  status text NOT NULL,
  CONSTRAINT import_runs_source_name_nonblank CHECK (btrim(source_name) <> ''),
  CONSTRAINT import_runs_sha256_format CHECK (source_sha256 IS NULL OR source_sha256 ~ '^[0-9a-f]{64}$'),
  CONSTRAINT import_runs_transform_version_nonblank CHECK (btrim(transform_version) <> ''),
  CONSTRAINT import_runs_actor_nonblank CHECK (btrim(actor) <> ''),
  CONSTRAINT import_runs_status_allowed CHECK (status IN ('running', 'completed', 'failed')),
  CONSTRAINT import_runs_completed_after_start CHECK (completed_at IS NULL OR completed_at >= started_at)
);

CREATE TABLE public.import_rows (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  import_run_id uuid NOT NULL REFERENCES public.import_runs(id) ON DELETE CASCADE,
  source_row_key text NOT NULL,
  entity_type text NOT NULL,
  entity_stable_id text,
  raw_payload jsonb NOT NULL,
  accepted_at timestamptz,
  CONSTRAINT import_rows_source_row_key_nonblank CHECK (btrim(source_row_key) <> ''),
  CONSTRAINT import_rows_entity_type_nonblank CHECK (btrim(entity_type) <> ''),
  CONSTRAINT import_rows_unique_source UNIQUE (import_run_id, source_row_key)
);

CREATE TABLE public.import_issues (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  import_run_id uuid NOT NULL REFERENCES public.import_runs(id) ON DELETE CASCADE,
  import_row_id bigint REFERENCES public.import_rows(id) ON DELETE SET NULL,
  severity text NOT NULL,
  field_name text,
  code text NOT NULL,
  message text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT transaction_timestamp(),
  CONSTRAINT import_issues_severity_allowed CHECK (severity IN ('warning', 'error')),
  CONSTRAINT import_issues_code_nonblank CHECK (btrim(code) <> ''),
  CONSTRAINT import_issues_message_nonblank CHECK (btrim(message) <> '')
);

CREATE TABLE public.field_provenance (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  entity_type text NOT NULL,
  entity_stable_id text NOT NULL,
  field_name text NOT NULL,
  origin text NOT NULL,
  actor text,
  provider text,
  model text,
  prompt_version text,
  source_reference text,
  produced_at timestamptz,
  reviewed_by text,
  reviewed_at timestamptz,
  import_run_id uuid REFERENCES public.import_runs(id) ON DELETE SET NULL,
  value_sha256 text NOT NULL,
  CONSTRAINT field_provenance_entity_type_nonblank CHECK (btrim(entity_type) <> ''),
  CONSTRAINT field_provenance_entity_stable_id_nonblank CHECK (btrim(entity_stable_id) <> ''),
  CONSTRAINT field_provenance_field_name_nonblank CHECK (btrim(field_name) <> ''),
  CONSTRAINT field_provenance_origin_allowed CHECK (origin IN ('user', 'ai', 'external', 'unknown')),
  CONSTRAINT field_provenance_sha256_format CHECK (value_sha256 ~ '^[0-9a-f]{64}$'),
  CONSTRAINT field_provenance_current_field_unique UNIQUE (entity_type, entity_stable_id, field_name)
);

CREATE TRIGGER app_users_touch_lifecycle
BEFORE UPDATE ON public.app_users
FOR EACH ROW EXECUTE FUNCTION public.touch_lifecycle_fields();
CREATE TRIGGER canvas_sizes_touch_lifecycle
BEFORE UPDATE ON public.canvas_sizes
FOR EACH ROW EXECUTE FUNCTION public.touch_lifecycle_fields();
CREATE TRIGGER images_touch_lifecycle
BEFORE UPDATE ON public.images
FOR EACH ROW EXECUTE FUNCTION public.touch_lifecycle_fields();
CREATE TRIGGER paints_touch_lifecycle
BEFORE UPDATE ON public.paints
FOR EACH ROW EXECUTE FUNCTION public.touch_lifecycle_fields();
CREATE TRIGGER palettes_touch_lifecycle
BEFORE UPDATE ON public.palettes
FOR EACH ROW EXECUTE FUNCTION public.touch_lifecycle_fields();
CREATE TRIGGER mix_recipes_touch_lifecycle
BEFORE UPDATE ON public.mix_recipes
FOR EACH ROW EXECUTE FUNCTION public.touch_lifecycle_fields();

COMMIT;
