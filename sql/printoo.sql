drop database if exists printoo;
-- create utf8-mb4 database
create database printoo character set = utf8mb4 collate = utf8mb4_unicode_ci;
use printoo;
-- database needs to store date in utc +0:00
set global time_zone = '+0:00';
set global sql_mode = 'no_auto_value_on_zero';

start transaction;
-- users
create table users (
  id smallint unsigned not null primary key auto_increment,

  username varchar(16) not null,
  password varchar(64) not null, -- is hashed

  unique key (username)
) engine = innodb; 
-- while 0 value is allowed for users.id

-- need this zero user allowing set persons.tid = 0
insert into users
(id, username, password) values
(0, "zerouser", "$2a$14$Aij9nZ5Dym2JJiiAc2nY..ZIlCTZrtGJSRqU9VwifPsdK8KL3Vzky");

-- on delete users.id echoed field persons.tid will be set to 0 not null
-- persons.tid is part of a primary key so cannot be set to null
/*delimiter $$
create trigger users_after_delete 
after delete 
on users for each row 
begin
update companies set tid=0 where tid=old.id;
update persons set tid=0 where tid=old.id;
end$$
delimiter ;*/
-- roles
create table roles (
	name varchar(16) not null primary key
) engine = innodb;

-- user_roles
create table user_roles (
	user_id smallint unsigned not null,
	role_name varchar(16) not null,

	unique key (user_id, role_name),

	constraint foreign key (user_id) references users (id)
	on update cascade,
	constraint foreign key (role_name) references roles (name)
	on update cascade
) engine = innodb;

-- persons
create table persons (
  tid smallint unsigned not null,
  id smallint unsigned not null auto_increment,
	primary key (id, tid), 
  
  longname varchar(50) not null,
  phone varchar(15) null, -- unique index allow unknown values as nulls
  email varchar(30) null, 
  is_male boolean null, -- here null is unknown value
  address varchar(200) null,
  is_client boolean not null default false, -- a person can be client or contractor or both
  is_contractor boolean not null default false,
  
  key (is_client,is_contractor),
  unique key (phone, tid),
  unique key (email, tid),

  constraint foreign key (tid) references users (id)
	on update cascade
) engine = innodb;

create table person_phones (
  tid smallint unsigned not null,
  person_id smallint unsigned not null,

  phone varchar(15) not null,
  
  unique key (person_id, tid, phone),
  
	constraint foreign key (person_id, tid) references persons (id, tid)
  on update cascade
) engine = innodb;

create table person_emails (
  tid smallint unsigned not null,
  person_id smallint unsigned not null,

  email varchar(30) not null, 
  
  unique key (person_id, tid, email),
  constraint foreign key (person_id, tid) references persons (id, tid)
  on update cascade
) engine = innodb;
commit;

-- companies
create table companies (
    tid smallint unsigned not null,
    id mediumint unsigned not null auto_increment,
		primary key (id, tid), 

    longname varchar(50) not null,
    tin varchar(30) not null, -- taxpayer identification number, in RO is cui
    rn varchar(30), -- registration number, in RO is J
    is_client boolean not null default true, -- a company can be client or contractor or both
    is_contractor boolean not null default false,
    prefixname char(3) generated always as (left(longname,3)),
    
		unique key (tin),
    unique key (rn),
    key (is_client,is_contractor),
    key (prefixname),
    
		constraint  foreign key (tid) references users (id)
		on update cascade
) engine = innodb;

create table company_addresses (
    tid smallint unsigned not null,
    company_id mediumint unsigned not null,
		id tinyint unsigned not null auto_increment,

    address varchar(200),
    location point null srid 4326,
   
		key (id),
    unique key (company_id, tid, id),

    constraint  foreign key (company_id, tid) references companies (id, tid)
		on update cascade
) engine = innodb;

create table company_ibans (
    tid smallint unsigned not null,
    company_id mediumint unsigned not null,

    iban char(34), -- International Bank Account Number
    bankname varchar(50),

    primary key (company_id, iban, tid),
    
		constraint  foreign key (company_id, tid) references companies (id, tid)
		on update cascade
) engine = innodb;

-- work_units exists as constraints for works
create table work_units (
	tid smallint unsigned not null,

	unit varchar(30) not null,

	primary key (unit, tid),

	constraint foreign key (tid) references users (id)
	on update cascade
) engine = innodb;

-- currencies exists as constraints for works
create table currencies (
	tid smallint unsigned not null default 0, -- 0 means default values
	
	currency char(3) not null,
	
	primary key (currency, tid),

	constraint foreign key (tid) references users (id)
	on update cascade
) engine = innodb;

-- works
create table works (
	tid smallint unsigned not null,
	id bigint unsigned not null auto_increment,

	label varchar(100) not null default '',
	quantity float not null default 1,
	unit varchar(30) not null default 'buc',
	unitprice numeric(15, 2),
	currency char(3) not null default 'ron',

	primary key (id, tid), 

	constraint foreign key (tid) references users (id)
	on update cascade,
	constraint foreign key (unit) references work_units (unit)
	on update cascade,
	constraint foreign key (currency) references currencies (currency)
	on update cascade
) engine = innodb;

-- every work pass to ordered stages
create table work_stages (
	tid smallint unsigned not null,

	stage varchar(20) not null,
	description varchar(150) null default "",
	ordered tinyint unsigned not null,

	primary key (stage, tid),
	unique key (tid, ordered),

	constraint foreign key (tid) references users (id)
	on update cascade
) engine = innodb;

create table works_stages (
	work_id bigint unsigned not null,
	stage varchar(20) not null,

	constraint foreign key (work_id) references works (id)
	on update cascade,
	constraint foreign key (stage) references work_stages (stage)
	on update cascade
) engine = innodb;

-- constraint for entries label
create table entries_code (
  tid smallint unsigned not null,
  
  code varchar(50) not null,
  description varchar(255) null,

  unique key (code, tid),

	constraint foreign key (tid) references users (id)
	on update cascade
) engine = innodb;

-- inputs
create table inputs (
	tid smallint unsigned not null,
	id bigint unsigned not null auto_increment,

	entry varchar(50) not null,
	quantity float not null default 1,
	updated datetime null on update current_timestamp,
	
	primary key (id, tid),
	
	constraint foreign key (entry, tid) references entries_code (code, tid)
	on update cascade
) engine = innodb;

-- outputs
create table outputs (
	tid smallint unsigned not null,
	works_id bigint unsigned not null,
	inputs_id bigint unsigned not null,
	quantity float not null default 0,
	
	constraint foreign key (tid) references users (id)
	on update cascade,
	constraint foreign key (works_id) references works (id)
	on update cascade,
	constraint foreign key (inputs_id) references inputs (id)
	on update cascade
) engine = innodb;

