## Synopsis

Following the Animal Telemetry Data & Metadata Meeting held in Halifax on July 14 2015 one action item was to develop a data and metadata template for archival and satellite telemetry projects that could be used to share data easily across organizations. 

## Infrastructure

This repository holds the PostgreSQL queries used to create the database schema and tables supporting the management of archival and satellite tagging data and metadata. Eventually we propose that a web application similar to the AATAMS user interface (https://github.com/aodn/aatams/) be built on top of that database schema for users to enter metadata, upload data, and search, filter and download data.

## Motivation

The need for such a data sharing standard has become obvious due to a growing number of projects (e.g. TOPP, POST, AATAMS) collecting important volumes of archival and satellite telemetry data (Kranstauber et al. 2011, Campbell et al. 2015, Dwyer et al. 2015, Campbell et al. 2016), which are more likely to result in the publication of articles in high impact factor journals (Block et al. 2011, Hussey et al. 2015, Kays et al. 2015). 

The standard proposed here is primarily based on the metadata convention developed for acoustic telemetry projects (Payne et al. 2013) and the structure of the AATAMS database (AATAMS 2015), with additional metadata information gathered from various projects (e.g. OTN, TOPP, Movebank) (Kranstauber et al. 2011). The present convention follows the nomenclature used in Payne et al. (2013) with database fields flagged as ‘required’ or ‘optional’ so that data users will be able to get a minimum amount of viable information for each dataset. Constraints and relationships between database tables are indicated to highlight how information from different tables can be joined together. For additional database related logic, refer to Payne et al. (2013). The proposed tables were designed using the PostgreSQL database language and the PostGIS extension to convert longitude/latitude coordinates into geometries.

## References
AATAMS (2015) The Australian Animal Tracking and Monitoring System (AATAMS) National Database Web Application. Accessed 11 November 2015. https://aatams.emii.org.au/aatams
Block BA, Jonsen ID, Jorgensen SJ, Winship AJ, Shaffer SA, Bograd SJ, Hazen EL, Foley DG, Breed GA, Harrison AL, Ganong JE, Swithenbank A, Castleton M, Dewar H, Mate BR, Shillinger GL, Schaefer KM, Benson SR, Weise MJ, Henry RW, Costa DP (2011) Tracking apex marine predator movements in a dynamic ocean. Nature 475:86-90
Campbell HA, Beyer HL, Dennis TE, Dwyer RG, Forester JD, Fukuda Y, Lynch C, Hindell MA, Menke N, Morales JM, Richardson C, Rodgers E, Taylor G, Watts ME, Westcott DA (2015) Finding our way: On the sharing and reuse of animal telemetry data in Australasia. Science of The Total Environment 534:79-84
Campbell HA, Urbano F, Davidson S, Dettki H, Cagnacci F (2016) A plea for standards in reporting data collected by animal-borne electronic devices. Animal Biotelemetry 4:1-4
Dwyer RG, Brooking C, Brimblecombe W, Campbell HA, Hunter J, Watts M, Franklin CE (2015) An open Web-based system for the analysis and sharing of animal tracking data. Animal Biotelemetry 3:1-11
Hussey NE, Kessel ST, Aarestrup K, Cooke SJ, Cowley PD, Fisk AT, Harcourt RG, Holland KN, Iverson SJ, Kocik JF, Mills Flemming JE, Whoriskey FG (2015) Aquatic animal telemetry: A panoramic window into the underwater world. Science 348
Kays R, Crofoot MC, Jetz W, Wikelski M (2015) Terrestrial animal tracking as an eye on life and planet. Science 348
Kranstauber B, Cameron A, Weinzerl R, Fountain T, Tilak S, Wikelski M, Kays R (2011) The Movebank data model for animal tracking. Environmental Modelling & Software 26:834-835
Payne J, Moustahfid H, Mayorga E, Branton R, Mihoff M, Bajona L (2013) A metadata convention for animal acoustic telemetry data. http://ioostech.googlecode.com/files/AAT Metadata Convention v1.2.pdf