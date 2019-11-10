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
delimiter $$
create trigger users_after_delete 
before delete 
on users for each row 
begin
update companies set tid=0 where tid=old.id;
update persons set tid=0 where tid=old.id;
end$$
delimiter ;
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
	on delete cascade
	on update cascade,
	constraint foreign key (role_name) references roles (name)
	on update cascade
	on delete cascade
) engine = innodb;

-- persons
create table persons (
  id mediumint unsigned not null auto_increment,
  tid smallint unsigned not null,
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
	on delete restrict
	on update cascade
	-- WARN replaced on delete with a trigger
	-- TODO create a trigger on delete users.id to set persons.tid 0
) engine = innodb;

create table person_phones (
  person_id mediumint unsigned not null,
  tid smallint unsigned not null,

  phone varchar(15) not null,
  
  unique key (person_id, tid, phone),
  
	constraint foreign key (person_id, tid) references persons (id, tid)
  on delete cascade
  on update cascade
) engine = innodb;

create table person_emails (
  person_id mediumint unsigned not null,
  tid smallint unsigned not null,

  email varchar(30) not null, 
  
  unique key (person_id, tid, email),
  constraint foreign key (person_id, tid) references persons (id, tid)
  on delete cascade
  on update cascade
) engine = innodb;
commit;

-- companies
create table companies (
    -- for internal use 
    id mediumint unsigned not null auto_increment,
    -- tenent id user id
    tid smallint unsigned not null,
		primary key (id, tid), 

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
		on delete restrict
		on update cascade
) engine = innodb;

create table company_addresses (
    company_id mediumint unsigned not null,
    tid smallint unsigned not null,
		id tinyint unsigned not null auto_increment,

    address varchar(200),
    location point null srid 4326,
   
		key (id),
    unique key (company_id, tid, id),

    constraint  foreign key (company_id, tid) references companies (id, tid)
    on delete cascade
		on update cascade
) engine = innodb;

create table company_ibans (
    company_id mediumint unsigned not null,
    tid smallint unsigned not null,

    iban char(34), -- International Bank Account Number
    bankname varchar(50),

    primary key (company_id, iban, tid),
    
		constraint  foreign key (company_id, tid) references companies (id, tid)
    on delete cascade
		on update cascade
) engine = innodb;

-- work_units exists as constraints for works
create table work_units (
	tid smallint unsigned not null,

	unit varchar(30) not null,

	primary key (unit, tid),

	constraint foreign key (tid) references users (id)
	on delete cascade
	on update cascade
) engine = innodb;

-- currencies exists as constraints for works
create table currencies (
	tid smallint unsigned not null default 0, -- 0 means default values
	
	currency char(3) not null,
	
	primary key (currency, tid),

	constraint foreign key (tid) references users (id)
	on delete cascade
	on update cascade
) engine = innodb;

-- works
create table works (
	id bigint unsigned not null auto_increment,
	tid smallint unsigned not null,

	label varchar(100) not null default '',
	quantity float not null default 1,
	unit varchar(30) not null default 'buc',
	unitprice numeric(15, 2),
	currency char(3) not null default 'ron',

	primary key (id, tid), 

	constraint foreign key (tid) references users (id)
	on delete cascade
	on update cascade,
	constraint foreign key (unit) references work_units (unit)
	on update cascade
	on delete cascade,
	constraint foreign key (currency) references currencies (currency)
	on update cascade
	on delete cascade
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
	on delete cascade
	on update cascade
) engine = innodb;

create table works_stages (
	work_id bigint unsigned not null,
	stage varchar(20) not null,

	constraint foreign key (work_id) references works (id)
	on delete cascade
	on update cascade,
	constraint foreign key (stage) references work_stages (stage)
	on update cascade
	on delete restrict
) engine = innodb;

-- constraint for entries label
create table entries_code (
  tid smallint unsigned not null,
  
  code varchar(50) not null,
  description varchar(255) null,

  unique key (code, tid),

	constraint foreign key (tid) references users (id)
	on delete cascade
	on update cascade
) engine = innodb;

-- inputs
create table inputs (
	id bigint unsigned not null auto_increment,
	tid smallint unsigned not null,

	entry varchar(50) not null,
	quantity float not null default 1,
	updated datetime null on update current_timestamp,
	
	primary key (id, tid),
	
	constraint foreign key (entry, tid) references entries_code (code, tid)
	on delete cascade
	on update cascade
) engine = innodb;

-- outputs
create table outputs (
	works_id bigint unsigned not null,
	tid smallint unsigned not null,
	inputs_id bigint unsigned not null,
	quantity float not null default 0,
	
	constraint foreign key (tid) references users (id)
	on delete cascade
	on update cascade,
	constraint foreign key (works_id) references works (id)
	on delete cascade
	on update cascade,
	constraint foreign key (inputs_id) references inputs (id)
	on delete cascade
	on update cascade
) engine = innodb;

start transaction;
select 'users'; 
-- test passords are gabiuser1 gabiuser2 teouser1
insert into users
(id, username, password) values
(null, "gabiuser1", "$2a$14$Aij9nZ5Dym2JJiiAc2nY..ZIlCTZrtGJSRqU9VwifPsdK8KL3Vzky"), 
(null, "gabiuser2", "$2a$14$15TQeheQKVkI7bysOpeETe99ktHTH8xMrxuqd4oAunRRfz3JLf6Uy"), 
(null, "teouser1", "$2a$14$klL5o18v1rub9FZzM50DDOg3ntE/GxZTLv8uYFd8KtF5wkxcU2Uqi"); 
set @tid=last_insert_id();
select 'persons';
insert into persons values
(null, @tid, 'Gabriel Braila', '0723158571', 'gb@mob.ro', true, 'Bucuresti, Ilioara 1A', 0, 0),
(null, @tid, 'Stoian Teodora', '0728032259', 'stoian.teodoara@gmail.com', false, 'Bucuresti Dristor', 0, 0),
(null, @tid, 'Gabor Toni', '0721032259', 'gt@gmail.com', true , 'Afumati, Centura', 0, 0),
(null, @tid, 'Bari Irinel', '0798032259', 'bari@gmail.com', true, 'Undeva cu credit', 0, 0),
(null, @tid, 'Wonder woman', '0728032659', 'ww@gmail.com', false, 'Undeva in spatiu', 0, 0);
insert into person_phones values
(1, @tid, '072548677'),(1, @tid, '0745879652'),
(2, @tid, '0736852497'),
(3, @tid, '074998965');
insert into person_emails values
(1, @tid, 'bg@bg.br'),(1, @tid, 'ab@ab.com'),
(2, @tid, 'ba@ba.ro'),
(3, @tid, 'cd@cd.com');
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
start transaction;
insert into companies values
(null, @tid, 'sc volt-media srl', 'ro16728168', 'j40/14133/2004', false, true, default);
select last_insert_id() into @lastid;
insert into company_ibans values
(@lastid, @tid, 'rncb12345678974512', 'reifeissenbank suc. baba novac');
insert into company_addresses values
(@lastid, @tid, null, 'grivitei nr 37', null);
insert into companies values
(null, @tid, 'sc tipografix house srl', 'ro22345120', 'j40/12133/2014', false, true, default);
select last_insert_id() into @lastid;
insert into company_ibans values
(@lastid, @tid, 'rodev345678974512', 'procredit bank titan'),
(@lastid, @tid, 'as435345675676', 'procredit bank titan');
insert into company_addresses values
(@lastid, @tid, null, 'str. Stefan cel Mare', st_srid(point(80.0, 10.0), 4326));
commit;
select 'work_unit';
insert into work_units values (@tid, 'buc'), (@tid, 'ore'), (@tid, 'mp'), (@tid, 'proiect');
select 'currencies';
-- get currencies list from https://www.iban.com/currency-codes.html
insert into currencies (currency) values ('AFN'),('ALL'),('DZD'),('USD'),('EUR'),('AOA'),('XCD'),('ARS'),('AMD'),('AWG'),('AUD'),('AZN'),('BSD'),('BHD'),('BDT'),('BBD'),('BYR'),('BZD'),('XOF'),('BMD'),('BTN'),('INR'),('BOB'),('BOV'),('BAM'),('BWP'),('NOK'),('BRL'),('BND'),('BGN'),('BIF'),('CVE'),('KHR'),('XAF'),('CAD'),('KYD'),('CLF'),('CLP'),('CNY'),('COP'),('COU'),('KMF'),('CDF'),('NZD'),('CRC'),('HRK'),('CUC'),('CUP'),('ANG'),('CZK'),('DKK'),('DJF'),('DOP'),('EGP'),('SVC'),('ERN'),('ETB'),('FKP'),('FJD'),('XPF'),('GMD'),('GEL'),('GHS'),('GIP'),('GTQ'),('GBP'),('GNF'),('GYD'),('HTG'),('HNL'),('HKD'),('HUF'),('ISK'),('IDR'),('XDR'),('IRR'),('IQD'),('ILS'),('JMD'),('JPY'),('JOD'),('KZT'),('KES'),('KPW'),('KRW'),('KWD'),('KGS'),('LAK'),('LBP'),('LSL'),('ZAR'),('LRD'),('LYD'),('CHF'),('MOP'),('MKD'),('MGA'),('MWK'),('MYR'),('MVR'),('MRU'),('MUR'),('XUA'),('MXN'),('MXV'),('MDL'),('MNT'),('MAD'),('MZN'),('MMK'),('NAD'),('NPR'),('NIO'),('NGN'),('OMR'),('PKR'),('PAB'),('PGK'),('PYG'),('PEN'),('PHP'),('PLN'),('QAR'),('RON'),('RUB'),('RWF'),('SHP'),('WST'),('STN'),('SAR'),('RSD'),('SCR'),('SLL'),('SGD'),('XSU'),('SBD'),('SOS'),('SSP'),('LKR'),('SDG'),('SRD'),('SZL'),('SEK'),('CHE'),('CHW'),('SYP'),('TWD'),('TJS'),('TZS'),('THB'),('TOP'),('TTD'),('TND'),('TRY'),('TMT'),('UGX'),('UAH'),('AED'),('USN'),('UYI'),('UYU'),('UZS'),('VUV'),('VEF'),('VND'),('YER'),('ZMW'),('ZWL');
select 'works';
insert into works values (null, @tid, 'D.T.P catalog "Șhaorma de Aur"', 1, 'proiect', 138, 'eur');
insert into works values (null, @tid, 'pliante "Țone de șârmărîe"', 1000, 'buc', 105, 'ron');
insert into works values (null, @tid, 'banner plastic printare fontă', 5, 'mp', 50, 'usd');
select 'work stages';
insert into work_stages values
(@tid, 'inițializată', 'datele initiale se extrag din comanda bruta (email, telefon, etc)', 1),
(@tid, 'verificată', 'datele inițiale sunt aprobate, comanda e formulată corect', 2),
(@tid, 'dată în lucru', 'comanda se trimite în atelier, pentru execuție', 3),
(@tid, 'finalizată', 'comanda a fost executată', 4);
select 'works_stages';
insert into works_stages values
(1, 'inițializată'), (1, 'verificată'),
(2, 'inițializată'), (2, 'verificată'), (2, 'dată în lucru'),
(3, 'inițializată'), (3, 'verificată'), (3, 'dată în lucru'), (3, 'finalizată');
select 'entries_code';
insert into entries_code values (@tid, 'DCL A4 150g', 'hartie dcl marime a4 gramaj 150g');
insert into entries_code values (@tid, 'DCL A4 200g', 'hartie dcl marime a4 gramaj 200g');
insert into entries_code values (@tid, 'DCL A4 300g', 'hartie dcl marime a4 gramaj 300g');
insert into entries_code values (@tid, 'DCL SRA3 300g', 'hartie dcl marime sra3 gramaj 300g');
select 'inputs';
insert into inputs values (null, @tid,  'DCL A4 150g', 2500, default);
insert into inputs (tid, entry, quantity) values (@tid, 'DCL A4 200g', 1500);
insert into inputs values (null, @tid,  'DCL SRA3 300g', 5800, null);
insert into inputs values (null, @tid, 'DCL A4 300g', 1500, null);
