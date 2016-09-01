SET SEARCH_PATH = biologging, public;

DROP SCHEMA IF EXISTS biologging CASCADE;
CREATE SCHEMA biologging AUTHORIZATION biologging;

-----------------------------------
-- Metadata tables
CREATE TABLE datacenter 
(
  id bigint NOT NULL,
  manager_id bigint NOT NULL,
  title character varying(255) NOT NULL,
  summary character varying(255) NOT NULL,
  citation character varying(255) NOT NULL,
  infoURL character varying(255) NOT NULL,
  license character varying(255) NOT NULL,
  distribution_statement character varying(255) NOT NULL,
  date_modified timestamp with time zone NOT NULL, -- time assigned to the last modified date (UTC) in the following format "YYYY-MM-DD hh:mm:ss"
  CONSTRAINT datacenter_pkey PRIMARY KEY (id),
  CONSTRAINT datacenter_name_key UNIQUE (title)
);

CREATE TABLE project
(
  id bigint NOT NULL,
  datacenter_id bigint, -- not compulsory as otherwise not possible for people to contribute without having their data in a data centre first.
  title character varying(255) NOT NULL,
  summary character varying(255) NOT NULL,
  citation character varying(255) NOT NULL,
  infoURL character varying(255),
  publications character varying(255),
  license character varying(255),
  distribution_statement character varying(255),
  date_modified timestamp with time zone NOT NULL, -- time assigned to the last modified date (UTC) in the following format "YYYY-MM-DD hh:mm:ss"
  location geometry NOT NULL,
  timestamp_start timestamp with time zone NOT NULL, -- time assigned to the project start date (UTC) in the following format "YYYY-MM-DD hh:mm:ss"
  timestamp_end timestamp with time zone NOT NULL, -- time assigned to the project end date (UTC) in the following format "YYYY-MM-DD hh:mm:ss"
  CONSTRAINT project_pkey PRIMARY KEY (id),
  CONSTRAINT project_name_key UNIQUE (title),
  CONSTRAINT project_fkey_datacenter FOREIGN KEY (datacenter_id)
      REFERENCES datacenter (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE users
(
  id bigint NOT NULL,
  organisation_name character varying(255) NOT NULL,
  name character varying(255) NOT NULL,
  email_address character varying(255) NOT NULL,
  department character varying(255) NOT NULL,
  phone_number character varying(20) NOT NULL,
  postal_address character varying(255) NOT NULL,
  CONSTRAINT users_pkey PRIMARY KEY (id),
  CONSTRAINT users_name_key UNIQUE (name, email_address)
);

ALTER TABLE datacenter 	ADD CONSTRAINT datacenter_fkey_manager FOREIGN KEY (manager_id)
      REFERENCES users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

CREATE TABLE project_role
(
  id bigint NOT NULL,
  user_id bigint NOT NULL,
  project_id bigint NOT NULL,
  role_type character varying NOT NULL,
  CONSTRAINT project_role_pkey PRIMARY KEY (id),
  CONSTRAINT project_role_fkey_project FOREIGN KEY (project_id)
      REFERENCES project (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT project_role_fkey_users FOREIGN KEY (user_id)
      REFERENCES users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT project_role_types CHECK (role_type = 'Principal Investigator' OR role_type = 'Co-Investigator' OR role_type = 'Research Assistant' OR role_type = 'Technical Assistant' OR role_type = 'Administrator' OR role_type = 'Student')
);

CREATE TABLE device
(
  id bigint NOT NULL,
  device_name character varying(255) NOT NULL, -- if acoustic tag then force device_name = (code_map || '-' || ping_code)
  project_id bigint NOT NULL,
  device_type character varying(255) NOT NULL, -- archival, pop-up, acoustic, or satellite tag
  manufacturer character varying(255) NOT NULL,
  model_name character varying(255) NOT NULL, -- Needs constraints to restrict the range of possibilities (see example for acoustic receivers in device_models constraint)
  serial_number character varying(255) NOT NULL, -- Body serial number
  code_map character varying(255), -- for acoustic tags only
  ping_code integer, -- for acoustic tags only
  ptt character varying(255), -- only applies to satellite tags
  device_wmo_ref character varying(255), -- only applies to satellite tags
  infoURL character varying(255) NOT NULL, -- Link to model on the manufacturer website
    CONSTRAINT device_pkey PRIMARY KEY (id),
    CONSTRAINT device_fkey_project FOREIGN KEY (project_id)
      REFERENCES project (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT device_unique UNIQUE (manufacturer, model_name, serial_number), 
    CONSTRAINT device_types CHECK (device_type = 'Archival tag' OR device_type = 'Pop-up satellite archival tag' OR device_type = 'Satellite tag' OR device_type = 'Acoustic tag' OR device_type = 'Acoustic receiver'),
    CONSTRAINT device_models CHECK (model_name = 'VR2' OR model_name = 'VR2W' OR model_name = 'VR3-UWM' OR model_name = 'VR3UWM' OR model_name = 'VR4' OR model_name = 'VR4UWM' OR model_name = 'VR4-UWM' OR model_name = 'VR2AR' OR model_name = 'VR2C29'),
    CONSTRAINT code_map_check CHECK ((device_type = 'Acoustic tag' AND code_map IS NOT NULL AND ping_code IS NOT NULL) OR (device_type != 'Acoustic tag' AND code_map IS NULL AND ping_code IS NULL))
);

CREATE TABLE instruments
( 
  id bigint NOT NULL,
  device_id bigint NOT NULL, -- FK to device.id
  firmware_version character varying(255), -- Version number of the firmware used to build the tag
  software_version character varying(255), -- Version number of the software used for the tag
  configuration_parameters character varying(255) NOT NULL, -- Parameter settings used to configure the tag for deployment; could also provide users with the possibility to upload a text file of specifications.
  pressure boolean NOT NULL,
  temperature boolean NOT NULL,
  light boolean NOT NULL,
  conductivity boolean NOT NULL,
  fluorescence boolean NOT NULL,
  accelerometer_3d boolean NOT NULL,
  magnetometer_3d boolean NOT NULL,
  stomach_temperature boolean NOT NULL,
  argos_location boolean NOT NULL,
  gps_location boolean NOT NULL,
  geolocation boolean NOT NULL,
  geolocation_data_processing character varying(255), -- If geolocation = TRUE then specify which algorithm was used to process GLS raw data
  pinger boolean NOT NULL, -- for acoustic tags only
  range_test boolean NOT NULL, -- for acoustic tags only
  intercept real, -- for acoustic tag sensors only
  slope real, -- for acoustic tag sensors only
  unit character varying(255), -- for acoustic tag sensors only, implement constraints based on sensor type (i.e. if temperature = true then unit = '°C', pressure = true then unit = 'm', accelerometer then unit = 'm.s-2')
    CONSTRAINT instruments_pkey PRIMARY KEY (id),
    CONSTRAINT instruments_fkey_device FOREIGN KEY (device_id)
      REFERENCES device (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT instrument_geolocation_processing CHECK ((geolocation = FALSE AND geolocation_data_processing IS NULL) OR (geolocation = TRUE AND geolocation_data_processing IS NOT NULL))
);

CREATE TABLE species -- Table greatly simplified, needs to conform to an existing standard (e.g. WoRMS)
(
  id bigint NOT NULL,
  "worms_aphiaID" character varying NOT NULL, -- WoRMS Aphia ID.
  kingdom character varying(255) NOT NULL,
  phylum character varying(255) NOT NULL,
  class_name character varying(255) NOT NULL,
  order_name character varying(255) NOT NULL,
  family character varying(255) NOT NULL,
  genus character varying(255) NOT NULL,
  subgenus character varying (255),
  "specificEpithet" character varying (255) NOT NULL, -- Name of the first or species epithet of the scientificName
  "infraspecificEpithet" character varying (255) NOT NULL, -- Name of the lowest or terminal infraspecific epithet of the scientificName, excluding any rank designation
  "scientificName" character varying(255) NOT NULL, -- Full scientific name, with authorship and date information if known
  "acceptedNameUsage" character varying(255) NOT NULL, -- Full name, with authorship and date information if known, of the currently valid (zoological) or accepted (botanical) taxon.
  "vernacularName" character varying(255) NOT NULL, -- Common or vernacular name
  "scientificNameAuthorship" character varying(255) NOT NULL, -- Authorship information for the scientificName
  date_modified timestamp with time zone NOT NULL, -- time assigned to the last modified date (UTC) in the following format "YYYY-MM-DD hh:mm:ss"
  CONSTRAINT species_pkey PRIMARY KEY (id)
);

CREATE TABLE animal
(
  id bigint NOT NULL,
  unique_id character varying (255) NOT NULL, -- Unique identifier for each animal (e.g. numbered tag, band, transponder)
  species_id bigint NOT NULL,
  sex character varying(7) NOT NULL,
  "lifeStage" character varying(255) NOT NULL, -- e.g. adult, juvenile, subadult, weaner
  "ageUnit" character varying(20), -- e.g. days, months, years
  value real,
  estimate boolean,
  comments character varying(255), --  e.g. animal origin (i.e. wild, hatchery), stock, injuries
  CONSTRAINT animal_pkey PRIMARY KEY (id),
  CONSTRAINT animal_fkey_species FOREIGN KEY (species_id)
      REFERENCES species (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT animal_sex_types CHECK (sex = 'Female' OR sex = 'Male' OR sex = 'Unknown'),
  CONSTRAINT animal_life_stage_types CHECK ("lifeStage" = 'Adult' OR "lifeStage" = 'Juvenile' OR "lifeStage" = 'Subadult'),
  CONSTRAINT animal_unit_types CHECK ("ageUnit" = 'Days' OR "ageUnit" = 'Months' OR "ageUnit" = 'Years' OR "ageUnit" IS NULL)
);

CREATE TABLE animal_release_recovery -- Previously named tag_deployment, links between surgery and animal table
(
  id bigint NOT NULL,
  animal_id bigint NOT NULL,
  tagger_id bigint NOT NULL, -- FK to users.id
  animal_capture_locality character varying(255),
  animal_capture_location geometry,
  animal_capture_datetime timestamp with time zone, -- time assigned to animal capture (UTC) in the following format "YYYY-MM-DD hh:mm:ss"
  deployment_locality character varying(255) NOT NULL,
  deployment_location geometry NOT NULL,
  deployment_datetime timestamp with time zone NOT NULL, -- time assigned to tag deployment (UTC) in the following format "YYYY-MM-DD hh:mm:ss"
  deployment_comments character varying(255), -- Describe whether any samples were taken during tag deployment (e.g. DNA, blubber, blood)
  recoverer_id bigint, -- FK to users.id
  recovery_locality character varying(255),
  recovery_location geometry,
  recovery_datetime timestamp with time zone, -- time assigned to tag recovery (UTC) in the following format "YYYY-MM-DD hh:mm:ss"
  recovery_comments character varying(255), -- e.g. Damage on tags, tag still operational, tag sent back to manufacturer for refurbishing, samples taken during tag recovery
    CONSTRAINT animal_release_recovery_pkey PRIMARY KEY (id),
    CONSTRAINT tag_deployment_fkey_tagger FOREIGN KEY (tagger_id)
      REFERENCES users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT tag_deployment_fkey_animal FOREIGN KEY (animal_id)
      REFERENCES animal (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT tag_recovery_fkey_tagger FOREIGN KEY (recoverer_id)
      REFERENCES users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT tag_recovery_check CHECK ((recoverer_id IS NULL AND recovery_location IS NULL AND recovery_datetime IS NULL) OR (recoverer_id IS NOT NULL AND recovery_location IS NOT NULL AND recovery_datetime IS NOT NULL))
);


CREATE TABLE surgery -- Allows for multiple deployments of devices
(
  id bigint NOT NULL,
  device_id bigint NOT NULL, -- FK to device.id
  release_id bigint NOT NULL, -- FK to animal_release_recovery.id
  attachment_method character varying(255) NOT NULL, -- Needs constraints to restrict the range of possibilities
  attachment_details character varying(255), -- Provide any other additional information regarding the attachment (location of tag on animal, wedges)
      CONSTRAINT surgery_pkey PRIMARY KEY (id),
    CONSTRAINT surgery_fkey_device FOREIGN KEY (device_id)
      REFERENCES device (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT surgery_fkey_animal_release_recovery FOREIGN KEY (release_id)
      REFERENCES animal_release_recovery (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE animal_measurement
(
  id bigint NOT NULL,
  animal_id bigint NOT NULL,
  type character varying(255) NOT NULL, -- e.g. length, weight, total length, carapace length, carapace width, fork length, width
  unit character varying(20) NOT NULL, -- e.g. mm, cm, m, g, kg
  value real NOT NULL,
  estimate boolean NOT NULL,
  comments character varying(255),
  CONSTRAINT animal_measurement_pkey PRIMARY KEY (id),
  CONSTRAINT animal_measurement_fkey_animal FOREIGN KEY (animal_id)
      REFERENCES animal (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE installation_station
(
  id bigint NOT NULL,
  project_id bigint NOT NULL,
  installation_name character varying(255) NOT NULL,
  station_name character varying(255) NOT NULL,
  station_location geometry NOT NULL,
    CONSTRAINT installation_station_pkey PRIMARY KEY (id),
    CONSTRAINT installation_station_name_key UNIQUE (installation_name, station_name),
    CONSTRAINT installation_name_key UNIQUE (installation_name), 
    CONSTRAINT installation_station_fkey_project FOREIGN KEY (project_id)
      REFERENCES project (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE receiver_deployment_recovery
(
  id bigint NOT NULL,
  receiver_id bigint NOT NULL,
  installation_station_id bigint NOT NULL,
  bottom_depthm real,
  comments text,
  deployer_id bigint, -- FK to users.id
  initialisation_datetime timestamp with time zone, -- initialisation time (UTC) in the following format "YYYY-MM-DD hh:mm:ss"
  deployment_datetime timestamp with time zone NOT NULL, -- deployment time (UTC) in the following format "YYYY-MM-DD hh:mm:ss"
  depth_below_surfacem real,
  mooring_descriptor character varying(255),
  mooring_type character varying(10), -- constraint: fixed or floating
  receiver_orientation character varying(255), -- constraint: up, down, or sideways
  deployment_location geometry NOT NULL,
  recoverer_id bigint, -- FK to users.id
  recovery_datetime timestamp with time zone, -- recovery time (UTC) in the following format "YYYY-MM-DD hh:mm:ss"
  recovery_location geometry,
  recovery_status character varying(255), -- constraint: retired, damaged, stolen, recovered, lost, or returned to vendor
    CONSTRAINT receiver_deployment_recovery_pkey PRIMARY KEY (receiver_id, installation_station_id, deployment_datetime),
    CONSTRAINT receiver_deployment_recovery_fkey_receiver FOREIGN KEY (receiver_id)
      REFERENCES device (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT receiver_deployment_recovery_fkey_installation_station FOREIGN KEY (installation_station_id)
      REFERENCES installation_station (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT receiver_deployment_recovery_fkey_deployer FOREIGN KEY (deployer_id)
      REFERENCES users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT receiver_deployment_recovery_fkey_recoverer FOREIGN KEY (recoverer_id)
      REFERENCES users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT mooring_types CHECK (mooring_type = 'Fixed' OR mooring_type = 'Floating'),
    CONSTRAINT receiver_orientations CHECK (receiver_orientation = 'Up' OR receiver_orientation = 'Down' OR receiver_orientation = 'Sideways'),
    CONSTRAINT recovery_statuses CHECK (recovery_status = 'Retired' OR recovery_status = 'Damaged' OR recovery_status = 'Stolen' OR recovery_status = 'Recovered' OR recovery_status = 'Lost' OR recovery_status = 'Returned to vendor'),
    CONSTRAINT tag_recovery_check CHECK ((recoverer_id IS NULL AND recovery_location IS NULL AND recovery_datetime IS NULL AND recovery_status IS NULL) OR (recoverer_id IS NOT NULL AND recovery_location IS NOT NULL AND recovery_datetime IS NOT NULL AND recovery_status IS NOT NULL))
);

-----------------------------------
-- Monitoring tables
CREATE TABLE activity_log
(
  id bigint NOT NULL,
  user_id bigint NOT NULL,
  class_name character varying(255) NOT NULL, -- table that was modified
  property_name character varying(255) NOT NULL, -- column that was modified
  persisted_object_id character varying(255) NOT NULL, -- row that was modified
  event_type character varying(255) NOT NULL, -- delete, insert or update constraints needed
  modification_datetime timestamp with time zone NOT NULL, -- modification time (UTC) in the following format "YYYY-MM-DD hh:mm:ss"
  new_value character varying(255),
  old_value character varying(255),
  CONSTRAINT activity_log_pkey PRIMARY KEY (id),
  CONSTRAINT activity_log_fkey_users FOREIGN KEY (user_id)
      REFERENCES users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT event_types CHECK (event_type = 'Delete' OR event_type = 'Insert' OR event_type = 'Update')
);

CREATE TABLE uploaded_file
(
  id bigint NOT NULL,
  user_id bigint NOT NULL,
  file_type character varying(255) NOT NULL, -- e.g. detections, gps, gls, argos
  file_name character varying(255) NOT NULL, -- Could also extract file size, MD5sum, other properties?
  upload_datetime timestamp with time zone NOT NULL, -- file upload time (UTC) in the following format "YYYY-MM-DD hh:mm:ss"
  status character varying(255) NOT NULL, -- i.e. processed, processing, error
  err_msg text NOT NULL, -- This implies that checkers will be implemented and that standard file formats are expected from users
  CONSTRAINT uploaded_file_pkey PRIMARY KEY (id),
  CONSTRAINT uploaded_file_fkey_users FOREIGN KEY (user_id)
      REFERENCES users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT file_types CHECK (file_type = 'Acoustic detections' OR file_type = 'GPS locations' OR file_type = 'Argos locations' OR file_type = 'GLS locations'),
  CONSTRAINT statuses CHECK (status = 'Processed' OR status = 'Processing' OR status = 'Error')
);

-----------------------------------
-- Data tables

-- Location data, constraints on time and spatial coordinates hard coded into each table.

CREATE TABLE gps_locations
(
  id serial NOT NULL, -- self-generated by database during data import
  file_id bigint NOT NULL,
  device_name character varying(255) NOT NULL,
  "timestamp" timestamp with time zone NOT NULL, -- time assigned to the location (UTC) in the following format "YYYY-MM-DD hh:mm:ss"
  "decimalLatitude" double precision NOT NULL, -- In decimal format and degree North, 
  "decimalLongitude" double precision NOT NULL, -- In decimal format and degree East.
  nsats_detected double precision,
  nsats_transmitted double precision,
  pseudoranges character varying (255),
  max_csn double precision,
  residual double precision,
  timeshift double precision,
  duplicate boolean,
    CONSTRAINT gps_locations_pkey PRIMARY KEY (id),
      CONSTRAINT gps_locations_fkey_uploaded_file FOREIGN KEY (file_id)
      REFERENCES uploaded_file (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
      CONSTRAINT gps_locations_latitude CHECK ("decimalLatitude" < 90 AND "decimalLatitude" > (-90)),
      CONSTRAINT gps_locations_longitude CHECK ("decimalLongitude" < 180 AND "decimalLongitude" > (-180)),
      CONSTRAINT gps_locations_time CHECK (timestamp < now())
);

CREATE TABLE argos_locations
(
  id serial NOT NULL, -- self-generated by database during data import
  file_id bigint NOT NULL,
  device_name character varying(255) NOT NULL,
  "timestamp" timestamp with time zone NOT NULL, -- time assigned to the location (UTC) in the following format "YYYY-MM-DD hh:mm:ss", e.g. "2009-08-05 21:19:52"
  "decimalLatitude" double precision NOT NULL, -- In decimal format and degree North.
  "decimalLongitude" double precision NOT NULL, -- In decimal format and degree East.
  location_quality character varying (2) NOT NULL, -- Location Quality assigned by Argos (-1 = class A, -2 = class B, 9 = class Z)
  alt_latitude double precision, -- Alternative solution to position equations, in decimal format and degree North.
  alt_longitude double precision, -- Alternative solution to position equations, in decimal format and degree East.
  n_mess double precision, -- Number of uplinks received during the satellite pass
  n_mess_120 double precision, -- Number of uplinks received with signal strength > -120 dB
  best_level double precision, -- Signal strength of strongest uplink (dB)
  pass_dur double precision, -- Duration of satellite overpass (seconds)
  freq double precision, -- Measured frequency of SRDL signal at the satellite (Hz)
  duplicate boolean,
    CONSTRAINT argos_locations_pkey PRIMARY KEY (id),
      CONSTRAINT argos_locations_fkey_uploaded_file FOREIGN KEY (file_id)
      REFERENCES uploaded_file (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
      CONSTRAINT argos_locations_latitude CHECK ("decimalLatitude" < 90 AND "decimalLatitude" > (-90)),
      CONSTRAINT argos_locations_longitude CHECK ("decimalLongitude" < 180 AND "decimalLongitude" > (-180)),
      CONSTRAINT argos_locations_time CHECK (timestamp < now())
);

CREATE TABLE gls_locations
(
  id serial NOT NULL, -- self-generated by database during data import
  file_id bigint NOT NULL,
  device_name character varying(255)NOT NULL,
  "timestamp" timestamp with time zone NOT NULL, -- time assigned to the location (UTC) in the following format "YYYY-MM-DD hh:mm:ss"
  "decimalLatitude" double precision NOT NULL, -- In decimal format and degree North.
  "decimalLongitude" double precision NOT NULL, -- In decimal format and degree East.
  duplicate boolean,
    CONSTRAINT gls_locations_pkey PRIMARY KEY (id),
      CONSTRAINT gls_locations_fkey_uploaded_file FOREIGN KEY (file_id)
      REFERENCES uploaded_file (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
      CONSTRAINT gls_locations_latitude CHECK ("decimalLatitude" < 90 AND "decimalLatitude" > (-90)),
      CONSTRAINT gls_locations_longitude CHECK ("decimalLongitude" < 180 AND "decimalLongitude" > (-180)),
      CONSTRAINT gls_locations_time CHECK (timestamp < now())
);

CREATE TABLE acoustic_detections
(
  id serial NOT NULL, -- self-generated by database during data import
  file_id bigint NOT NULL,
  receiver_name character varying(255) NOT NULL,
  transmitter_id character varying(255) NOT NULL,
  "timestamp" timestamp with time zone NOT NULL, -- time assigned to the location (UTC) in the following format "YYYY-MM-DD hh:mm:ss
  sensor_value real,
  sensor_unit character varying(255),
  duplicate boolean,
  CONSTRAINT acoustic_detections_pkey PRIMARY KEY (id),
  CONSTRAINT acoustic_detections_fkey_uploaded_file FOREIGN KEY (file_id)
      REFERENCES uploaded_file (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

-----------------------------------
-- Functions to check for duplicates in all data tables
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
                  WHERE detection.id = subquery.id;

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
                  WHERE detection.id = subquery.id;

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
                  WHERE detection.id = subquery.id;

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