BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "sorvete_idempotency_cache" (
    "id" bigserial PRIMARY KEY,
    "key" text NOT NULL,
    "value" text,
    "storedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "sorvete_idempotency_key_idx" ON "sorvete_idempotency_cache" USING btree ("key");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "sorvete_outbox" (
    "id" bigserial PRIMARY KEY,
    "eventId" text NOT NULL,
    "type" text NOT NULL,
    "aggregateId" text NOT NULL,
    "occurredAt" timestamp without time zone NOT NULL,
    "payload" text NOT NULL,
    "publishedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "sorvete_outbox_event_id_idx" ON "sorvete_outbox" USING btree ("eventId");
CREATE INDEX "sorvete_outbox_published_at_idx" ON "sorvete_outbox" USING btree ("publishedAt");


--
-- MIGRATION VERSION FOR identity
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('identity', '20260609104442315', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260609104442315', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260213194423028', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260213194423028', "timestamp" = now();

--
-- MIGRATION VERSION FOR sorvete_server_kit
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('sorvete_server_kit', '20260609104015503', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260609104015503', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260129181112269', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181112269', "timestamp" = now();


COMMIT;
