set search_path = biologging, public;

------------------------------
-- Test inserts for one animal
INSERT INTO organisation
VALUES (1,'IMAS','Marine mammal dept','+61362261752','Castray Esplanade');

INSERT INTO users
VALUES (1,1,'Clive McMahon','cmcmahon@utas.edu.au','+61362261893');

INSERT INTO datacenter
VALUES (1,1,'IMOS','IMOS is a national collaborative project','','','','','2015-11-05');

INSERT INTO project
VALUES (1,1,'Satellite tagging of fur seals','Blablab','BlaBla','http://www.','','','','2015-11-05', ST_MAKEPOINT(155,-35), '2010-01-10','2010-07-20');

INSERT INTO project_role
VALUES (1,1,1,'Principal Investigator');

INSERT INTO device
VALUES (26113,'ct100-261-13',1,'SMRU SRDL CTD','SMRU','SRDL CTD','274602042187498','12261','Q113403','http://www.smru.');

INSERT INTO instruments
VALUES (1,26113,'v.9.2','v.2.4','dives start below 6m',TRUE,TRUE,FALSE,TRUE,FALSE,FALSE,FALSE,FALSE,TRUE,FALSE,FALSE,NULL,TRUE);

INSERT INTO species
VALUES (1,279,'Animalia','','','','','','','','','Chelonia mydas','','green turtle','','2005-01-01');

INSERT INTO animal (id, unique_id, species_id, sex, "lifeStage")
VALUES (1,'Mama Betsy',1,'Female', 'Adult');

INSERT INTO animal_release
VALUES (27,1,1,'Groote Eylandt',ST_MAKEPOINT(137,-12),'2009-08-06','Groote Eylandt',ST_MAKEPOINT(137,-12),'2009-08-06','DNA, titanium tags, CCL, CCW, Weight',NULL,'',NULL,NULL,'');

INSERT INTO surgery
VALUES (1,26113,27,'glued onto head','');

INSERT INTO animal_measurement
VALUES (1,1,'Length','cm',98,FALSE,'');

-- Select statement to extract info
  SELECT animal.unique_id, 
	species."vernacularName", 
	animal.sex, 
	animal."lifeStage", 
	device.tag_id, 
	device.device_type,
	animal_release.deployment_locality,
	animal_release.deployment_datetime,
	animal_release.recovery_locality,
	animal_release.recovery_datetime,
	project.title, 
	datacenter.title,
	instruments.*,
	users.name,
	organisation.name
  FROM device
  JOIN instruments ON device.id = instruments.device_id
  JOIN project ON project.id = device.project_id
  JOIN project_role ON project_role.project_id = project.id
  JOIN users ON users.id = project_role.user_id
  JOIN datacenter ON datacenter.id = project.datacenter_id
  JOIN organisation ON organisation.id = users.organisation_id
  JOIN surgery ON surgery.device_id = device.id
  JOIN animal_release ON animal_release.id = surgery.release_id
  JOIN animal ON animal.id = animal_release.animal_id
  JOIN species ON species.id = animal.species_id;


------------------------------
-- Test inserts for one animal but two devices deployed
INSERT INTO device
VALUES (26114,'ct100-261-14',1,'SMRU SRDL CTD','SMRU','SRDL CTD','274602042187499','12262','Q113404','http://www.smru.'),
(975,'SR208',1,'VEMCO minilog temperature logger','VEMCO','VM27','2956273593',NULL,NULL,'http://www.vemco.com');

INSERT INTO instruments
VALUES (2,26114,'v.9.2','v.2.4','dives start below 6m',TRUE,TRUE,FALSE,TRUE,FALSE,FALSE,FALSE,FALSE,TRUE,FALSE,FALSE,NULL,TRUE),
(3,975,'v.1.2','v.3.5','sampling frequency = 10 minutes',FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,FALSE,FALSE,FALSE,NULL,FALSE);

INSERT INTO animal (id, unique_id, species_id, sex, "lifeStage")
VALUES (2,'Sally',1,'Female', 'Adult');

INSERT INTO animal_release
VALUES (28,2,1,'Groote Eylandt',ST_MAKEPOINT(137,-12),'2009-08-07','Groote Eylandt',ST_MAKEPOINT(137,-12),'2009-08-07','DNA, titanium tags, CCL, CCW',NULL,'',NULL,NULL,'');

INSERT INTO surgery
VALUES (2,26114,28,'glued onto head',''),
(3,975,28,'swollen','');

INSERT INTO animal_measurement
VALUES (2,2,'Weigth','kg',45,TRUE,'');

-- Select statement to extract info
  SELECT animal.unique_id, 
	species."vernacularName", 
	animal.sex, 
	animal."lifeStage", 
	device.tag_id, 
	device.device_type,
	animal_release.deployment_locality,
	animal_release.deployment_datetime,
	animal_release.recovery_locality,
	animal_release.recovery_datetime,
	project.title, 
	datacenter.title,
	instruments.*,
	users.name,
	organisation.name
  FROM device
  JOIN instruments ON device.id = instruments.device_id
  JOIN project ON project.id = device.project_id
  JOIN project_role ON project_role.project_id = project.id
  JOIN users ON users.id = project_role.user_id
  JOIN datacenter ON datacenter.id = project.datacenter_id
  JOIN organisation ON organisation.id = users.organisation_id
  JOIN surgery ON surgery.device_id = device.id
  JOIN animal_release ON animal_release.id = surgery.release_id
  JOIN animal ON animal.id = animal_release.animal_id
  JOIN species ON species.id = animal.species_id
  WHERE animal.unique_id = 'Sally';