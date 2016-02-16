SET SEARCH_PATH = biologging, public;

DROP SCHEMA IF EXISTS biologging CASCADE;
CREATE SCHEMA biologging AUTHORIZATION biologging;

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
  doi character varying(255),
  license character varying(255) NOT NULL,
  distribution_statement character varying(255) NOT NULL,
  date_modified timestamp with time zone NOT NULL,
  CONSTRAINT datacenter_pkey PRIMARY KEY (id)
);

CREATE TABLE project
(
  id bigint NOT NULL,
  datacenter_id bigint NOT NULL,
  title character varying(255) NOT NULL,
  summary character varying(255) NOT NULL,
  citation character varying(255) NOT NULL,
  infoURL character varying(255),
  publications character varying(255),
  doi character varying(255),
  license character varying(255),
  distribution_statement character varying(255),
  date_modified timestamp with time zone NOT NULL,
  location geometry NOT NULL,
  timestamp_start timestamp with time zone NOT NULL,
  timestamp_end timestamp with time zone NOT NULL,
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
  configuration_info character varying(255) NOT NULL, -- whether the default config was used, otherwise details about customisation of tags
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
  tdr boolean NOT NULL,
    CONSTRAINT device_pkey PRIMARY KEY (id),
    CONSTRAINT device_fkey_project FOREIGN KEY (project_id)
      REFERENCES project (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE species -- Table greatly simplified, needs to conform to an existing standard (e.g. WoRMS)
(
  id bigint NOT NULL,
  kingdom character varying(255) NOT NULL,
  phylum character varying(255) NOT NULL,
  class character varying(255) NOT NULL,
  order_name character varying(255) NOT NULL,
  family character varying(255) NOT NULL,
  genus character varying(255) NOT NULL,
  "specificEpithet" character varying(255) NOT NULL,
  "scientificName" character varying(255) NOT NULL,
  "vernacularName" character varying(255) NOT NULL,
  "scientificNameAuthorship" character varying(255) NOT NULL,
  date_modified timestamp with time zone NOT NULL,
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
  comments character varying(255), --  e.g. animal origin (i.e. wild, hatchery), stock, damages
  capture_locality character varying(255),
  capture_location geometry,
  capture_datetime timestamp with time zone, -- UTC
  release_locality character varying(255) NOT NULL,
  release_location geometry NOT NULL,
  release_datetime timestamp with time zone NOT NULL, -- UTC
  other_samples_taken character varying(255), -- Describe whether any samples were taken during the tagging experiment (e.g. DNA, blubber, blood)
  CONSTRAINT animal_pkey PRIMARY KEY (id),
  CONSTRAINT animal_fkey_species FOREIGN KEY (species_id)
      REFERENCES species (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT animal_sex_types CHECK (sex = 'Female' OR sex = 'Male' OR sex = 'Unknown'),
  CONSTRAINT animal_life_stage_types CHECK ("lifeStage" = 'Adult' OR "lifeStage" = 'Juvenile' OR "lifeStage" = 'Subadult'),
  CONSTRAINT animal_unit_types CHECK (unit = 'Days' OR unit = 'Months' OR unit = 'Years' OR unit IS NULL)
);

CREATE TABLE tag_deployment
(
  id bigint NOT NULL,
  device_id bigint NOT NULL, -- FK to device.id
  animal_id bigint NOT NULL,
  tagger_id bigint NOT NULL, -- FK to users.id
  attachment_method character varying(255) NOT NULL, -- Could be made a separate table so that users have a limited range of tagging attachment methods
  attachment_details character varying(255), -- Provide any other additional information regarding the attachment (exact location of tag on animal, wedges)
    CONSTRAINT tag_deployment_pkey PRIMARY KEY (id),
    CONSTRAINT tag_deployment_fkey_device FOREIGN KEY (device_id)
      REFERENCES device (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT tag_deployment_fkey_tagger FOREIGN KEY (tagger_id)
      REFERENCES users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT tag_deployment_fkey_animal FOREIGN KEY (animal_id)
      REFERENCES animal (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE tag_recovery
(
  id bigint NOT NULL,
  deployment_id bigint NOT NULL,
  recoverer_id bigint NOT NULL, -- FK to users.id
  recovery_locality character varying(255) NOT NULL,
  recovery_location geometry NOT NULL,
  recovery_datetime timestamp with time zone NOT NULL, -- UTC
  comments character varying(255), -- e.g. Damage on tags, tag still operational, tag sent back to manufacturer for refurbishing
  CONSTRAINT tag_recovery_pkey PRIMARY KEY (id),
  CONSTRAINT tag_recovery_fkey FOREIGN KEY (deployment_id)
      REFERENCES tag_deployment (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT tag_recovery_fkey_tagger FOREIGN KEY (recoverer_id)
      REFERENCES users (id) MATCH SIMPLE
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