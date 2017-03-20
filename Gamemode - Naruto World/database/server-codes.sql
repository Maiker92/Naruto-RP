DROP TABLE IF EXISTS "accounts";
CREATE TABLE `accounts` (`id` INTEGER PRIMARY KEY, `name` TEXT, `password` TEXT, `code` TEXT);
INSERT INTO "accounts" VALUES(1,'(gmR)Amit','12321','afnw');
INSERT INTO "accounts" VALUES(2,'Darkj3cT10n','ran<3','afnw');
INSERT INTO "accounts" VALUES(3,'SoS[T]Boy','qwe123qwe','afnw');
INSERT INTO "accounts" VALUES(4,'(gmR)Elegant(L)','123123','afnw');
DROP TABLE IF EXISTS "admincmds";
CREATE TABLE `admincmds` (`cmdtext` TEXT, `level` INTEGER);
INSERT INTO "admincmds" VALUES('/ahelp',1);
INSERT INTO "admincmds" VALUES('/adduser',4);
INSERT INTO "admincmds" VALUES('/assign',4);
INSERT INTO "admincmds" VALUES('/remove',4);
INSERT INTO "admincmds" VALUES('/activate',3);
INSERT INTO "admincmds" VALUES('/deactivate',3);
INSERT INTO "admincmds" VALUES('/id',1);
INSERT INTO "admincmds" VALUES('/setadmin',5);
INSERT INTO "admincmds" VALUES('/play',1);
INSERT INTO "admincmds" VALUES('/goto',2);
INSERT INTO "admincmds" VALUES('/get',2);
INSERT INTO "admincmds" VALUES('/setworld',5);
INSERT INTO "admincmds" VALUES('/getworld',5);
INSERT INTO "admincmds" VALUES('/setskin',4);
INSERT INTO "admincmds" VALUES('/skinid',4);
INSERT INTO "admincmds" VALUES('/skinlist',4);
INSERT INTO "admincmds" VALUES('/counts',2);
INSERT INTO "admincmds" VALUES('/toggledownfall',2);
INSERT INTO "admincmds" VALUES('/jetpack',1);
INSERT INTO "admincmds" VALUES('/setint',5);
INSERT INTO "admincmds" VALUES('/getint',5);
INSERT INTO "admincmds" VALUES('/route',5);
DROP TABLE IF EXISTS "admins";
CREATE TABLE `admins` (`id` INTEGER PRIMARY KEY, `level` INTEGER);
INSERT INTO "admins" VALUES(1,5);
DROP TABLE IF EXISTS "players";
CREATE TABLE "players" ("pid" INTEGER PRIMARY KEY, "uid" INTEGER,"cuid" TEXT,"type" INTEGER,"dna" TEXT,"status" INTEGER,"xp" INTEGER,"level" INTEGER,"lastpos" TEXT,"lastchakra" INTEGER );
INSERT INTO "players" VALUES(1,1,'tsunade',0,'BUDQVFPYRKSKUHAEMJSFXNKKURBQRXIH',1,0,1,'182.5850,-414.3772,23.7000,161.6841',371);
INSERT INTO "players" VALUES(2,1,'gaara',0,'DSFMHGTVTHQKQNEXTIOHBRSCJYYNCRVV',1,0,1,'0.0,0.0,0.0,0.0',0);
INSERT INTO "players" VALUES(3,2,'jiraiya',0,'blah',1,0,1,'0.0,0.0,0.0,0.0',0);
INSERT INTO "players" VALUES(4,3,'naruto',0,'blah',1,0,1,'0.0,0.0,0.0,0.0',0);
INSERT INTO "players" VALUES(5,4,'rocklee',0,'blah',1,0,1,'0.0,0.0,0.0,0.0',0);
DROP TABLE IF EXISTS "settings";
CREATE TABLE `settings` (`name` TEXT, `value` TEXT);
