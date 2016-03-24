drop database if exists printoo;
-- create utf8-mb4 database
create database printoo character set = utf8mb4 collate = utf8mb4_unicode_ci;
use printoo;
-- database needs to store date in utc +0:00
set session time_zone = '+0:00';
set session sql_mode = 'traditional';
-- types
create table entry_types (
	label varchar(50) not null primary key,
	description varchar(255),
	unique key (label)
) engine = innodb;

-- entries
create table entries (
	ai_col int unsigned not null primary key auto_increment,
	type varchar(50) not null,
	label varchar(100) not null default '',
	amount float not null default 1,
	created datetime null default current_timestamp,
	updated datetime null on update current_timestamp,
	unique key (type, label),
	constraint entries_type_fk_entry_types_label foreign key (type) references entry_types (label)
	on delete restrict
	on update cascade
) engine = innodb;

-- work_units exists as constraints for works
create table work_units (
	label varchar(30) not null primary key,
	unique key (label)
) engine = innodb;

-- currencies exists as constraints for works
create table currencies (
	label varchar(15) not null primary key,
	unique key (label)
) engine = innodb;

-- works
create table works (
	ai_col int unsigned not null primary key auto_increment,
	label varchar(100) not null default '',
	unit varchar(30) not null,
	price numeric(15, 2),
	currency varchar(15),
	amount float not null,
	constraint works_unit_fk_work_units_label foreign key (unit) references work_units (label)	
	on update cascade
	on delete no action,
	constraint currencies_label_fk_works_currency foreign key (currency) references currencies (label)	
	on update cascade
	on delete no action
) engine = innodb;

-- add some data
insert into entry_types values ('țevi', 'țevi cu φ de 50mm și cu înălțimea de 0,1');
insert into entry_types values ('blat șhaormă', 'blat de șhaormă cu peste 80% făină naturală');
insert into entries values (null, 'țevi', 'Ø16/18', 2500, null, default);
insert into entries (type, label, amount) values ('țevi', 'Ø30/15', 1500);
insert into entries values (null, 'blat șhaormă', 'roșu de Istambul', 58, default, null);
insert into entries values (null, 'blat șhaormă', 'ᚠᛇᚻ᛫ᛒᛦᚦ᛫ᚠᚱᚩᚠᚢᚱ᛫ᚠᛁᚱᚪ᛫ᚷᛖᚻᚹᛦᛚᚳᚢᛗ', 58, null, null);
insert into work_units values ('buc'), ('ore'), ('mp'), ('proiect');  
insert into currencies values ('ron'), ('eur'), ('usd');  
insert into works values (null, 'D.T.P catalog "Șhaorma de Aur"', 'proiect', 138, 'eur', 1);
insert into works values (null, 'pliante "Țone de șârmărîe"', 'buc', 1.05, 'ron', 10000);
insert into works values (null, 'banner plastic printare fontă', 'mp', 5, 'usd', 50);

