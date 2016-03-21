drop database if exists `printoo`;
-- create utf8-mb4 database
create database `printoo` character set = utf8mb4 collate = utf8mb4_unicode_ci;
use printoo;

-- types
drop table if exists `types`;
create table `types` (
	label varchar(100) not null primary key,
	description varchar(255)
) engine = innodb;

-- entries
drop table if exists `entries`;
create table `entries` (
	type varchar(100) not null default 0,
	label varchar(100) not null default '',
	amount float not null default 1,
	primary key (type, label),
	foreign key (type) references types (label)
	on delete restrict
	on update cascade
) engine = innodb;

