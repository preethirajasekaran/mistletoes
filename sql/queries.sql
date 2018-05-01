SELECT * FROM `site`
DELETE FROM `site` WHERE `site_info`.`site_name_key`='n/a'
DELETE FROM `site` WHERE `site_info.site_name_key`='n/a'
Expand  Requery  Edit  Explain  Profiling  Bookmark  Database : project  Queried time : 8:20:36
SELECT * FROM `site`
SELECT * FROM `site` WHERE `site_info._gps_site_latitude`='n/a'
SELECT * FROM `site`
SELECT * FROM `site`
SELECT * FROM `site`
SELECT * FROM `site` WHERE `site_info._gps_site_latitude`=n/a
SELECT * FROM `site`
SELECT * FROM `site` WHERE `site_info._gps_site_latitude`='n/a'
DELETE FROM `site` WHERE `site_info._gps_site_latitude`='n/a'
SELECT * FROM `site`
SELECT DISTINCT `site_info.site_name_key`,`site_info.plot_name_key`,`site_info.site_type` FROM `site`
SELECT * FROM `site`
SELECT DISTINCT `site_info.site_name_key`,`site_info.plot_name_key`,`site_info.site_type`,`site_info.site_stature`,`site_info .site_soil` FROM `site`
SELECT DISTINCT `site_info.site_name_key`,`site_info.plot_name_key`,`site_info.site_type`,`site_info.site_stature`,`site_info .site_soil` FROM `site`
SELECT DISTINCT `site_info.site_name_key`,`site_info.plot_name_key`,`site_info.site_type`,`site_info.site_stature`,
SELECT DISTINCT `site_info.site_name_key`,`site_info.plot_name_key`,`site_info.site_type`,`site_info.site_stature`,`site_info.site_soil` FROM `site`
CREATE TABLE sub_site AS (SELECT DISTINCT `site_info.site_name_key`,`site_info.plot_name_key` FROM `site`)
SELECT * FROM `sub_site`
CREATE TABLE sub_site AS SELECT DISTINCT  (`site_info.site_name_key`,`site_info.plot_name_key`),`site_info.site_type`,`site_info.site_stature`,`site_info.site_soil` FROM `site` GROUP BY `site_info.site_name_key`,`site_info.plot_name_key`

CREATE TABLE sub_site AS SELECT `site_info.site_name_key`,`site_info.plot_name_key`,`site_info.site_type`,`site_info.site_stature`,`site_info.site_soil` FROM `site` GROUP BY  `site_info.site_name_key`,`site_info.plot_name_key`

ALTER TABLE `hosts` ADD `gbh` DOUBLE(5,2) NOT NULL AFTER `gbh5`;
UPDATE `hosts` SET gbh=sqrt(pow(gbh1,2)+pow(gbh2,2)+pow(gbh3,2)+pow(gbh4,2)+pow(gbh5,2))
ALTER TABLE `hosts` MODIFY gbh DOUBLE(5,2);
ALTER TABLE `hosts` DROP COLUMN gbh1, DROP COLUMN gbh2,DROP COLUMN gbh3,DROP COLUMN gbh4,DROP COLUMN gbh5;

ALTER TABLE `host` ADD `count` INT NOT NULL AFTER `gbh`;
UPDATE `rawdata` SET `rawdata`.count=0 WHERE `rawdata`.infest=0;

UPDATE `rawdata` SET `rawdata`.count=(SELECT COUNT(*) FROM `rawdata` AS raw GROUP BY raw.site,raw.plot,raw.host,raw.gbh1,raw.gbh2,raw.gbh3,raw.gbh4,raw.gbh5,raw.infest) WHERE `rawdata`.infest=1;

--118
SELECT *,COUNT(*) AS thecount FROM `rawdata` AS raw WHERE raw.infest=1 GROUP BY raw.site,raw.plot,raw.host,raw.gbh1,raw.gbh2,raw.gbh3,raw.gbh4,raw.gbh5,raw.infest

INSERT INTO `rawdata_backup` (SELECT *,COUNT(*) AS thecount FROM `rawdata` AS raw WHERE raw.infest=1 GROUP BY raw.site,raw.plot,raw.host,raw.gbh1,raw.gbh2,raw.gbh3,raw.gbh4,raw.gbh5,raw.infest)

INSERT INTO `rawdata_backup` (SELECT *,0 FROM `rawdata` AS raw WHERE raw.infest=2 GROUP BY raw.site,raw.plot,raw.host,raw.gbh1,raw.gbh2,raw.gbh3,raw.gbh4,raw.gbh5,raw.infest)

UPDATE `rawdata` SET `rawdata`.count=(SELECT COUNT(*) FROM (SELECT DISTINCT site,plot,host,gbh1,gbh2,gbh3,gbh4,gbh5,infest FROM `rawdata` WHERE `rawdata`.infest=1) AS RAW;

DELETE FROM `rawdata_backup`;

SELECT COUNT(*) FROM `rawdata` WHERE infest=1 GROUP BY site,plot,host,gbh1,gbh2,gbh3,gbh4,gbh5
SELECT site,plot,host,gbh1,gbh2,gbh3,gbh4,gbh5,infest,biomass,COUNT(*) FROM `rawdata` WHERE infest=1 GROUP BY site,plot,host,gbh1,gbh2,gbh3,gbh4,gbh5

CREATE TABLE `hosts_backup` AS SELECT * FROM `hosts`
CREATE TABLE `rawdata_backup` AS SELECT * FROM `rawdata`

INSERT INTO `sub_site` SELECT * FROM `sub_site` WHERE `site_info.plot_name_key`='plot1';
INSERT INTO sub_site VALUES('aranya','plot2','2','2','1')

INSERT INTO sub_site VALUES('aranya','plot3','2','2','1')
INSERT INTO sub_site VALUES('aranya','plot4','2','2','1')
INSERT INTO sub_site VALUES('aranya','plot5','2','2','1')
INSERT INTO sub_site VALUES('aranya','plot6','2','2','1')
INSERT INTO sub_site VALUES('aranya','plot7','2','2','1')
INSERT INTO sub_site VALUES('aranya','plot8','2','2','1')
INSERT INTO sub_site VALUES('aranya','plot9','2','2','1')
INSERT INTO sub_site VALUES('aranya','plot10','2','2','1')
INSERT INTO sub_site VALUES('aranya','plot11','2','2','1')
INSERT INTO sub_site VALUES('aranya','plot12','2','2','1')
INSERT INTO sub_site VALUES('aranya','plot13','2','2','1')
INSERT INTO sub_site VALUES('aranya','plot14','2','2','1')
INSERT INTO sub_site VALUES('aranya','plot15','2','2','1')

ALTER TABLE `hosts` CHANGE `count` `count_parasite` BIGINT(20) NULL DEFAULT NULL;
ALTER TABLE `sub_site` ADD `trees_count` INT(3) NOT NULL AFTER `site_info.plot_name_key`, ADD `trees_infected` INT(3) NOT NULL AFTER `trees_count`, ADD `trees_not_infected` INT(3) NOT NULL AFTER `trees_infected`;

ALTER IGNORE TABLE `host` ADD UNIQUE INDEX index_name(site,plot,host,gbh)

UPDATE `sub_site` SET trees_count=COUNT(SELECT h.* FROM hosts_backup h,sub_site s WHERE h.`plot`=s.`site_info.plot_name_key` GROUP BY h.`host`,h.`plot`);

SELECT h.* FROM hosts_backup h,sub_site s WHERE h.`plot`=s.`site_info.plot_name_key` GROUP BY h.`host`,h.`plot`
SELECT * FROM hosts_backup h,sub_site s WHERE h.`plot`=s.`site_info.plot_name_key` GROUP BY h.`host`
SELECT * FROM hosts_backup h,sub_site s WHERE h.`plot`=s.`site_info.plot_name_key` GROUP BY h.`plot`

SELECT h.`host`,COUNT(*) FROM hosts h GROUP BY h.`host`;
SELECT h.`host`,COUNT(*) FROM hosts h WHERE h.`count_parasite`>=1 GROUP BY h.`host`;

ALTER TABLE `species` ADD `total_individuals` INT(3) NOT NULL AFTER `physiognomy`, ADD `infected_individuals` INT(3) NOT NULL AFTER `total_individuals`, ADD `noninfected_individuals` INT(3) NOT NULL AFTER `infected_individuals`;
ALTER TABLE `species` ADD `abundance_ratio` DOUBLE(5,2) NOT NULL AFTER `noninfected_individuals`;

UPDATE `species` SET `total_individuals`=58,`infected_individuals`=21,`noninfected_individuals`=37 WHERE species_name='Acacia auriculiformis';
UPDATE `species` SET `total_individuals`=25,`infected_individuals`=11,`noninfected_individuals`=14 WHERE species_name='Acacia chundra';
UPDATE `species` SET `total_individuals`=89,`infected_individuals`=27,`noninfected_individuals`=62 WHERE species_name='Acacia holosericea';
UPDATE `species` SET `total_individuals`=56,`infected_individuals`=7,`noninfected_individuals`=49 WHERE species_name='Acacia mangium';
UPDATE `species` SET `total_individuals`=10,`infected_individuals`=0,`noninfected_individuals`=10 WHERE species_name='Adenanthera pavonina';
UPDATE `species` SET `total_individuals`=1,`infected_individuals`=0,`noninfected_individuals`=1 WHERE species_name='Aegle marmelos';
UPDATE `species` SET `total_individuals`=2,`infected_individuals`=0,`noninfected_individuals`=2 WHERE species_name='Albizia amara';
UPDATE `species` SET `total_individuals`=16,`infected_individuals`=6,`noninfected_individuals`=10 WHERE species_name='Albizia lebbeck';
UPDATE `species` SET `total_individuals`=2,`infected_individuals`=0,`noninfected_individuals`=2 WHERE species_name='Atalantia monophylla';
UPDATE `species` SET `total_individuals`=20,`infected_individuals`=0,`noninfected_individuals`=20 WHERE species_name='Azadirachta indica';
UPDATE `species` SET `total_individuals`=3,`infected_individuals`=1,`noninfected_individuals`=29 WHERE species_name='Barringtonia acutangala';
UPDATE `species` SET `total_individuals`=10,`infected_individuals`=0,`noninfected_individuals`=10 WHERE species_name='Bauhinia racemosa';
UPDATE `species` SET `total_individuals`=5,`infected_individuals`=0,`noninfected_individuals`=5 WHERE species_name='Benkara malabarica';
UPDATE `species` SET `total_individuals`=2,`infected_individuals`=0,`noninfected_individuals`=2 WHERE species_name='Borassus flabellifer';
UPDATE `species` SET `total_individuals`=52,`infected_individuals`=16,`noninfected_individuals`=36 WHERE species_name='Bridelia retusa';
UPDATE `species` SET `total_individuals`=9,`infected_individuals`=0,`noninfected_individuals`=9 WHERE species_name='Butea monosperma';
UPDATE `species` SET `total_individuals`=4,`infected_individuals`=0,`noninfected_individuals`=4 WHERE species_name='Canthium coromandelicum';
UPDATE `species` SET `total_individuals`=1,`infected_individuals`=0,`noninfected_individuals`=1 WHERE species_name='Carissa spinarum';
UPDATE `species` SET `total_individuals`=4,`infected_individuals`=0,`noninfected_individuals`=4 WHERE species_name='Carmona retusa';
UPDATE `species` SET `total_individuals`=9,`infected_individuals`=0,`noninfected_individuals`=9 WHERE species_name='Cassia fistula';
UPDATE `species` SET `total_individuals`=1,`infected_individuals`=1,`noninfected_individuals`=0 WHERE species_name='Cassia siamea';
UPDATE `species` SET `total_individuals`=13,`infected_individuals`=5,`noninfected_individuals`=8 WHERE species_name='Casuarina equisetifolia';
UPDATE `species` SET `total_individuals`=2,`infected_individuals`=0,`noninfected_individuals`=2 WHERE species_name='Chloroxylon swietenia';
UPDATE `species` SET `total_individuals`=4,`infected_individuals`=0,`noninfected_individuals`=4 WHERE species_name='Cleistanthus collinus';
UPDATE `species` SET `total_individuals`=10,`infected_individuals`=0,`noninfected_individuals`=10 WHERE species_name='Cochlospermum religiosa';
UPDATE `species` SET `total_individuals`=4,`infected_individuals`=0,`noninfected_individuals`=4 WHERE species_name='Diospyros montana';
UPDATE `species` SET `total_individuals`=74,`infected_individuals`=3,`noninfected_individuals`=71 WHERE species_name='Dodonaea angustifolia';
UPDATE `species` SET `total_individuals`=12,`infected_individuals`=0,`noninfected_individuals`=12 WHERE species_name='Dolichandrone falcata';
UPDATE `species` SET `total_individuals`=3,`infected_individuals`=0,`noninfected_individuals`=3 WHERE species_name='Erythroxylum monogynum';
UPDATE `species` SET `total_individuals`=5,`infected_individuals`=2,`noninfected_individuals`=3 WHERE species_name='Ficus benghalensis';
UPDATE `species` SET `total_individuals`=1,`infected_individuals`=0,`noninfected_individuals`=1 WHERE species_name='Ficus religiosa';
UPDATE `species` SET `total_individuals`=7,`infected_individuals`=0,`noninfected_individuals`=7 WHERE species_name='Flacourtia indica';
UPDATE `species` SET `total_individuals`=5,`infected_individuals`=0,`noninfected_individuals`=5 WHERE species_name='Gliricidia sepium';
UPDATE `species` SET `total_individuals`=2,`infected_individuals`=0,`noninfected_individuals`=2 WHERE species_name='Gmelina arborea';
UPDATE `species` SET `total_individuals`=5,`infected_individuals`=0,`noninfected_individuals`=5 WHERE species_name='Guazuma ulmifolia';
UPDATE `species` SET `total_individuals`=23,`infected_individuals`=6,`noninfected_individuals`=17 WHERE species_name='Hardwickia binata';
UPDATE `species` SET `total_individuals`=1,`infected_individuals`=0,`noninfected_individuals`=1 WHERE species_name='Helictes isora';
UPDATE `species` SET `total_individuals`=5,`infected_individuals`=0,`noninfected_individuals`=5 WHERE species_name='Ixora pavetta';
UPDATE `species` SET `total_individuals`=3,`infected_individuals`=2,`noninfected_individuals`=1 WHERE species_name='Khaya senegalensis';
UPDATE `species` SET `total_individuals`=1,`infected_individuals`=0,`noninfected_individuals`=1 WHERE species_name='Livistona chinensis';
UPDATE `species` SET `total_individuals`=11,`infected_individuals`=0,`noninfected_individuals`=11 WHERE species_name='Madhuca longifolia';
UPDATE `species` SET `total_individuals`=2,`infected_individuals`=0,`noninfected_individuals`=2 WHERE species_name='Mangifera indica';
UPDATE `species` SET `total_individuals`=31,`infected_individuals`=0,`noninfected_individuals`=31 WHERE species_name='Manilkara hexandra';
UPDATE `species` SET `total_individuals`=36,`infected_individuals`=1,`noninfected_individuals`=35 WHERE species_name='Memecylon umbellatum';
UPDATE `species` SET `total_individuals`=2,`infected_individuals`=0,`noninfected_individuals`=2 WHERE species_name='Mimusops elengi';
UPDATE `species` SET `total_individuals`=49,`infected_individuals`=2,`noninfected_individuals`=47 WHERE species_name='Morinda coreia';
UPDATE `species` SET `total_individuals`=1,`infected_individuals`=1,`noninfected_individuals`=0 WHERE species_name='Peltophorum pterocarpum';
UPDATE `species` SET `total_individuals`=1,`infected_individuals`=0,`noninfected_individuals`=1 WHERE species_name='Pongamia pinnata';
UPDATE `species` SET `total_individuals`=2,`infected_individuals`=0,`noninfected_individuals`=2 WHERE species_name='Pterocarpus marsupium';
UPDATE `species` SET `total_individuals`=61,`infected_individuals`=3,`noninfected_individuals`=58 WHERE species_name='Pterocarpus santalinus';
UPDATE `species` SET `total_individuals`=3,`infected_individuals`=0,`noninfected_individuals`=3 WHERE species_name='Pterospermum canescens';
UPDATE `species` SET `total_individuals`=1,`infected_individuals`=0,`noninfected_individuals`=1 WHERE species_name='Randia sp';
UPDATE `species` SET `total_individuals`=17,`infected_individuals`=0,`noninfected_individuals`=17 WHERE species_name='Syzgium cumini';
UPDATE `species` SET `total_individuals`=10,`infected_individuals`=1,`noninfected_individuals`=9 WHERE species_name='Tectona grandis';
UPDATE `species` SET `total_individuals`=11,`infected_individuals`=1,`noninfected_individuals`=10 WHERE species_name='Terminalia arjuna';
UPDATE `species` SET `total_individuals`=5,`infected_individuals`=0,`noninfected_individuals`=5 WHERE species_name='Terminalia bellerica';
UPDATE `species` SET `total_individuals`=7,`infected_individuals`=0,`noninfected_individuals`=7 WHERE species_name='Terminalia catappa';
UPDATE `species` SET `total_individuals`=14,`infected_individuals`=0,`noninfected_individuals`=14 WHERE species_name='Walsura trifoliata';
UPDATE `species` SET `total_individuals`=10,`infected_individuals`=1,`noninfected_individuals`=9 WHERE species_name='Ziziphus oenoplia';

UPDATE `species` SET `abundance_ratio`=(`total_individuals`/833);

ALTER TABLE `species` ADD `prevalence` INT(3) NOT NULL AFTER `abundance_ratio`;

UPDATE `species` SET `prevalence`=(`infected_individuals`/`total_individuals`);

--Total trees
SELECT COUNT(*) FROM hosts_backup h,sub_site s WHERE h.`plot`=s.`site_info.plot_name_key` AND h.`plot`='plot1'
--infested
SELECT COUNT(*) FROM hosts_backup h,sub_site s WHERE h.`plot`=s.`site_info.plot_name_key` AND h.`plot`='plot1' AND h.`count`>=1
--not infested
SELECT COUNT(*) FROM hosts_backup h,sub_site s WHERE h.`plot`=s.`site_info.plot_name_key` AND h.`plot`='plot1' AND h.`count`=0

SELECT COUNT(*) FROM hosts_backup h,sub_site s WHERE h.`plot`=s.`site_info.plot_name_key` AND h.`plot`='plot1';
SELECT COUNT(*) FROM hosts_backup h,sub_site s WHERE h.`plot`=s.`site_info.plot_name_key` AND h.`plot`='plot1' AND h.`count`>=1;
SELECT COUNT(*) FROM hosts_backup h,sub_site s WHERE h.`plot`=s.`site_info.plot_name_key` AND h.`plot`='plot1' AND h.`count`=0;

UPDATE sub_site SET trees_count=36, trees_infected=5,trees_not_infected=31 WHERE `site_info.plot_name_key`='plot1';
UPDATE sub_site SET trees_count=45, trees_infected=5,trees_not_infected=40 WHERE `site_info.plot_name_key`='plot2';
UPDATE sub_site SET trees_count=47, trees_infected=3,trees_not_infected=44 WHERE `site_info.plot_name_key`='plot3';
UPDATE sub_site SET trees_count=52, trees_infected=5,trees_not_infected=47 WHERE `site_info.plot_name_key`='plot4';
UPDATE sub_site SET trees_count=57, trees_infected=6,trees_not_infected=51 WHERE `site_info.plot_name_key`='plot5';
UPDATE sub_site SET trees_count=55, trees_infected=16,trees_not_infected=39 WHERE `site_info.plot_name_key`='plot6';
UPDATE sub_site SET trees_count=64, trees_infected=5,trees_not_infected=59 WHERE `site_info.plot_name_key`='plot7';
UPDATE sub_site SET trees_count=46, trees_infected=5,trees_not_infected=41 WHERE `site_info.plot_name_key`='plot8';
UPDATE sub_site SET trees_count=60, trees_infected=12,trees_not_infected=48 WHERE `site_info.plot_name_key`='plot9';
UPDATE sub_site SET trees_count=53, trees_infected=8,trees_not_infected=45 WHERE `site_info.plot_name_key`='plot10';
UPDATE sub_site SET trees_count=56, trees_infected=14,trees_not_infected=42 WHERE `site_info.plot_name_key`='plot11';
UPDATE sub_site SET trees_count=50, trees_infected=5,trees_not_infected=45 WHERE `site_info.plot_name_key`='plot12';
UPDATE sub_site SET trees_count=78, trees_infected=11,trees_not_infected=67 WHERE `site_info.plot_name_key`='plot13';
UPDATE sub_site SET trees_count=74, trees_infected=12,trees_not_infected=62 WHERE `site_info.plot_name_key`='plot14';
UPDATE sub_site SET trees_count=60, trees_infected=6,trees_not_infected=54 WHERE `site_info.plot_name_key`='plot15';

---Should I? Remove PU
DELETE FROM sub_site WHERE `site_info.site_name_key`='pu';

ALTER TABLE `rawdata_backup` ADD `gbh` DOUBLE(5,2) NOT NULL AFTER `gbh5`;
UPDATE `rawdata_backup` SET gbh=sqrt(pow(gbh1,2)+pow(gbh2,2)+pow(gbh3,2)+pow(gbh4,2)+pow(gbh5,2))

ALTER TABLE `rawdata` ADD `gbh` DOUBLE(5,2) NOT NULL AFTER `gbh5`;
UPDATE `rawdata` SET gbh=sqrt(pow(gbh1,2)+pow(gbh2,2)+pow(gbh3,2)+pow(gbh4,2)+pow(gbh5,2))

CREATE TABLE parasite AS SELECT site,plot,host,gbh,biomass,phenologypar1,phenologypar2,phenologypar3,clump FROM rawdata WHERE infest=1;

SELECT h.host FROM hosts_backup h,sub_site s WHERE h.`plot`=s.`site_info.plot_name_key` GROUP BY h.`host`;

--Species name 7
SELECT * FROM hosts WHERE host='7'
UPDATE hosts SET host='Terminalia catappa' WHERE host='7';
SELECT * FROM hosts_backup WHERE host='7'
UPDATE hosts_backup SET host='Terminalia catappa' WHERE host='7';
SELECT * FROM parasite WHERE host='7'
UPDATE parasite SET host='Terminalia catappa' WHERE host='7';
SELECT * FROM rawdata WHERE host='7'
UPDATE rawdata SET host='Terminalia catappa' WHERE host='7';
SELECT * FROM rawdata_backup WHERE host='7'
UPDATE rawdata_backup SET host='Terminalia catappa' WHERE host='7';

CREATE TABLE `project`.`species` ( `species_name` VARCHAR(40) NOT NULL , `family` VARCHAR(20) NOT NULL , `bark_texture` VARCHAR(15) NOT NULL , `physiognomy` VARCHAR(15) NOT NULL ) ENGINE = InnoDB;

SELECT h.host FROM hosts_backup h,sub_site s WHERE h.`plot`=s.`site_info.plot_name_key` GROUP BY h.`host`;

SELECT h.host FROM hosts_backup h,sub_site s WHERE h.`plot`=s.`site_info.plot_name_key` GROUP BY h.`host` INTO OUTFILE '/tmp/species.csv' FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';

mysql --host='127.0.0.1' --user='preethi' --password='root' 'project' -e "SELECT h.host FROM hosts_backup h,sub_site s WHERE h.`plot`=s.`site_info.plot_name_key` GROUP BY h.`host` INTO OUTFILE '/tmp/species.csv' FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';"

SELECT QUOTE(host), gbh, count_parasite, plot FROM hosts;
