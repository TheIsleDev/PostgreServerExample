\connect theisle

ALTER DATABASE theisle OWNER TO theisle;

SET ROLE theisle;

CREATE SCHEMA storage AUTHORIZATION theisle;
CREATE SCHEMA statistic AUTHORIZATION theisle;



GRANT CONNECT
ON DATABASE theisle TO storage_component;
GRANT USAGE
ON SCHEMA storage TO storage_component;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA storage TO storage_component;
GRANT USAGE, SELECT
ON ALL SEQUENCES IN SCHEMA storage TO storage_component;

ALTER DEFAULT PRIVILEGES IN SCHEMA storage GRANT SELECT, INSERT, UPDATE, DELETE
ON TABLES TO storage_component;
ALTER DEFAULT PRIVILEGES IN SCHEMA storage GRANT USAGE, SELECT
ON SEQUENCES TO storage_component;


GRANT CONNECT
ON DATABASE theisle TO statistic_component;
GRANT USAGE
ON SCHEMA statistic TO statistic_component;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA statistic TO statistic_component;
GRANT USAGE, SELECT
ON ALL SEQUENCES IN SCHEMA statistic TO statistic_component;

ALTER DEFAULT PRIVILEGES IN SCHEMA statistic GRANT SELECT, INSERT, UPDATE, DELETE
ON TABLES TO statistic_component;
ALTER DEFAULT PRIVILEGES IN SCHEMA statistic GRANT USAGE, SELECT
ON SEQUENCES TO statistic_component;

GRANT USAGE
ON SCHEMA storage TO statistic_component;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA storage TO statistic_component;
GRANT USAGE, SELECT
ON ALL SEQUENCES IN SCHEMA storage TO statistic_component;

ALTER DEFAULT PRIVILEGES IN SCHEMA storage GRANT SELECT, INSERT, UPDATE, DELETE
ON TABLES TO statistic_component;
ALTER DEFAULT PRIVILEGES IN SCHEMA storage GRANT USAGE, SELECT
ON SEQUENCES TO statistic_component;



CREATE TABLE IF NOT EXISTS storage."Dinosaurs" (
    DinoId    BIGINT NOT NULL,
    SaveData  TEXT    NOT NULL,
    Active    BOOL    NOT NULL DEFAULT false,
    Died      BOOL    NOT NULL DEFAULT false,
    PRIMARY KEY (DinoId)
);

CREATE TABLE IF NOT EXISTS storage."LogsDinosaursStorage" (
    Id        BIGSERIAL PRIMARY KEY,
    DinoId    BIGINT NOT NULL,
    Action    TEXT    NOT NULL,
    CreatedAt TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_logs_steamid_dinoid ON storage."LogsDinosaursStorage" (DinoId);


CREATE TABLE IF NOT EXISTS statistic."Dinosaurs" (
    Id        BIGSERIAL PRIMARY KEY,
    DinoId    BIGINT NOT NULL,
    Growth    FLOAT NOT NULL,
    health    FLOAT NOT NULL,
    Stamina   FLOAT NOT NULL,
    Hunger    FLOAT NOT NULL,
    Thirst    FLOAT NOT NULL,
    Oxygen    FLOAT NOT NULL,
    Blood     FLOAT NOT NULL,
    X         FLOAT NOT NULL,
    Y         FLOAT NOT NULL,
    Z         FLOAT NOT NULL,
    CreatedAt TIMESTAMPTZ NOT NULL DEFAULT now()
);


CREATE TABLE IF NOT EXISTS storage."GlobalIDs" (
    Id BIGSERIAL PRIMARY KEY,

    SteamId  BIGINT NOT NULL,
    DinoClass  TEXT NOT NULL,
    DinoId   BIGINT NOT NULL,

    UNIQUE(SteamId, DinoClass, DinoId)
);


CREATE OR REPLACE FUNCTION storage.resolve_dino(
    p_SteamId BIGINT,
    p_DinoClass TEXT,
    p_DinoId BIGINT
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    SELECT id
    INTO v_id
    FROM storage."GlobalIDs"
    WHERE SteamId = p_SteamId
        AND DinoClass = p_DinoClass
        AND DinoId = p_DinoId;

    IF FOUND THEN
        RETURN v_id;
    END IF;

    INSERT INTO storage."GlobalIDs"
        (SteamId, DinoClass, DinoId)
    VALUES
        (p_SteamId, p_DinoClass, p_DinoId)

    RETURNING id
    INTO v_id;

    RETURN v_id;
END;
$$;


RESET ROLE;