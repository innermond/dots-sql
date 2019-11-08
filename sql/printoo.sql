drop database if exists printoo;
-- create utf8-mb4 database
create database printoo character set = utf8mb4 collate = utf8mb4_unicode_ci;
use printoo;
-- database needs to store date in utc +0:00
set session time_zone = '+0:00';
set session sql_mode = 'traditional';

-- users
create table users (
  id int unsigned not null primary key auto_increment,

  username varchar(16) not null,
  password varchar(64) not null, -- is hashed

  unique key (username, password)
) engine = innodb;

-- roles
create table roles (
	name varchar(16) not null primary key
) engine = innodb;

-- user_roles
create table user_roles (
	user_id int unsigned not null,
	role_name varchar(16) not null,

	unique key (user_id, role_name),
	constraint foreign key (user_id) references users (id)
	on delete cascade,
	constraint foreign key (role_name) references roles (name)
	on update cascade
	on delete cascade
) engine = innodb;

-- persons
create table persons (
  id int unsigned not null primary key auto_increment,
  tid int unsigned not null,
  
  longname varchar(50) not null,
  phone varchar(15) null, -- unique index allow unknown values as nulls
  email varchar(30) null, 
  is_male boolean null, -- here null is unknown value
  address varchar(200) null,
  is_client boolean not null default false, -- a person can be client or contractor or both
  is_contractor boolean not null default false,
  oid int unsigned null,
  
  key ix_cc (is_client,is_contractor),
  unique key (phone),
  unique key (email),
  constraint foreign key (oid) references users (id)
	on delete set null
) engine = innodb;

create table person_phones (
  person_id int unsigned not null,
  phone varchar(15) not null,
  
  unique key (person_id, phone),
  constraint foreign key (person_id) references persons (id)
  on delete cascade
) engine = innodb;

create table person_emails (
  person_id int unsigned not null,
  email varchar(30) not null, 
  
  unique key (person_id, email),
  constraint foreign key (person_id) references persons (id)
  on delete cascade
) engine = innodb;

-- companies
create table companies (
    -- for internal use 
    id int unsigned not null primary key auto_increment,
    -- tenent id user id
    tid int unsigned not null,

    longname varchar(50) not null,
    tin varchar(30) not null, -- taxpayer identification number, in RO is cui
    rn varchar(30), -- registration number, in RO is J
    is_client boolean not null default true, -- a company can be client or contractor or both
    is_contractor boolean not null default false,
    prefixname char(3) generated always as (left(longname,3)),
    unique key (tin),
    unique key (rn),
    key ix_cc (is_client,is_contractor),
    key ix_prefix3 (prefixname),
    constraint  foreign key (tid) references users (id)
) engine = innodb;

create table company_addresses (
    id int unsigned not null primary key auto_increment,

    company_id int unsigned not null,
    address varchar(200),
    location point not null srid 4326,
    
		spatial key (location),
    unique key (company_id, address),
    constraint  foreign key (company_id) references companies (id)
    on delete cascade
) engine = innodb;

create table ibans (
    company_id int unsigned not null,
    iban char(34), -- International Bank Account Number
    bankname varchar(50),

    primary key (company_id, iban),
    constraint  foreign key (company_id) references companies (id)
    on delete cascade
) engine = innodb;

-- work_units exists as constraints for works
create table work_units (
	tid int unsigned not null,

	unit varchar(30) not null primary key
) engine = innodb;

-- currencies exists as constraints for works
create table currencies (
	tid int unsigned not null default 0, -- 0 means default values
	
	currency char(3) not null primary key
) engine = innodb;

-- works
create table works (
	id int unsigned not null primary key auto_increment,
	tid int unsigned not null,

	label varchar(100) not null default '',
	quantity float not null default 1,
	unit varchar(30) not null default 'buc',
	unitprice numeric(15, 2),
	currency char(3) not null default 'ron',
	
	constraint works_unit_fk_work_units_unit foreign key (unit) references work_units (unit)
	on update cascade
	on delete restrict,
	constraint currencies_label_fk_works_currency foreign key (currency) references currencies (currency)
	on update cascade
	on delete restrict
) engine = innodb;

-- every work pass to ordered stages
create table work_stages (
	tid int unsigned not null,

	stage varchar(20) not null,
	description varchar(150) null default "",
	ordered int unsigned not null,

	primary key (stage, tid),
	unique key (tid, ordered)
) engine = innodb;

create table works_stages (
	work_id int unsigned not null,
	stage varchar(20) not null,

	constraint works_stages_id_fk_works_id foreign key (work_id) references works (id)
	on delete cascade,
	constraint works_stages_stage_fk_work_stages_stage foreign key (stage) references work_stages (stage)
	on update cascade
	on delete restrict
) engine = innodb;

-- constraint for entries label
create table entries_code (
  tid int unsigned not null,
  
  code varchar(50) not null,
  description varchar(255) null,

  unique key (code, tid)
) engine = innodb;

-- inputs
create table inputs (
	id int unsigned not null primary key auto_increment,
	tid int unsigned not null,

	entry varchar(50) not null,
	quantity float not null default 1,
	updated datetime null on update current_timestamp,
	
	unique key (entry, tid),
	constraint inputs_entry_fk_entries_code foreign key (entry) references entries_code (code)
	on delete restrict
	on update cascade
) engine = innodb;

-- inputs history
create table inputs_history (
	id int unsigned not null primary key auto_increment,
	tid int unsigned not null,

	entry varchar(50) not null,
	quantity float not null default 1,
	created datetime null default current_timestamp,
	
	constraint inputs_history_entry_fk_entries_code foreign key (entry) references entries_code (code)
) engine = innodb;

-- outputs
create table outputs (
	works_id int unsigned not null,
	inputs_id int unsigned not null,
	quantity float not null default 0,
	
	constraint outputs_works_id_fk_works_id foreign key (works_id) references works (id)
	on delete restrict,
	constraint outputs_inputs_id_fk_inputs_id foreign key (inputs_id) references inputs (id)
	on delete restrict
) engine = innodb;

