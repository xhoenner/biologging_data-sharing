SET SEARCH_PATH = biologging, public;

DROP SCHEMA IF EXISTS biologging CASCADE;
CREATE SCHEMA biologging AUTHORIZATION biologging;

-----------------------------------
-- Metadata tables

CREATE TABLE organisation
(
  id bigint NOT NULL,
  name character varying(255) NOT NULL,
  department character varying(255) NOT NULL,
  phone_number character varying(20) NOT NULL,
  postal_address character varying(255) NOT NULL,
  CONSTRAINT organisation_pkey PRIMARY KEY (id)
);

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
  CONSTRAINT datacenter_pkey PRIMARY KEY (id)
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
  CONSTRAINT project_datacenter_key UNIQUE (datacenter_id),
  CONSTRAINT project_fkey_datacenter FOREIGN KEY (datacenter_id)
      REFERENCES datacenter (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE users
(
  id bigint NOT NULL,
  organisation_id bigint,
  name character varying(255) NOT NULL,
  email_address character varying(255) NOT NULL,
  phone_number character varying(20),
  CONSTRAINT users_pkey PRIMARY KEY (id),
  CONSTRAINT users_fkey_org FOREIGN KEY (organisation_id)
      REFERENCES organisation (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
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
  tag_id character varying(255) NOT NULL,
  project_id bigint NOT NULL,
  device_type character varying(255) NOT NULL, -- archival, pop-up, or satellite tag
  manufacturer character varying(255) NOT NULL,
  model_name character varying(255) NOT NULL,
  serial_number character varying(255) NOT NULL, -- Body serial number
  ptt character varying(255),
  device_wmo_ref character varying(255),
  infoURL character varying(255) NOT NULL, -- Link to model on the manufacturer website
    CONSTRAINT device_pkey PRIMARY KEY (id),
    CONSTRAINT device_fkey_project FOREIGN KEY (project_id)
      REFERENCES project (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
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
  unit character varying(20), -- e.g. days, months, years
  value real,
  estimate boolean,
  comments character varying(255), --  e.g. animal origin (i.e. wild, hatchery), stock, injuries
  CONSTRAINT animal_pkey PRIMARY KEY (id),
  CONSTRAINT animal_fkey_species FOREIGN KEY (species_id)
      REFERENCES species (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT animal_sex_types CHECK (sex = 'Female' OR sex = 'Male' OR sex = 'Unknown'),
  CONSTRAINT animal_life_stage_types CHECK ("lifeStage" = 'Adult' OR "lifeStage" = 'Juvenile' OR "lifeStage" = 'Subadult'),
  CONSTRAINT animal_unit_types CHECK (unit = 'Days' OR unit = 'Months' OR unit = 'Years' OR unit IS NULL)
);

CREATE TABLE animal_release -- Previously named tag_deployment, links between surgery and animal table
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
    CONSTRAINT animal_release_pkey PRIMARY KEY (id),
    CONSTRAINT tag_deployment_fkey_tagger FOREIGN KEY (tagger_id)
      REFERENCES users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT tag_deployment_fkey_animal FOREIGN KEY (animal_id)
      REFERENCES animal (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT tag_recovery_fkey_tagger FOREIGN KEY (recoverer_id)
      REFERENCES users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);


CREATE TABLE surgery -- Allows for multiple deployments of devices
(
  id bigint NOT NULL,
  device_id bigint NOT NULL, -- FK to device.id
  release_id bigint NOT NULL, -- FK to animal_release.id
  attachment_method character varying(255) NOT NULL, -- Could be made a separate table so that users have a limited range of tagging attachment methods
  attachment_details character varying(255), -- Provide any other additional information regarding the attachment (exact location of tag on animal, wedges)
      CONSTRAINT surgery_pkey PRIMARY KEY (id),
    CONSTRAINT surgery_fkey_device FOREIGN KEY (device_id)
      REFERENCES device (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT surgery_fkey_animal_release FOREIGN KEY (release_id)
      REFERENCES animal_release (id) MATCH SIMPLE
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


-----------------------------------
-- Data tables

-- Location data, constraints on time and spatial coordinates hard coded into each table.

CREATE TABLE gps_locations
(
  measurement_id bigint NOT NULL,
  surgery_id bigint NOT NULL, 
  timestamp timestamp with time zone NOT NULL, -- time assigned to the location (UTC) in the following format "YYYY-MM-DD hh:mm:ss"
  latitude double precision NOT NULL, -- In decimal format and degree North.
  longitude double precision NOT NULL, -- In decimal format and degree East.
  nsats_detected double precision,
  nsats_transmitted double precision,
  pseudoranges character varying (255),
  max_csn double precision,
  residual double precision,
  timeshift double precision,
    CONSTRAINT gps_locations_pkey PRIMARY KEY (measurement_id),
      CONSTRAINT gps_locations_fkey_surgery FOREIGN KEY (surgery_id)
      REFERENCES surgery (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
      CONSTRAINT gps_locations_latitude CHECK (latitude < 90 AND latitude > (-90)),
      CONSTRAINT gps_locations_longitude CHECK (longitude < 180 AND longitude > (-180)),
      CONSTRAINT gps_locations_time CHECK (timestamp < now())
);

CREATE TABLE argos_locations
(
  measurement_id bigint NOT NULL,
  surgery_id bigint NOT NULL,
  timestamp timestamp with time zone NOT NULL, -- time assigned to the location (UTC) in the following format "YYYY-MM-DD hh:mm:ss", e.g. "2009-08-05 21:19:52"
  latitude double precision NOT NULL, -- Preferred longitude estimate (WGS 84 datum), in decimal format and degree North.
  longitude double precision NOT NULL, -- Preferred latitude estimate (WGS 84 datum), in decimal format and degree East.
  location_quality character varying (2) NOT NULL, -- Location Quality assigned by Argos (-1 = class A, -2 = class B, 9 = class Z)
  alt_latitude double precision, -- Alternative solution to position equations, in decimal format and degree North.
  alt_longitude double precision, -- Alternative solution to position equations, in decimal format and degree East.
  n_mess double precision, -- Number of uplinks received during the satellite pass
  n_mess_120 double precision, -- Number of uplinks received with signal strength > -120 dB
  best_level double precision, -- Signal strength of strongest uplink (dB)
  pass_dur double precision, -- Duration of satellite overpass (seconds)
  freq double precision, -- Measured frequency of SRDL signal at the satellite (Hz)
    CONSTRAINT argos_locations_pkey PRIMARY KEY (measurement_id),
      CONSTRAINT argos_locations_fkey_surgery FOREIGN KEY (surgery_id)
      REFERENCES surgery (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
      CONSTRAINT argos_locations_latitude CHECK (latitude < 90 AND latitude > (-90)),
      CONSTRAINT argos_locations_longitude CHECK (longitude < 180 AND longitude > (-180)),
      CONSTRAINT argos_locations_time CHECK (timestamp < now())
);

CREATE TABLE gls_locations
(
  measurement_id bigint NOT NULL,
  surgery_id bigint NOT NULL, 
  timestamp timestamp with time zone NOT NULL, -- time assigned to the location (UTC) in the following format "YYYY-MM-DD hh:mm:ss"
  latitude double precision NOT NULL, -- In decimal format and degree North.
  longitude double precision NOT NULL, -- In decimal format and degree East.
    CONSTRAINT gls_locations_pkey PRIMARY KEY (measurement_id),
      CONSTRAINT gls_locations_fkey_surgery FOREIGN KEY (surgery_id)
      REFERENCES surgery (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
      CONSTRAINT gls_locations_latitude CHECK (latitude < 90 AND latitude > (-90)),
      CONSTRAINT gls_locations_longitude CHECK (longitude < 180 AND longitude > (-180)),
      CONSTRAINT gls_locations_time CHECK (timestamp < now())
);