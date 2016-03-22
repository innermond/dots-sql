drop database if exists `printoo`;
-- create utf8-mb4 database
create database `printoo` character set = utf8mb4 collate = utf8mb4_unicode_ci;
use printoo;
-- database needs to store date in utc +0:00
set time_zone = '+0:00';

-- types
create table `types` (
	label varchar(50) not null primary key,
	description varchar(255)
) engine = innodb;

-- entries
create table `entries` (
	ai_col int unsigned not null primary key auto_increment,
	type varchar(50) not null,
	label varchar(100) not null default '',
	amount float not null default 1,
	created datetime null default current_timestamp,
	updated datetime null on update current_timestamp,
	unique key (type, label),
	foreign key (type) references types (label)
	on delete restrict
	on update cascade
) engine = innodb;


-- add some data
insert into types values('țevi', 'țevi cu φ de 50mm și cu înălțimea de 0,1');
insert into types values('blat șhaormă', 'blat de șhaormă cu peste 80% făină naturală');
insert into entries values('țevi', 'Ø16/18', 2500, null, default);
insert into entries (type, label, amount) values('țevi', 'Ø30/15', 1500);
insert into entries values('blat șhaormă', 'roșu de Istambul', 58, default, null);
insert into entries values('blat șhaormă', 'ᚠᛇᚻ᛫ᛒᛦᚦ᛫ᚠᚱᚩᚠᚢᚱ᛫ᚠᛁᚱᚪ᛫ᚷᛖᚻᚹᛦᛚᚳᚢᛗ', 58, null, null);
