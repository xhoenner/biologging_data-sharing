SET SEARCH_PATH = biologging, public;

---- Metadata Tables
-- project
COMMENT ON TABLE project IS 'Information on tagging projects (e.g. abstract, distribution statement)';
COMMENT ON COLUMN project.id IS 'Project ID (unique). Primary key';
COMMENT ON COLUMN project.title IS 'Project name. Must be unique';
COMMENT ON COLUMN project.summary IS 'Description of project including background, methods, and objectives';
COMMENT ON COLUMN project.citation IS 'Citation to be used in publications using the data from the project should follow the following format: “ProjectName. [year-of-data-download], [Title], [Data access URL], accessed [date-of-access]”';
COMMENT ON COLUMN project.infourl IS 'URL to project information website or metadata record';
COMMENT ON COLUMN project.publications IS 'Published or web-based references that describe the data or methods used to produce the data from the project. Multiple references should be separated with a semicolon. If available DOIs should be given';
COMMENT ON COLUMN project.license IS 'Describe the project restrictions to data access and distribution';
COMMENT ON COLUMN project.distribution_statement IS 'Statement describing data distribution policy (e.g. ‘You accept all risks and responsibility for losses, damages, costs and other consequences resulting directly or indirectly from using the data from this project’)';
COMMENT ON COLUMN project.date_modified IS 'Date on which the project data was last modified';
COMMENT ON COLUMN project.project_geospatial_lat_min IS 'Southernmost latitude of bounding box of the project data. A value between -90 and 90 decimal degrees North.';
COMMENT ON COLUMN project.project_geospatial_lat_max IS 'Northernnmost latitude of bounding box of the project data. A value between -90 and 90 decimal degrees North.';
COMMENT ON COLUMN project.project_geospatial_lon_min IS 'Westernmost longitude of bounding box of the project data. A value between -180 and 180 decimal degrees East.';
COMMENT ON COLUMN project.project_geospatial_lon_max IS 'Easternmost longitude of bounding box of the project data. A value between -180 and 180 decimal degrees East.';
COMMENT ON COLUMN project.timestamp_start IS 'Start date and time (UTC) of the project data. Check constraint required';
COMMENT ON COLUMN project.timestamp_end IS 'End date and time (UTC) of the project data. Check constraint required';

-- users
COMMENT ON TABLE users IS 'Provides names and contact details of users';
COMMENT ON COLUMN users.id IS 'User ID (unique). Primary key';
COMMENT ON COLUMN users.organisation_name IS 'Name of organisation';
COMMENT ON COLUMN users.name IS 'Name of user';
COMMENT ON COLUMN users.email_address IS 'Email address of user';
COMMENT ON COLUMN users.department IS 'Department name within organisation';
COMMENT ON COLUMN users.phone_number IS 'Phone number of user, including country and area code';
COMMENT ON COLUMN users.postal_address IS 'Postal address of organisation';

-- project_role
COMMENT ON TABLE project_role IS 'Provides mapping between the project and users table';
COMMENT ON COLUMN project_role.id IS 'Project role ID (unique). Primary key';
COMMENT ON COLUMN project_role.user_id IS 'User ID. Foreign key to users table';
COMMENT ON COLUMN project_role.project_id IS 'Project ID. Foreign key to project table';
COMMENT ON COLUMN project_role.role_type IS 'Role of user in project (e.g. Principal Investigator, Co-Investigator, Administrator, Student).';

-- device
COMMENT ON TABLE device IS 'Manufacturing details for each device. The information in this table is static, i.e. will not change from one deployment of a device to the next';
COMMENT ON COLUMN device.id IS 'Device ID (unique). Primary key';
COMMENT ON COLUMN device.device_type IS 'Type of device, can only be be a tag, receiver, or transceiver';
COMMENT ON COLUMN device.manufacturer_name IS 'Name of device manufacturer. Unique constraint on the combination of manufacturer_name, model_name, and serial_number. Controlled vocabulary required';
COMMENT ON COLUMN device.model_name IS 'Device model name. Controlled vocabulary required';
COMMENT ON COLUMN device.serial_number IS 'Device serial number';
COMMENT ON COLUMN device.infourl IS 'URL to device model specifications';
COMMENT ON COLUMN device.invoice_number IS 'Purchase invoice number';
COMMENT ON COLUMN device.invoice_date IS 'Date and time of purchase as shown on invoice (UTC)';
COMMENT ON COLUMN device.manufacturing_date IS 'Manufacturing date and time (UTC)';
COMMENT ON COLUMN device.shipping_date IS 'Date and time of device shipping (UTC)';
COMMENT ON COLUMN device.firmware_name IS 'Name of the firmware used to build the device';
COMMENT ON COLUMN device.firmware_version IS 'Version number of the firmware used to build the device';

-- device_predeployment_specifications
COMMENT ON TABLE device_predeployment_specifications IS 'Information about pre-deployment configuration settings of individual devices. Allows for device re-configuration in case of multiple deployments';
COMMENT ON COLUMN device_predeployment_specifications.id IS 'Device configuration ID (unique). Primary key';
COMMENT ON COLUMN device_predeployment_specifications.device_id IS 'Device ID. Foreign key to device table';
COMMENT ON COLUMN device_predeployment_specifications.project_id IS 'Project ID. Foreign key to project table';
COMMENT ON COLUMN device_predeployment_specifications.device_name IS 'Device name for each project (e.g. ct111-030-13). For acoustic tags, this field value should be automatically generated using values from the `code_space` and `ping_code` fields in the `sensors` table (i.e. `device_name` = `code_map`-`ping_code`). For acoustic receivers, this field value should be automatically generated using values from the `model_name` and `serial_number` fields in the `device` table (i.e. ` device_name ` = `model_name`-` serial_number`). This field value needs to match the content of the `device_name` field (or `transmitter_id`) in the data tables for data to be joined to metadata';
COMMENT ON COLUMN device_predeployment_specifications.software_name IS 'Name of the software used to configure the device'; 
COMMENT ON COLUMN device_predeployment_specifications.software_version IS 'Version number of the software used to configure the device';
COMMENT ON COLUMN device_predeployment_specifications.software_specifications IS 'Parameters used when configuring the device for deployment, i.e. sensor specs and calibration procedures; could also consists of a URL pointing to where the configuration file can be found';
COMMENT ON COLUMN device_predeployment_specifications.software_modified_date IS 'Date and time of last software modification (UTC)';
COMMENT ON COLUMN device_predeployment_specifications.expected_life_time_days IS 'Number of days the device is expected to be functional for';
COMMENT ON COLUMN device_predeployment_specifications.initialisation_datetime IS 'Device initialisation date and time (UTC). Not null if device.device_type = `Receiver`';
COMMENT ON COLUMN device_predeployment_specifications.programmed_popoff_date IS 'Programmed release date and time for PSAT tags (UTC)';

-- transmission_type
COMMENT ON TABLE transmission_type IS 'Information about data-relaying capabilities of individual devices, if any';
COMMENT ON COLUMN transmission_type.id IS 'Transmission type ID (unique). Primary key';
COMMENT ON COLUMN transmission_type.device_predeployment_specifications_id IS 'Device configuration ID. Foreign key to device_predeployment_specifications table';
COMMENT ON COLUMN transmission_type.transmission_name IS 'Name of communication system used for transmitting data. Controlled vocabulary implemented, e.g. Fastloc GPS, Argos, Iridium, GSM, or Acoustic';
COMMENT ON COLUMN transmission_type.transmission_id IS 'Communication ID, if any, as provided by the communication company, e.g. PTT for Argos. This field may be null for acoustic and potentially other devices';
COMMENT ON COLUMN transmission_type.transmission_preprocessing IS 'Which algorithm was used to process raw data, if any, e.g. for Argos: Least Squares vs. Kalman filter';
COMMENT ON COLUMN transmission_type.wmo_number IS 'World Meteorological Organization (WMO) number allocated to this device, if any';

-- sensors
COMMENT ON TABLE sensors IS 'Information about on-board sensors on individual devices, if any';
COMMENT ON COLUMN sensors.id IS 'Sensor ID (unique). Primary key';
COMMENT ON COLUMN sensors.device_predeployment_specifications_id IS 'Device configuration ID. Foreign key to device_predeployment_specifications table';
COMMENT ON COLUMN sensors.sensor_type IS 'Type of on-board sensor. Controlled vocabulary implemented, e.g. Pressure, Temperature, Light, Conductivity, Fluorescence, Accelerometer, Magnetometer, Stomach temperature, Pinger, or Range test. The latter two are not sensors per se but are listed in here because acoustic tags carrying multiple sensors each have their own ping_code';
COMMENT ON COLUMN sensors.unit IS 'Sensor unit. Controlled vocabulary required. May be null, e.g. for pingers';
COMMENT ON COLUMN sensors.sensor_data_processing IS 'Which algorithm was used to process raw sensor data, if any';
COMMENT ON COLUMN sensors.code_space IS 'For acoustic tags only, transmission frequency can be inferred based on this. If device.device_type = `Tag` and transmission_type.transmission_name = `Acoustic` then this field cannot be null. Controlled vocabulary implemented. Could also check whether sensor_type matches this code_space value, refer to https://github.com/aodn/aatams/issues/373';
COMMENT ON COLUMN sensors.ping_code IS 'For acoustic tags only. If device.device_type = `Tag` and transmission_type.transmission_name = `Acoustic` then this field cannot be null';
COMMENT ON COLUMN sensors.intercept IS 'Intercept of the sensor. Not null if device.device_type = `Tag` and transmission_type.transmission_name = `Acoustic` and sensor.sensor_type IN (Temperature, Pressure, Accelerometer)';
COMMENT ON COLUMN sensors.slope IS 'Slope of the sensor. Not null if device.device_type = `Tag` and transmission_type.transmission_name = `Acoustic` and sensor.sensor_type IN (Temperature, Pressure, Accelerometer)';
COMMENT ON COLUMN sensors.ping_rate IS 'For acoustic tag range and performance testing, more details required from OTN';
COMMENT ON COLUMN sensors.onoff_settings IS 'For acoustic tag range and performance testing, more details required from OTN';

-- species
COMMENT ON TABLE species IS 'Simplified list of species (read only). Need to conform to a comprehensive standard agreed upon by the tagging community (e.g. WoRMS for marine species, http://www.marinespecies.org/). To be more user-friendly it would be good to use English names for higher level taxonomical ranks, e.g. marine mammals, sharks, fish, marine reptiles';
COMMENT ON COLUMN species.id IS 'Species ID (unique). Primary key';
COMMENT ON COLUMN species."worms_aphiaID" IS 'WoRMS Aphia ID';
COMMENT ON COLUMN species.kingdom IS 'The full scientific name of the kingdom in which the taxon is classified';
COMMENT ON COLUMN species.phylum IS 'The full scientific name of the phylum or division in which the taxon is classified';
COMMENT ON COLUMN species.class_name IS 'The full scientific name of the class in which the taxon is classified';
COMMENT ON COLUMN species.order_name IS 'The full scientific name of the order in which the taxon is classified';
COMMENT ON COLUMN species.family IS 'The full scientific name of the family in which the taxon is classified';
COMMENT ON COLUMN species.genus IS 'The full scientific name of the genus in which the taxon is classified';
COMMENT ON COLUMN species.subgenus IS 'The full scientific name of the subgenus in which the taxon is classified. Values should include the genus to avoid homonym confusion';
COMMENT ON COLUMN species."specificEpithet" IS 'The name of the first or species epithet of the scientificName';
COMMENT ON COLUMN species."infraspecificEpithet" IS 'The name of the lowest or terminal infraspecific epithet of the scientificName, excluding any rank designation';
COMMENT ON COLUMN species."scientificName" IS 'The full scientific name, with authorship and date information if known. When forming part of an Identification, this should be the name in lowest level taxonomic rank that can be determined. This term should not contain identification qualifications, which should instead be supplied in the identificationQualifier term';
COMMENT ON COLUMN species."acceptedNameUsage" IS 'The full name, with authorship and date information if known, of the currently valid (zoological) or accepted (botanical) taxon';
COMMENT ON COLUMN species."vernacularName" IS 'A common or vernacular name';
COMMENT ON COLUMN species."scientificNameAuthorship" IS 'The authorship information for the scientificName formatted according to the conventions of the applicable nomenclaturalCode';
COMMENT ON COLUMN species.date_modified IS 'Date on which each species entry was last modified';

-- platform
COMMENT ON TABLE platform IS 'Information about the platform on which individual devices have been deployed';
COMMENT ON COLUMN platform.id IS 'Platform ID (unique). Primary key';
COMMENT ON COLUMN platform.platform_type IS 'Type of platform. Controlled vocabulary implemented, e.g. Underwater mooring, Surface buoy, Animal, Glider, AUV, Drifter, or Vessel';
COMMENT ON COLUMN platform.platform_name IS 'This field value needs to match the content of the `platform_name` field in the `platform_locations` tables for data to be joined to metadata for gliders, AUVs, drifters, and vessels. Station name for underwater moorings or surface buoys';
COMMENT ON COLUMN platform.project_id IS 'Project ID. May only be null if platform_type = `Animal`';
COMMENT ON COLUMN platform."platform_decimalLatitude" IS 'Manmade platform latitude, in decimal format and degree North. A value between -90 and 90 decimal degrees North. Null unless platform_type IN (`Underwater mooring`, `Surface buoy`)';
COMMENT ON COLUMN platform."platform_decimalLongitude" IS 'Manmade platform longitude, in decimal format and degree East. A value between -180 and 180 decimal degrees East. Null unless platform_type IN (`Underwater mooring`, `Surface buoy`)';
COMMENT ON COLUMN platform.platform_depth IS 'Vertical distance of the manmade platform below the surface, in meters. A value between 0 and 500 m. Null unless platform_type IN (`Underwater mooring`, `Surface buoy`)';
COMMENT ON COLUMN platform.species_id IS 'Species ID. Null unless platform_type = `Animal`';
COMMENT ON COLUMN platform.sex IS 'Sex of animal. Can only be female, male, or unknown. Null unless platform_type = `Animal`';


-- device_deployment_recovery
COMMENT ON TABLE device_deployment_recovery IS 'Deployment and recovery information of configured devices. This is a mapping table between the `device_predeployment_specifications` and `platform` tables';
COMMENT ON COLUMN device_deployment_recovery.id IS 'Device deployment and recovery ID (unique). Primary key';
COMMENT ON COLUMN device_deployment_recovery.device_predeployment_specifications_id IS 'Device configuration ID. Foreign key to device_predeployment_specifications table';
COMMENT ON COLUMN device_deployment_recovery.platform_id IS 'Platform ID. Foreign key to platform table';
COMMENT ON COLUMN device_deployment_recovery.deployer_id IS 'ID of the person who deployed the configured device. Foreign key to users table';
COMMENT ON COLUMN device_deployment_recovery.deployment_locality IS 'Locality, State/Territory, Country of device deployment. Controlled vocabulary required, could be using entries from the Geonames database, http://www.geonames.org/';
COMMENT ON COLUMN device_deployment_recovery."deployment_decimalLatitude" IS 'Deployment latitude, in decimal format and degree North. A value between -90 and 90 decimal degrees North';
COMMENT ON COLUMN device_deployment_recovery."deployment_decimalLongitude" IS 'Deployment longitude, in decimal format and degree East. A value between -180 and 180 decimal degrees East';
COMMENT ON COLUMN device_deployment_recovery.deployment_datetime IS 'Date and time (UTC) of deployment';
COMMENT ON COLUMN device_deployment_recovery.deployment_position IS 'Location of device on platform. For acoustic receiver specify type of mooring used (fixed vs floating) and receiver orientation (up, down, sideways)';
COMMENT ON COLUMN device_deployment_recovery.deployment_method IS 'Describe how the device was attached to the platform (e.g. glued, implant, dart and leader for PSATs)';
COMMENT ON COLUMN device_deployment_recovery.deployment_comments IS 'Additional information regarding device deployment, e.g. wedges, leader number, details about mooring';
COMMENT ON COLUMN device_deployment_recovery.deployment_bottom_depthm IS 'Vertical distance of the seafloor below the surface, in meters. A value between 0 and 11,000 m';
COMMENT ON COLUMN device_deployment_recovery.deployment_sst IS 'Sea surface temperature recorded when deploying the device. A value between -2.5 and 40 degrees Celsius';
COMMENT ON COLUMN device_deployment_recovery.recoverer_id IS 'ID of the person who recovered the device. Foreign key to users table. Check constraint required: all fields in this table labelled "recovery_" cannot be null if recoverer_id is not null';
COMMENT ON COLUMN device_deployment_recovery.recovery_locality IS 'Locality, State/Territory, Country of device recovery. Controlled vocabulary required, could be using entries from the Geonames database, http://www.geonames.org/';
COMMENT ON COLUMN device_deployment_recovery."recovery_decimalLatitude" IS 'Recovery latitude, in decimal format and degree North. A value between -90 and 90 decimal degrees North';
COMMENT ON COLUMN device_deployment_recovery."recovery_decimalLongitude" IS 'Recovery longitude, in decimal format and degree East. A value between -180 and 180 decimal degrees East';
COMMENT ON COLUMN device_deployment_recovery.recovery_datetime IS 'Device recovery date and time (UTC). A value greater than the value for deployment_datetime';
COMMENT ON COLUMN device_deployment_recovery."popup_decimalLatitude" IS 'Pop-up latitude, in decimal format and degree North. A value between -90 and 90 decimal degrees North';
COMMENT ON COLUMN device_deployment_recovery."popup_decimalLongitude" IS 'Pop-up longitude, in decimal format and degree East. A value between -180 and 180 decimal degrees East';
COMMENT ON COLUMN device_deployment_recovery.popup_datetime IS 'Device pop-up date and time (UTC). A value greater than the value for deployment_datetime. Null unless device_predeployment_specifications.programmed_popoff_date is not null';
COMMENT ON COLUMN device_deployment_recovery.device_recovery_status IS 'Retired, damaged, stolen, recovered, lost, or returned to vendor?';
COMMENT ON COLUMN device_deployment_recovery.embargo_datetime IS 'Embargo date and time (UTC). Null if device.device_type = `Receiver`. Check constraint implemented to limit the time a given device deployment can be embargoed for';

-- animal_capture
COMMENT ON TABLE animal_capture IS 'Information about animal capture and release';
COMMENT ON COLUMN animal_capture.id IS 'Animal capture ID (unique). Primary key';
COMMENT ON COLUMN animal_capture.platform_id IS 'Platform ID. Foreign key to platform table';
COMMENT ON COLUMN animal_capture.catcher_id IS 'ID of the person who captured the animal. Foreign key to users table';
COMMENT ON COLUMN animal_capture.capture_number IS 'Implement code to increment this number automatically when same animal is re-captured';
COMMENT ON COLUMN animal_capture.capture_locality IS 'Locality, State/Territory, Country of capture. Controlled vocabulary required, could be using entries from the Geonames database, http://www.geonames.org/';
COMMENT ON COLUMN animal_capture."capture_decimalLatitude" IS 'Capture latitude, in decimal format and degree North. A value between -90 and 90 decimal degrees North';
COMMENT ON COLUMN animal_capture."capture_decimalLongitude" IS 'Capture longitude, in decimal format and degree East. A value between -180 and 180 decimal degrees East';
COMMENT ON COLUMN animal_capture.capture_datetime IS 'Date and time (UTC) of capture. A value not greater than today`s date';
COMMENT ON COLUMN animal_capture.capture_comments IS 'e.g. caught after nesting, anesthetic used and dosage';
COMMENT ON COLUMN animal_capture.release_locality IS 'Locality, State/Territory, Country of release. Controlled vocabulary required, could be using entries from the Geonames database, http://www.geonames.org/';
COMMENT ON COLUMN animal_capture."release_decimalLatitude" IS 'Release latitude, in decimal format and degree North. A value between -90 and 90 decimal degrees North';
COMMENT ON COLUMN animal_capture."release_decimalLongitude" IS 'Release longitude, in decimal format and degree East. A value between -180 and 180 decimal degrees East';
COMMENT ON COLUMN animal_capture.release_datetime IS 'Date and time (UTC) of release. A value not greater than today`s date and greater than capture_datetime';
COMMENT ON COLUMN animal_capture.release_comments IS 'e.g. animal lethargic, behaviour at release';
COMMENT ON COLUMN animal_capture.tag_status IS 'e.g. new, damaged, recovered';

-- animal_measurements
COMMENT ON TABLE animal_measurements IS 'Lists all morphological measurements taken when the animal was captured';
COMMENT ON COLUMN animal_measurements.id IS 'Animal measurement ID (unique). Primary key';
COMMENT ON COLUMN animal_measurements.capture_id IS 'Animal capture ID. Foreign key to animal_capture table';
COMMENT ON COLUMN animal_measurements.type IS 'Type of measurement (e.g. length, weight, total length, carapace length, carapace width, fork length, width). Controlled vocabulary required';
COMMENT ON COLUMN animal_measurements.unit IS 'Unit of measurement (e.g. mm, cm, m, g, kg). Controlled vocabulary required';
COMMENT ON COLUMN animal_measurements.value IS 'Measurement value';
COMMENT ON COLUMN animal_measurements.estimate IS 'Is the measurement value an estimate?';
COMMENT ON COLUMN animal_measurements.comments IS 'Additional information on each measurement';

-- animal_observations
COMMENT ON TABLE animal_observations IS 'Lists all observations and samples taken for each tagged animal';
COMMENT ON COLUMN animal_observations.id IS 'Animal observation ID (unique). Primary key';
COMMENT ON COLUMN animal_observations.capture_id IS 'Animal capture ID. Foreign key to animal_capture table';
COMMENT ON COLUMN animal_observations."lifeStage" IS 'Animal life stage (e.g. adult, juvenile, subadult, weaner). Controlled vocabulary required';
COMMENT ON COLUMN animal_observations."ageUnit" IS 'Unit of age (e.g. days, months, years). Controlled vocabulary required';
COMMENT ON COLUMN animal_observations.value IS 'Age of animal';
COMMENT ON COLUMN animal_observations.estimate IS 'Is the age value an estimate?';
COMMENT ON COLUMN animal_observations."DNA_sample_id" IS 'ID of DNA sample, if any taken';
COMMENT ON COLUMN animal_observations."mRNA_sample_id" IS 'ID of mRNA sample, if any taken';
COMMENT ON COLUMN animal_observations.genetic_sample_location IS 'Where was the genetic sample taken from on the animal? Check constraint required';
COMMENT ON COLUMN animal_observations.conventional_tag_numbers IS 'IDs of conventional tag(s) attached, if any';
COMMENT ON COLUMN animal_observations.conventional_tag_locations IS 'Where were conventional tags attached on the animal? Check constraint required';
COMMENT ON COLUMN animal_observations.comments IS 'e.g. animal origin (i.e. wild, hatchery), stock, injuries, ultrasound or laparoscopy examinations?';


---- Monitoring Tables
-- activity_log
COMMENT ON TABLE activity_log IS 'Lists modifications made by users through the GUI to metadata tables';
COMMENT ON COLUMN activity_log.id IS 'Activity log ID (unique). Primary key';
COMMENT ON COLUMN activity_log.user_id IS 'ID of the user who made the modification. Foreign key to users table';
COMMENT ON COLUMN activity_log.class_name IS 'Name of the table that was modified';
COMMENT ON COLUMN activity_log.property_name IS 'Name of the column that was modified';
COMMENT ON COLUMN activity_log.persisted_object_id IS 'Row number where the modification was made';
COMMENT ON COLUMN activity_log.event_type IS 'Type of modification made: i.e. delete, insert, or update';
COMMENT ON COLUMN activity_log.modification_datetime IS 'Date and time (UTC) of modification';
COMMENT ON COLUMN activity_log.new_value IS 'Value after modification was made';
COMMENT ON COLUMN activity_log.old_value IS 'Value before modification was made';

-- uploaded_file
COMMENT ON TABLE uploaded_file IS 'Lists all files uploaded by users. Can be data files, photographs/videos (e.g. tagged animals, devices), processing scripts, firmware/software specification file';
COMMENT ON COLUMN uploaded_file.id IS 'File ID (unique). Primary key';
COMMENT ON COLUMN uploaded_file.user_id IS 'ID of the user who uploaded the file. Foreign key to users table';
COMMENT ON COLUMN uploaded_file.file_type IS 'Type of file uploaded, e.g. detections/events, gps, gls, argos, photograph, footage, platform positions (e.g. glider, AUV), data processing scripts, device configuration file';
COMMENT ON COLUMN uploaded_file.file_name IS 'Name of file uploaded. Could also extract file size, MD5sum, etc.';
COMMENT ON COLUMN uploaded_file.class_name IS 'Which table does the uploaded file refer to? e.g. device, device_predeployment_specifications, device_deployment_recovery, platform, animal_capture. NULL if file uploaded was a data file';
COMMENT ON COLUMN uploaded_file.persisted_object_id IS 'Which id in the above table does the uploaded file refer to? NULL if file uploaded was a data file';
COMMENT ON COLUMN uploaded_file.comments IS 'Additional information about the uploaded file, e.g. high resolution data file for data previously uploaded, time-drift corrected data';
COMMENT ON COLUMN uploaded_file.upload_datetime IS 'Date and time (UTC) of file upload';
COMMENT ON COLUMN uploaded_file.status IS 'i.e. Processed, processing, or error';
COMMENT ON COLUMN uploaded_file.err_msg IS 'Potential error message from file checkers';



---- Data Tables
-- gps_locations
COMMENT ON TABLE gps_locations IS 'Provides animal location data and diagnostic information obtained using the Fastloc GPS technology';
COMMENT ON COLUMN gps_locations.id IS 'GPS location ID (unique), self-generated during data import. Primary key';
COMMENT ON COLUMN gps_locations.file_id IS 'Corresponding file ID. Foreign key to uploaded_file table';
COMMENT ON COLUMN gps_locations.device_name IS 'The `device_name` value needs to match the content of the `device_name` field in the device_predeployment_specifications table for data to be joined to metadata';
COMMENT ON COLUMN gps_locations.timestamp IS 'Date and time (UTC) of the GPS location. A value not greater than today`s date';
COMMENT ON COLUMN gps_locations."decimalLatitude" IS 'Latitude, in decimal format and degree North. A value between -90 and 90 decimal degrees North';
COMMENT ON COLUMN gps_locations."decimalLongitude" IS 'Longitude, in decimal format and degree East. A value between -180 and 180 decimal degrees East';
COMMENT ON COLUMN gps_locations.nsats_detected IS 'Field still to be defined';
COMMENT ON COLUMN gps_locations.nsats_transmitted IS 'Field still to be defined';
COMMENT ON COLUMN gps_locations.pseudoranges IS 'Field still to be defined';
COMMENT ON COLUMN gps_locations.max_csn IS 'Field still to be defined';
COMMENT ON COLUMN gps_locations.residual IS 'Field still to be defined';
COMMENT ON COLUMN gps_locations.timeshift IS 'Field still to be defined';
COMMENT ON COLUMN gps_locations.duplicate IS 'Does this GPS location already exist in this table? A PostgreSQL function flags this field as TRUE if the combination of `device_name` and `timestamp` is found multiple times';

-- argos_locations
COMMENT ON TABLE argos_locations IS 'Provides animal location data and diagnostic information obtained using the Argos technology';
COMMENT ON COLUMN argos_locations.id IS 'Argos location ID (unique), self-generated during data import. Primary key';
COMMENT ON COLUMN argos_locations.file_id IS 'Corresponding file ID. Foreign key to uploaded_file table';
COMMENT ON COLUMN argos_locations.device_name IS 'The `device_name` value needs to match the content of the `device_name` field in the device_predeployment_specifications table for data to be joined to metadata';
COMMENT ON COLUMN argos_locations.timestamp IS 'Date and time (UTC) of the Argos location. A value not greater than today`s date';
COMMENT ON COLUMN argos_locations."decimalLatitude" IS 'Latitude, in decimal format and degree North. A value between -90 and 90 decimal degrees North';
COMMENT ON COLUMN argos_locations."decimalLongitude" IS 'Longitude, in decimal format and degree East. A value between -180 and 180 decimal degrees East';
COMMENT ON COLUMN argos_locations.location_quality IS 'Location Quality assigned by Argos (-1 = class A, -2 = class B, 9 = class Z). Controlled vocabulary required';
COMMENT ON COLUMN argos_locations.alt_latitude IS 'Alternative solution to position equations, in decimal format and degree North';
COMMENT ON COLUMN argos_locations.alt_longitude IS 'Alternative solution to position equations, in decimal format and degree East';
COMMENT ON COLUMN argos_locations.n_mess IS 'Number of uplinks received during the satellite pass';
COMMENT ON COLUMN argos_locations.n_mess_120 IS 'Number of uplinks received with signal strength > -120 dB';
COMMENT ON COLUMN argos_locations.best_level IS 'Signal strength of strongest uplink (dB)';
COMMENT ON COLUMN argos_locations.pass_dur IS 'Duration of satellite overpass (seconds)';
COMMENT ON COLUMN argos_locations.freq IS 'Measured frequency of SRDL signal at the satellite (Hz)';
COMMENT ON COLUMN argos_locations.duplicate IS 'Does this Argos location already exist in this table? A PostgreSQL function flags this field as TRUE if the combination of `device_name` and `timestamp` is found multiple times';

-- gls_locations
COMMENT ON TABLE gls_locations IS 'Provides animal location data using light level sensor tags';
COMMENT ON COLUMN gls_locations.id IS 'GLS location ID (unique), self-generated during data import. Primary key';
COMMENT ON COLUMN gls_locations.file_id IS 'Corresponding file ID. Foreign key to uploaded_file table';
COMMENT ON COLUMN gls_locations.device_name IS 'The `device_name` value needs to match the content of the `device_name` field in the device_predeployment_specifications table for data to be joined to metadata';
COMMENT ON COLUMN gls_locations.timestamp IS 'Date and time (UTC) of the GLS location. A value not greater than today`s date';
COMMENT ON COLUMN gls_locations."decimalLatitude" IS 'Latitude, in decimal format and degree North. A value between -90 and 90 decimal degrees North';
COMMENT ON COLUMN gls_locations."decimalLongitude" IS 'Longitude, in decimal format and degree East. A value between -180 and 180 decimal degrees East';
COMMENT ON COLUMN gls_locations.duplicate IS 'Does this GLS location already exist in this table? A PostgreSQL function flags this field as TRUE if the combination of `device_name` and `timestamp` is found multiple times';

-- acoustic_detections
COMMENT ON TABLE acoustic_detections IS 'Provides animal location data and sensor values obtained from acoustic receivers';
COMMENT ON COLUMN acoustic_detections.id IS 'Acoustic detection ID (unique), self-generated during data import. Primary key';
COMMENT ON COLUMN acoustic_detections.file_id IS 'Corresponding file ID. Foreign key to uploaded_file table';
COMMENT ON COLUMN acoustic_detections.receiver_name IS 'Name of receiver on which transmitter was detected. The `receiver_name` value needs to match the content of the `device_name` field in the device_predeployment_specifications table for data to be joined to metadata';
COMMENT ON COLUMN acoustic_detections.transmitter_id IS 'ID of the transmitter which was detected. The `transmitter_id` value needs to match the content of the `device_name` field in the device_predeployment_specifications table for data to be joined to metadata';
COMMENT ON COLUMN acoustic_detections.timestamp IS 'Date and time (UTC) of the acoustic detection. A value not greater than today`s date';
COMMENT ON COLUMN acoustic_detections.sensor_value IS 'Value recorded by the sensor tag. Check constraint required';
COMMENT ON COLUMN acoustic_detections.sensor_unit IS 'Corresponding unit for the sensor_value. Check constraint required';
COMMENT ON COLUMN acoustic_detections.duplicate IS 'Does this acoustic detection already exist in this table? A PostgreSQL function flags this field as TRUE if the combination of `transmitter_id`, `receiver_name`, and `timestamp` is found multiple times';

-- platform_locations
COMMENT ON TABLE platform_locations IS 'Provides location data for gliders, AUVs, drifters, or vessels';
COMMENT ON COLUMN platform_locations.id IS 'Platform location ID (unique), self-generated during data import. Primary key';
COMMENT ON COLUMN platform_locations.file_id IS 'Corresponding file ID. Foreign key to uploaded_file table';
COMMENT ON COLUMN platform_locations.platform_name IS 'The `platform_name` value needs to match the content of the `platform_name` field in the platform table for data to be joined to metadata';
COMMENT ON COLUMN platform_locations.timestamp IS 'Date and time (UTC) of the platform location. A value not greater than today`s date';
COMMENT ON COLUMN platform_locations."decimalLatitude" IS 'Latitude, in decimal format and degree North. A value between -90 and 90 decimal degrees North';
COMMENT ON COLUMN platform_locations."decimalLongitude" IS 'Longitude, in decimal format and degree East. A value between -180 and 180 decimal degrees East';
COMMENT ON COLUMN platform_locations.duplicate IS 'Does this platform location already exist in this table? A PostgreSQL function flags this field as TRUE if the combination of `platform_name` and `timestamp` is found multiple times';


-- List comments on table and columns for a given table
SELECT ('biologging.device_predeployment_specifications'::regclass)::text AS table_name, 
	NULL AS column_name, 
    (obj_description('biologging.device_predeployment_specifications'::regclass, 'pg_class'))::text AS description
UNION ALL
SELECT
	cols.table_name,
    cols.column_name,
    (SELECT pg_catalog.col_description(c.oid, cols.ordinal_position::int)
        FROM pg_catalog.pg_class c
        WHERE c.oid = (SELECT cols.table_name::regclass::oid) AND c.relname = cols.table_name) as description
FROM information_schema.columns cols
WHERE cols.table_schema = 'biologging' AND cols.table_name = 'device_predeployment_specifications'; 