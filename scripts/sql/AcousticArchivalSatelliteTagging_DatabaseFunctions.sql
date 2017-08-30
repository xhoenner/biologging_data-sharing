-- Functions to check for duplicates in data tables
-- gps
CREATE OR REPLACE FUNCTION set_gps_locations_duplicate_status()
  RETURNS trigger AS
$BODY$

                DECLARE
                  changed_row biologging.gps_locations%ROWTYPE;

                BEGIN
                  IF (TG_OP = 'DELETE') THEN
                    changed_row = OLD;
                  ELSE
                    changed_row = NEW;
                  END IF;

                  UPDATE biologging.gps_locations
                  SET duplicate = subquery.duplicate
                  FROM (
                    SELECT id,
                    ROW_NUMBER() OVER(PARTITION BY timestamp, device_name ORDER BY id asc) > 1
                      AS duplicate
                    FROM biologging.gps_locations
                    WHERE timestamp = changed_row.timestamp
                      AND device_name = changed_row.device_name
                  ) subquery
                  WHERE gps_locations.id = subquery.id;

                  RETURN changed_row;
                END;

                $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE TRIGGER check_for_gps_locations_duplicates
  AFTER INSERT OR DELETE
  ON gps_locations
  FOR EACH ROW
  EXECUTE PROCEDURE set_gps_locations_duplicate_status();


-- argos
CREATE OR REPLACE FUNCTION set_argos_locations_duplicate_status()
  RETURNS trigger AS
$BODY$

                DECLARE
                  changed_row biologging.argos_locations%ROWTYPE;

                BEGIN
                  IF (TG_OP = 'DELETE') THEN
                    changed_row = OLD;
                  ELSE
                    changed_row = NEW;
                  END IF;

                  UPDATE biologging.argos_locations
                  SET duplicate = subquery.duplicate
                  FROM (
                    SELECT id,
                    ROW_NUMBER() OVER(PARTITION BY timestamp, device_ic ORDER BY id asc) > 1
                      AS duplicate
                    FROM biologging.argos_locations
                    WHERE timestamp = changed_row.timestamp
                      AND device_name = changed_row.device_name
                  ) subquery
                  WHERE argos_locations.id = subquery.id;

                  RETURN changed_row;
                END;

                $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE TRIGGER check_for_argos_locations_duplicates
  AFTER INSERT OR DELETE
  ON argos_locations
  FOR EACH ROW
  EXECUTE PROCEDURE set_argos_locations_duplicate_status();

-- gls
CREATE OR REPLACE FUNCTION set_gls_locations_duplicate_status()
  RETURNS trigger AS
$BODY$

                DECLARE
                  changed_row biologging.gls_locations%ROWTYPE;

                BEGIN
                  IF (TG_OP = 'DELETE') THEN
                    changed_row = OLD;
                  ELSE
                    changed_row = NEW;
                  END IF;

                  UPDATE biologging.gls_locations
                  SET duplicate = subquery.duplicate
                  FROM (
                    SELECT id,
                    ROW_NUMBER() OVER(PARTITION BY timestamp, device_name ORDER BY id asc) > 1
                      AS duplicate
                    FROM biologging.gls_locations
                    WHERE timestamp = changed_row.timestamp
                      AND device_name = changed_row.device_name
                  ) subquery
                  WHERE gls_locations.id = subquery.id;

                  RETURN changed_row;
                END;

                $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE TRIGGER check_for_gls_locations_duplicates
  AFTER INSERT OR DELETE
  ON gls_locations
  FOR EACH ROW
  EXECUTE PROCEDURE set_gls_locations_duplicate_status();

-- acoustic
CREATE OR REPLACE FUNCTION set_acoustic_detections_duplicate_status()
  RETURNS trigger AS
$BODY$

                DECLARE
                  changed_row biologging.acoustic_detections%ROWTYPE;

                BEGIN
                  IF (TG_OP = 'DELETE') THEN
                    changed_row = OLD;
                  ELSE
                    changed_row = NEW;
                  END IF;

                  UPDATE biologging.acoustic_detections
                  SET duplicate = subquery.duplicate
                  FROM (
                    SELECT id,
                    ROW_NUMBER() OVER(PARTITION BY timestamp, transmitter_id, receiver_name ORDER BY id asc) > 1
                      AS duplicate
                    FROM biologging.acoustic_detections
                    WHERE timestamp = changed_row.timestamp
                      AND transmitter_id = changed_row.transmitter_id
                      AND receiver_name = changed_row.receiver_name
                  ) subquery
                  WHERE acoustic_detections.id = subquery.id;

                  RETURN changed_row;
                END;

                $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE TRIGGER check_for_acoustic_detections_duplicates
  AFTER INSERT OR DELETE
  ON acoustic_detections
  FOR EACH ROW
  EXECUTE PROCEDURE set_acoustic_detections_duplicate_status();


-- platform
CREATE OR REPLACE FUNCTION set_platform_locations_duplicate_status()
  RETURNS trigger AS
$BODY$

                DECLARE
                  changed_row biologging.platform_locations%ROWTYPE;

                BEGIN
                  IF (TG_OP = 'DELETE') THEN
                    changed_row = OLD;
                  ELSE
                    changed_row = NEW;
                  END IF;

                  UPDATE biologging.platform_locations
                  SET duplicate = subquery.duplicate
                  FROM (
                    SELECT id,
                    ROW_NUMBER() OVER(PARTITION BY timestamp, platform_name ORDER BY id asc) > 1
                      AS duplicate
                    FROM biologging.platform_locations
                    WHERE timestamp = changed_row.timestamp
                      AND platform_name = changed_row.platform_name
                  ) subquery
                  WHERE platform_locations.id = subquery.id;

                  RETURN changed_row;
                END;

                $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE TRIGGER check_for_platform_locations_duplicates
  AFTER INSERT OR DELETE
  ON platform_locations
  FOR EACH ROW
  EXECUTE PROCEDURE set_platform_locations_duplicate_status();