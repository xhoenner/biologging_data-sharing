INSERT INTO organisation
VALUES (1,'IMAS','Marine mammal dept','+61362261752','Castray Esplanade');

INSERT INTO users
VALUES (1,1,'Clive McMahon','cmcmahon@utas.edu.au','+61362261893');

INSERT INTO datacenter
VALUES (1,1,'IMOS','IMOS is a national collaborative project','','','','','','2015-11-05');

INSERT INTO project
VALUES ('ct100',1,1,'Satellite tagging of fur seals','Blablab','BlaBla','http://www.','','','','','2015-11-05', ST_MAKEPOINT(155,-35), '2010-01-10','2010-07-20');

INSERT INTO device
VALUES ('ct100-261-13','ct100','SMRU SRDL CTD','SMRU','SRDL CTD','12261','113403','','http://www.smru.','dives start below 6m',TRUE,TRUE,FALSE,TRUE,FALSE,FALSE,FALSE,FALSE,TRUE,FALSE,FALSE,TRUE);

INSERT INTO species
VALUES (1, '','','','','','','','','Australian fur seal','','2010-11-10');

INSERT INTO animal (id, unique_id, species_id, sex, life_stage, release_locality, release_location, release_datetime)
VALUES (1,'Q9204729',1,'Female', 'Adult','Montague Island', ST_MAKEPOINT(155,-35), '2010-01-09');

INSERT INTO tag_deployment (id, device_id, animal_id, tagger_id, attachment_method)
VALUES (1, 'ct100-261-13', 1, 1, 'glued onto head');

INSERT INTO animal_measurement
VALUES (1,1,'Length','cm',98,FALSE,'');