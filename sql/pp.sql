drop database if exists printoo;
-- create utf8-mb4 database
create database printoo character set = utf8mb4 collate = utf8mb4_unicode_ci;
use printoo;
-- database needs to store date in utc +0:00
set session time_zone = '+0:00';
set session sql_mode = 'traditional';

-- companies
create table companies (
  id int unsigned not null primary key auto_increment,
  longname varchar(50) not null,
	tin varchar(30) not null, -- taxpayer identification number, in RO is cui
	rn varchar(30), -- registration number, in RO is J
	is_client boolean not null default true, -- a company can be client or contractor or both
	is_contractor boolean not null default false,
	prefixname char(3) generated always as (left(longname,3)),
	unique key (tin),
	unique key (rn),
	key ix_cc (is_client,is_contractor),
  key ix_prefix3 (prefixname)
) engine = innodb;

create table company_addresses (
  id int unsigned not null primary key auto_increment,
  company_id int unsigned not null,
	address varchar(200),
	location point not null srid 4326,
	spatial key (location),
	constraint  foreign key (company_id) references companies (id)
	on delete cascade
) engine = innodb;

create table ibans (
  id int unsigned not null primary key auto_increment,
  company_id int unsigned not null,
	iban char(34), -- International Bank Account Number
	bankname varchar(50),
	unique key (iban),
	constraint  foreign key (company_id) references companies (id)
	on delete cascade
) engine = innodb;

-- work_units exists as constraints for works
create table work_units (
	unit varchar(30) not null primary key
) engine = innodb;

-- currencies exists as constraints for works
create table currencies (
	currency char(3) not null primary key
) engine = innodb;

-- works
create table works (
	id int unsigned not null primary key auto_increment,
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
	stage varchar(20) not null primary key,
	description varchar(150) null default "",
	ordered int unsigned not null,
	unique key (ordered)
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

-- users
create table users (
  id int unsigned not null primary key auto_increment,
  username varchar(16) not null,
  password varchar(64) not null, -- is hashed
  unique key (username)
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

-- constraint for entries label
create table entries_code (
	code varchar(50) not null primary key,
  description varchar(255) null
) engine = innodb;

-- inputs
create table inputs (
	id int unsigned not null primary key auto_increment,
	entry varchar(50) not null,
	quantity float not null default 1,
	updated datetime null on update current_timestamp,
	unique key (entry),
	constraint inputs_entry_fk_entries_code foreign key (entry) references entries_code (code)
	on delete restrict
	on update cascade
) engine = innodb;

-- inputs history
create table inputs_history (
	id int unsigned not null primary key auto_increment,
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

start transaction;
insert into companies values
(null, 'sc volt-media srl', 'ro16728168', 'j40/14133/2004', false, true, default);
select last_insert_id() into @lastid;
insert into ibans values
(@lastid, 'rncb12345678974512', 'reifeissenbank suc. baba novac');
insert into companies values
(null, 'sc tipografix house srl', 'ro22345120', 'j40/12133/2014', false, true, default);
select last_insert_id() into @lastid;
insert into ibans values
(@lastid, 'rodev345678974512', 'procredit bank titan'),
(@lastid, 'as435345675676', 'procredit bank titan');
commit;
select 'work_unit';
insert into work_units values ('buc'), ('ore'), ('mp'), ('proiect');
select 'currencies';
-- get currencies list from https://www.iban.com/currency-codes.html
insert into currencies values ('AFN'),('ALL'),('DZD'),('USD'),('EUR'),('AOA'),('XCD'),('ARS'),('AMD'),('AWG'),('AUD'),('AZN'),('BSD'),('BHD'),('BDT'),('BBD'),('BYR'),('BZD'),('XOF'),('BMD'),('BTN'),('INR'),('BOB'),('BOV'),('BAM'),('BWP'),('NOK'),('BRL'),('BND'),('BGN'),('BIF'),('CVE'),('KHR'),('XAF'),('CAD'),('KYD'),('CLF'),('CLP'),('CNY'),('COP'),('COU'),('KMF'),('CDF'),('NZD'),('CRC'),('HRK'),('CUC'),('CUP'),('ANG'),('CZK'),('DKK'),('DJF'),('DOP'),('EGP'),('SVC'),('ERN'),('ETB'),('FKP'),('FJD'),('XPF'),('GMD'),('GEL'),('GHS'),('GIP'),('GTQ'),('GBP'),('GNF'),('GYD'),('HTG'),('HNL'),('HKD'),('HUF'),('ISK'),('IDR'),('XDR'),('IRR'),('IQD'),('ILS'),('JMD'),('JPY'),('JOD'),('KZT'),('KES'),('KPW'),('KRW'),('KWD'),('KGS'),('LAK'),('LBP'),('LSL'),('ZAR'),('LRD'),('LYD'),('CHF'),('MOP'),('MKD'),('MGA'),('MWK'),('MYR'),('MVR'),('MRU'),('MUR'),('XUA'),('MXN'),('MXV'),('MDL'),('MNT'),('MAD'),('MZN'),('MMK'),('NAD'),('NPR'),('NIO'),('NGN'),('OMR'),('PKR'),('PAB'),('PGK'),('PYG'),('PEN'),('PHP'),('PLN'),('QAR'),('RON'),('RUB'),('RWF'),('SHP'),('WST'),('STN'),('SAR'),('RSD'),('SCR'),('SLL'),('SGD'),('XSU'),('SBD'),('SOS'),('SSP'),('LKR'),('SDG'),('SRD'),('SZL'),('SEK'),('CHE'),('CHW'),('SYP'),('TWD'),('TJS'),('TZS'),('THB'),('TOP'),('TTD'),('TND'),('TRY'),('TMT'),('UGX'),('UAH'),('AED'),('USN'),('UYI'),('UYU'),('UZS'),('VUV'),('VEF'),('VND'),('YER'),('ZMW'),('ZWL');
select 'works';
insert into works values (null, 'D.T.P catalog "Șhaorma de Aur"', 1, 'proiect', 138, 'eur');
insert into works values (null, 'pliante "Țone de șârmărîe"', 1000, 'buc', 105, 'ron');
insert into works values (null, 'banner plastic printare fontă', 5, 'mp', 50, 'usd');
select 'work stages';
insert into work_stages values
('inițializată', 'datele initiale se extrag din comanda bruta (email, telefon, etc)', 1),
('verificată', 'datele inițiale sunt aprobate, comanda e formulată corect', 2),
('dată în lucru', 'comanda se trimite în atelier, pentru execuție', 3),
('finalizată', 'comanda a fost executată', 4);
select 'works_stages';
insert into works_stages values
(1, 'inițializată'), (1, 'verificată'),
(2, 'inițializată'), (2, 'verificată'), (2, 'dată în lucru'),
(3, 'inițializată'), (3, 'verificată'), (3, 'dată în lucru'), (3, 'finalizată');
start transaction;
select 'users'; 
-- test passords are gabiuser1 gabiuser2 teouser1
insert into users
(id, username, password) values
(default, "gabiuser1", "$2a$14$Aij9nZ5Dym2JJiiAc2nY..ZIlCTZrtGJSRqU9VwifPsdK8KL3Vzky"), 
(default, "gabiuser2", "$2a$14$15TQeheQKVkI7bysOpeETe99ktHTH8xMrxuqd4oAunRRfz3JLf6Uy"), 
(default, "teouser1", "$2a$14$klL5o18v1rub9FZzM50DDOg3ntE/GxZTLv8uYFd8KtF5wkxcU2Uqi"); 
select 'persons';
insert into persons values
(null, 'Gabriel Braila', '0723158571', 'gb@mob.ro', true, 'Bucuresti, Ilioara 1A', 0, 0, 1),
(default, 'Stoian Teodora', '0728032259', 'stoian.teodoara@gmail.com', false, 'Bucuresti Dristor', 0, 0, 3),
(default, 'Gabor Toni', '0721032259', 'gt@gmail.com', true , 'Afumati, Centura', 0, 0, 2),
(default, 'Bari Irinel', '0798032259', 'bari@gmail.com', true, 'Undeva cu credit', 0, 0, 2),
(default, 'Wonder woman', '0728032659', 'ww@gmail.com', false, 'Undeva in spatiu', 0, 0, 3);
insert into person_phones values
(1, '072548677'),(1, '0745879652'),
(2, '0736852497'),
(3, '074998965');
select 'roles';
insert into roles values
('anonymous'),
('user'),
('admin'),
('superadmin');
select 'user_roles';
insert into user_roles values
(1, 'superadmin'),
(1, 'admin'),
(1, 'user'),
(2, 'admin'),
(3, 'user');
commit;
select 'entries_code';
insert into entries_code values ('DCL A4 150g', 'hartie dcl marime a4 gramaj 150g');
insert into entries_code values ('DCL A4 200g', 'hartie dcl marime a4 gramaj 200g');
insert into entries_code values ('DCL A4 300g', 'hartie dcl marime a4 gramaj 300g');
insert into entries_code values ('DCL SRA3 300g', 'hartie dcl marime sra3 gramaj 300g');
select 'inputs';
insert into inputs values (null, 'DCL A4 150g', 2500, default);
insert into inputs (entry, quantity) values ('DCL A4 200g', 1500);
insert into inputs values (null, 'DCL SRA3 300g', 5800, null);
insert into inputs values (null, 'DCL A4 300g', 1500, null);
