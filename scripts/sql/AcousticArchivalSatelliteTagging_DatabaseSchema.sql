SET SEARCH_PATH = biologging, public;

DROP SCHEMA IF EXISTS biologging CASCADE;
DROP USER IF EXISTS biologging;
CREATE USER biologging WITH PASSWORD 'biologging';
CREATE SCHEMA biologging AUTHORIZATION biologging;

-----------------------------------
-- Metadata tables
CREATE TABLE project
(
  id bigint NOT NULL,
  title character varying(255) NOT NULL,
  summary character varying(255) NOT NULL,
  citation character varying(255) NOT NULL,
  infoURL character varying(255),
  publications character varying(255),
  license character varying(255),
  distribution_statement character varying(255),
  date_modified timestamp without time zone NOT NULL,
  project_geospatial_lat_min double precision NOT NULL,
  project_geospatial_lat_max double precision NOT NULL,
  project_geospatial_lon_min double precision NOT NULL,
  project_geospatial_lon_max double precision NOT NULL,
  timestamp_start timestamp without time zone NOT NULL,
  timestamp_end timestamp without time zone NOT NULL,
  CONSTRAINT project_pkey PRIMARY KEY (id),
  CONSTRAINT project_name_key UNIQUE (title),
  CONSTRAINT project_latitude CHECK (project_geospatial_lat_min < 90 AND project_geospatial_lat_min > (-90) AND project_geospatial_lat_max < 90 AND project_geospatial_lat_max > (-90) AND project_geospatial_lat_min < project_geospatial_lat_max),
  CONSTRAINT project_longitude CHECK (project_geospatial_lon_min < 180 AND project_geospatial_lon_min > (-180) AND project_geospatial_lon_max < 180 AND project_geospatial_lon_max > (-180) AND project_geospatial_lon_min < project_geospatial_lon_max),
  CONSTRAINT project_time CHECK (timestamp_start < timestamp_end)
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
  CONSTRAINT project_role_types CHECK (role_type IN ('Principal Investigator', 'Co-Investigator', 'Research Assistant', 'Technical Assistant', 'Administrator', 'Student'))
);

CREATE TABLE device
(
  id bigint NOT NULL,
  device_type character varying(255) NOT NULL,
  manufacturer_name character varying(255) NOT NULL,
  model_name character varying(255) NOT NULL,
  serial_number character varying(255) NOT NULL,
  infoURL character varying(255) NOT NULL,
  invoice_number character varying(255),
  invoice_date timestamp without time zone,
  manufacturing_date timestamp without time zone NOT NULL,
  shipping_date timestamp without time zone,
  firmware_name character varying(255),
  firmware_version character varying(255),
    CONSTRAINT device_pkey PRIMARY KEY (id),
    CONSTRAINT unique_device UNIQUE (manufacturer_name, model_name, serial_number),
    CONSTRAINT device_types CHECK (device_type IN ('Tag', 'Receiver', 'Transceiver')),
    CONSTRAINT manufacturing_time CHECK (manufacturing_date < now())
);

CREATE TABLE device_predeployment_specifications
( 
  id bigint NOT NULL,
  device_id bigint NOT NULL,
  project_id bigint NOT NULL,
  device_name character varying(255) NOT NULL,
  software_name character varying(255), 
  software_version character varying(255),
  software_specifications text NOT NULL,
  software_modified_date timestamp without time zone NOT NULL,
  expected_life_time_days integer NOT NULL,
  initialisation_datetime timestamp without time zone,
  programmed_popoff_date timestamp without time zone,
    CONSTRAINT device_predeployment_specifications_pkey PRIMARY KEY (id),
    CONSTRAINT device_predeployment_specifications_fkey_device FOREIGN KEY (device_id)
      REFERENCES device (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT device_predeployment_specifications_fkey_project FOREIGN KEY (project_id)
      REFERENCES project (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE transmission_type
(
  id bigint NOT NULL,
  device_predeployment_specifications_id bigint NOT NULL,
  transmission_name character varying(255) NOT NULL,
  transmission_id character varying(255),
  transmission_preprocessing character varying(255),
  wmo_number character varying(255),
  CONSTRAINT transmission_type_pkey PRIMARY KEY (id),
  CONSTRAINT transmission_type_fkey_device_predeployment_specifications FOREIGN KEY (device_predeployment_specifications_id)
    REFERENCES device_predeployment_specifications (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT transmission_name_check CHECK (transmission_name IN ('Fastloc GPS', 'Argos', 'Iridium', 'GSM', 'Acoustic'))
);

CREATE TABLE sensors
(
  id bigint NOT NULL,
  device_predeployment_specifications_id bigint NOT NULL,
  sensor_type character varying(255) NOT NULL,
  unit character varying(255) NOT NULL,
  sensor_data_processing character varying(255),
  code_space character varying(255),
  ping_code integer, 
  intercept real,
  slope real,
  ping_rate real,
  onoff_settings real,
  CONSTRAINT sensor_pkey PRIMARY KEY (id),
  CONSTRAINT sensor_fkey_device_specifications FOREIGN KEY (device_predeployment_specifications_id)
      REFERENCES device_predeployment_specifications (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT sensor_type_name CHECK (sensor_type IN ('Pressure', 'Temperature', 'Light', 'Conductivity', 'Fluorescence', 'Accelerometer', 'Magnetometer', 'Stomach temperature', 'Pinger', 'Range test')), -- examples only, more to be added in
  CONSTRAINT unit_type CHECK (unit IN ('°C', 'm', 'm.s-2')), -- examples only, more to be added in
  CONSTRAINT code_space_check CHECK (code_space IS NOT NULL AND code_space IN ('A69-1105', 'A69-9002', 'A69-9004', 'A180-1303', 'A180-1601')) -- examples only, more to be added in
);

CREATE TABLE species 
(
  id bigint NOT NULL,
  "worms_aphiaID" character varying NOT NULL,
  kingdom character varying(255) NOT NULL,
  phylum character varying(255) NOT NULL,
  class_name character varying(255) NOT NULL,
  order_name character varying(255) NOT NULL,
  family character varying(255) NOT NULL,
  genus character varying(255) NOT NULL,
  subgenus character varying (255),
  "specificEpithet" character varying (255) NOT NULL, 
  "infraspecificEpithet" character varying (255) NOT NULL,
  "scientificName" character varying(255) NOT NULL, 
  "acceptedNameUsage" character varying(255) NOT NULL,
  "vernacularName" character varying(255) NOT NULL,
  "scientificNameAuthorship" character varying(255) NOT NULL,
  date_modified timestamp without time zone NOT NULL,
  CONSTRAINT species_pkey PRIMARY KEY (id)
);

CREATE TABLE platform
(
  id bigint NOT NULL,
  platform_type character varying (255) NOT NULL,
  platform_name character varying (255) NOT NULL,
  project_id bigint REFERENCES project,
  "platform_decimalLatitude" double precision,
  "platform_decimalLongitude" double precision,
  platform_depth real,
  species_id bigint REFERENCES species,
  sex character varying(7),
  CONSTRAINT platform_pkey PRIMARY KEY (id),
  CONSTRAINT platform_types CHECK (platform_type IN ('Underwater mooring', 'Surface buoy', 'Animal', 'Glider', 'AUV', 'Drifter', 'Vessel')),
  CONSTRAINT platform_animal_project CHECK ((platform_type = 'Animal' AND project_id IS NULL) OR (platform_type != 'Animal' AND project_id IS NOT NULL)),
  CONSTRAINT platform_latitude CHECK ((platform_type IN ('Underwater mooring', 'Surface buoy') AND "platform_decimalLatitude" < 90 AND "platform_decimalLatitude" > (-90)) OR (platform_type NOT IN ('Underwater mooring', 'Surface buoy') and "platform_decimalLatitude" IS NULL)),
  CONSTRAINT platform_longitude CHECK ((platform_type IN ('Underwater mooring', 'Surface buoy') AND "platform_decimalLongitude" < 180 AND "platform_decimalLongitude" > (-180)) OR (platform_type NOT IN ('Underwater mooring', 'Surface buoy') and "platform_decimalLatitude" IS NULL)),
  CONSTRAINT platform_depthm CHECK ((platform_type IN ('Underwater mooring', 'Surface buoy') AND platform_depth >= 0 AND platform_depth < 500) OR (platform_type NOT IN ('Underwater mooring', 'Surface buoy') and platform_depth IS NULL)),
  CONSTRAINT platform_animal_species CHECK ((platform_type = 'Animal' AND species_id IS NOT NULL) OR (platform_type != 'Animal' AND species_id IS NULL)),
  CONSTRAINT platform_animal_sex_types CHECK ((platform_type = 'Animal' AND sex IN ('Female', 'Male', 'Unknown')) OR (platform_type != 'Animal' AND sex IS NULL))
);

CREATE TABLE device_deployment_recovery
(
  id bigint NOT NULL,
  device_predeployment_specifications_id bigint NOT NULL,
  platform_id bigint NOT NULL,
  deployer_id bigint NOT NULL,
  deployment_locality character varying(255) NOT NULL,
  "deployment_decimalLatitude" double precision NOT NULL,
  "deployment_decimalLongitude" double precision NOT NULL,
  deployment_datetime timestamp without time zone NOT NULL,
  deployment_position character varying(255) NOT NULL,
  deployment_method character varying(255) NOT NULL,
  deployment_comments character varying(255),
  deployment_bottom_depthm real,
  deployment_sst real,
  recoverer_id bigint REFERENCES users,
  recovery_locality character varying(255),
  "recovery_decimalLatitude" double precision,
  "recovery_decimalLongitude" double precision,
  recovery_datetime timestamp without time zone,
  "popup_decimalLatitude" double precision,
  "popup_decimalLongitude" double precision,
  popup_datetime timestamp without time zone,
  device_recovery_status character varying(255),
  embargo_datetime timestamp without time zone,
    CONSTRAINT device_deployment_recovery_pkey PRIMARY KEY (id),
    CONSTRAINT device_deployment_recovery_fkey_device FOREIGN KEY (device_predeployment_specifications_id)
    REFERENCES device_predeployment_specifications (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT device_deployment_recovery_fkey_platform FOREIGN KEY (platform_id)
      REFERENCES platform (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT device_deployment_recovery_fkey_tagger FOREIGN KEY (deployer_id)
      REFERENCES users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT device_deployment_recovery_fkey_recoverer FOREIGN KEY (recoverer_id)
      REFERENCES users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT deployment_bottom_depth CHECK (deployment_bottom_depthm > 0 AND deployment_bottom_depthm < 11000),
    CONSTRAINT deployment_ssts CHECK (deployment_sst > (-2.5) AND deployment_sst < 40),
    CONSTRAINT deployment_latitude CHECK ("deployment_decimalLatitude" < 90 AND "deployment_decimalLatitude" > (-90)),
    CONSTRAINT deployment_longitude CHECK ("deployment_decimalLongitude" < 180 AND "deployment_decimalLongitude" > (-180)),
    CONSTRAINT recovery_latitude CHECK ("recovery_decimalLatitude" < 90 AND "recovery_decimalLatitude" > (-90)),
    CONSTRAINT recovery_longitude CHECK ("recovery_decimalLongitude" < 180 AND "recovery_decimalLongitude" > (-180)),
    CONSTRAINT recovery_time CHECK (deployment_datetime < recovery_datetime),
    CONSTRAINT popup_latitude CHECK ("popup_decimalLatitude" < 90 AND "popup_decimalLatitude" > (-90)),
    CONSTRAINT popup_longitude CHECK ("popup_decimalLongitude" < 180 AND "popup_decimalLongitude" > (-180)),
    CONSTRAINT popup_time CHECK (popup_datetime < now() AND deployment_datetime < popup_datetime),
    CONSTRAINT embargo_time CHECK (embargo_datetime < (now() + interval '3 year'))
);

CREATE TABLE animal_capture
(
  id bigint NOT NULL,
  platform_id bigint NOT NULL,
  catcher_id bigint NOT NULL,
  capture_number integer NOT NULL,
  capture_locality character varying(255) NOT NULL,
  "capture_decimalLatitude" double precision NOT NULL,
  "capture_decimalLongitude" double precision NOT NULL,
  capture_datetime timestamp without time zone NOT NULL,
  capture_comments character varying(255),
  release_locality character varying(255) NOT NULL,
  "release_decimalLatitude" double precision NOT NULL,
  "release_decimalLongitude" double precision NOT NULL,
  release_datetime timestamp without time zone NOT NULL,
  release_comments character varying(255),
  tag_status character varying(255),
    CONSTRAINT animal_capture_pkey PRIMARY KEY (id),
    CONSTRAINT animal_capture_fkey_catcher FOREIGN KEY (catcher_id)
      REFERENCES users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT animal_capture_fkey_platform FOREIGN KEY (platform_id)
      REFERENCES platform (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT capture_latitude CHECK ("capture_decimalLatitude" < 90 AND "capture_decimalLatitude" > (-90)),
    CONSTRAINT capture_longitude CHECK ("capture_decimalLongitude" < 180 AND "capture_decimalLongitude" > (-180)),
    CONSTRAINT capture_time CHECK (capture_datetime < now()),
    CONSTRAINT release_latitude CHECK ("release_decimalLatitude" < 90 AND "release_decimalLatitude" > (-90)),
    CONSTRAINT release_longitude CHECK ("release_decimalLongitude" < 180 AND "release_decimalLongitude" > (-180)),
    CONSTRAINT release_time CHECK (release_datetime < now() AND capture_datetime < release_datetime)
);

CREATE TABLE animal_measurements
(
  id bigint NOT NULL,
  capture_id bigint NOT NULL,
  type character varying(255) NOT NULL,
  unit character varying(20) NOT NULL,
  value real NOT NULL,
  estimate boolean NOT NULL,
  comments character varying(255),
  CONSTRAINT animal_measurements_pkey PRIMARY KEY (id),
  CONSTRAINT animal_measurements_fkey_animal FOREIGN KEY (capture_id)
      REFERENCES animal_capture (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT animal_measurements_type CHECK (type IN ('length', 'width', 'weight', 'total length', 'carapace length', 'carapace width', 'fork length', 'girth', 'half girth')), -- examples only, more to be added in
  CONSTRAINT animal_measurements_unit CHECK (unit IN ('mm', 'cm', 'm', 'g', 'kg')), -- examples only, more to be added in
  CONSTRAINT animal_measurements_value CHECK (value > 0)
);

CREATE TABLE animal_observations
(
  id bigint NOT NULL,
  capture_id bigint NOT NULL,
  "lifeStage" character varying(255) NOT NULL,
  "ageUnit" character varying(20),
  value real,
  estimate boolean,
  "DNA_sample_id" character varying(20),
  "mRNA_sample_id" character varying(20),
  genetic_sample_location character varying(255),
  conventional_tag_numbers character varying(255),
  conventional_tag_locations character varying(255),
  comments character varying(255),
  CONSTRAINT animal_observations_pkey PRIMARY KEY (id),
  CONSTRAINT animal_observations_capture_ukey UNIQUE (capture_id),
  CONSTRAINT animal_observations_fkey_animal FOREIGN KEY (capture_id)
      REFERENCES animal_capture (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT animal_life_stage_types CHECK ("lifeStage" IN ('Adult', 'Juvenile', 'Subadult')), -- examples only, more to be added in
  CONSTRAINT animal_unit_types CHECK ("ageUnit" IN ('Days', 'Months', 'Years')), -- examples only, more to be added in
  CONSTRAINT animal_value CHECK (value > 0)
);


-----------------------------------
-- Monitoring tables
CREATE TABLE activity_log
(
  id bigint NOT NULL,
  user_id bigint NOT NULL,
  class_name character varying(255) NOT NULL,
  property_name character varying(255) NOT NULL,
  persisted_object_id character varying(255) NOT NULL,
  event_type character varying(255) NOT NULL,
  modification_datetime timestamp without time zone NOT NULL,
  new_value character varying(255),
  old_value character varying(255),
  CONSTRAINT activity_log_pkey PRIMARY KEY (id),
  CONSTRAINT activity_log_fkey_users FOREIGN KEY (user_id)
      REFERENCES users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT event_types CHECK (event_type IN ('Delete', 'Insert', 'Update'))
);

CREATE TABLE uploaded_file
(
  id bigint NOT NULL,
  user_id bigint NOT NULL,
  file_type character varying(255) NOT NULL,
  file_name character varying(255) NOT NULL,
  class_name character varying(255),
  persisted_object_id character varying(255),
  comments character varying(255),
  upload_datetime timestamp without time zone NOT NULL,
  status character varying(255) NOT NULL,
  err_msg character varying(255) NOT NULL,
  CONSTRAINT uploaded_file_pkey PRIMARY KEY (id),
  CONSTRAINT uploaded_file_fkey_users FOREIGN KEY (user_id)
      REFERENCES users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT file_types CHECK (file_type IN ('Acoustic detections', 'GPS locations', 'Argos locations', 'GLS locations')) -- examples only, more to be added in
);

-----------------------------------
-- Data tables
CREATE TABLE gps_locations
(
  id serial NOT NULL,
  file_id bigint NOT NULL,
  device_name character varying(255) NOT NULL,
  "timestamp" timestamp without time zone NOT NULL,
  "decimalLatitude" double precision NOT NULL,
  "decimalLongitude" double precision NOT NULL,
  nsats_detected double precision,
  nsats_transmitted double precision,
  pseudoranges character varying (255),
  max_csn double precision,
  residual double precision,
  timeshift double precision,
  duplicate boolean NOT NULL,
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
  id serial NOT NULL, 
  file_id bigint NOT NULL,
  device_name character varying(255) NOT NULL,
  "timestamp" timestamp without time zone NOT NULL,
  "decimalLatitude" double precision NOT NULL,
  "decimalLongitude" double precision NOT NULL,
  location_quality character varying (2) NOT NULL,
  alt_latitude double precision,
  alt_longitude double precision,
  n_mess double precision,
  n_mess_120 double precision,
  best_level double precision,
  pass_dur double precision,
  freq double precision,
  duplicate boolean NOT NULL,
    CONSTRAINT argos_locations_pkey PRIMARY KEY (id),
      CONSTRAINT argos_locations_fkey_uploaded_file FOREIGN KEY (file_id)
      REFERENCES uploaded_file (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
      CONSTRAINT argos_locations_latitude CHECK ("decimalLatitude" < 90 AND "decimalLatitude" > (-90)),
      CONSTRAINT argos_locations_longitude CHECK ("decimalLongitude" < 180 AND "decimalLongitude" > (-180)),
      CONSTRAINT argos_locations_alt_latitude CHECK (alt_latitude < 90 AND alt_latitude > (-90)),
      CONSTRAINT argos_locations_alt_longitude CHECK (alt_longitude < 180 AND alt_longitude > (-180)),
      CONSTRAINT argos_locations_time CHECK (timestamp < now())
);

CREATE TABLE gls_locations
(
  id serial NOT NULL,
  file_id bigint NOT NULL,
  device_name character varying(255)NOT NULL,
  "timestamp" timestamp without time zone NOT NULL,
  "decimalLatitude" double precision NOT NULL,
  "decimalLongitude" double precision NOT NULL,
  duplicate boolean NOT NULL,
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
  id serial NOT NULL,
  file_id bigint NOT NULL,
  receiver_name character varying(255) NOT NULL,
  transmitter_id character varying(255) NOT NULL,
  "timestamp" timestamp without time zone NOT NULL,
  sensor_value real,
  sensor_unit character varying(255),
  duplicate boolean NOT NULL,
  CONSTRAINT acoustic_detections_pkey PRIMARY KEY (id),
  CONSTRAINT acoustic_detections_fkey_uploaded_file FOREIGN KEY (file_id)
      REFERENCES uploaded_file (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);


CREATE TABLE platform_locations
(
  id serial NOT NULL,
  file_id bigint NOT NULL,
  platform_name character varying(255)NOT NULL,
  "timestamp" timestamp without time zone NOT NULL,
  "decimalLatitude" double precision NOT NULL,
  "decimalLongitude" double precision NOT NULL,
  duplicate boolean NOT NULL,
    CONSTRAINT platform_locations_pkey PRIMARY KEY (id),
      CONSTRAINT platform_locations_fkey_uploaded_file FOREIGN KEY (file_id)
      REFERENCES uploaded_file (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
      CONSTRAINT platform_locations_latitude CHECK ("decimalLatitude" < 90 AND "decimalLatitude" > (-90)),
      CONSTRAINT platform_locations_longitude CHECK ("decimalLongitude" < 180 AND "decimalLongitude" > (-180)),
      CONSTRAINT platform_locations_time CHECK (timestamp < now())
);