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

	constraint foreign key (user_id) references users (id),
	constraint foreign key (role_name) references roles (name)
	on update cascade
) engine = innodb;

-- persons
create table persons (
  tid smallint unsigned not null,
  id tinyint unsigned not null auto_increment,
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
) engine = innodb;

create table person_phones (
  tid smallint unsigned not null,
  person_id tinyint unsigned not null,

  phone varchar(15) not null,
  
  unique key (person_id, tid, phone),
  
	constraint foreign key (person_id, tid) references persons (id, tid)
) engine = innodb;

create table person_emails (
  tid smallint unsigned not null,
  person_id tinyint unsigned not null,

  email varchar(30) not null, 
  
  unique key (person_id, tid, email),
  constraint foreign key (person_id, tid) references persons (id, tid)
) engine = innodb;
commit;

-- companies
create table companies (
    tid smallint unsigned not null,
    id tinyint unsigned not null auto_increment,
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
) engine = innodb;

create table company_addresses (
    tid smallint unsigned not null,
    company_id tinyint unsigned not null,
		id tinyint unsigned not null auto_increment,

    address varchar(200),
    location point null srid 4326,
   
		key (id),
    unique key (company_id, tid, id),

    constraint  foreign key (company_id, tid) references companies (id, tid)
) engine = innodb;

create table company_ibans (
    tid smallint unsigned not null,
    company_id tinyint unsigned not null,

    iban char(34), -- International Bank Account Number
    bankname varchar(50),

    primary key (company_id, tid, iban),
    
		constraint  foreign key (company_id, tid) references companies (id, tid)
) engine = innodb;

-- work_units exists as constraints for works
create table work_units (
	tid smallint unsigned not null,
	unit varchar(30) not null,

	primary key (unit, tid),

	constraint foreign key (tid) references users (id)
) engine = innodb;

-- currencies exists as constraints for works
create table currencies (
	tid smallint unsigned not null default 0, -- 0 means default values
	currency char(3) not null,
	
	primary key (currency, tid),

	constraint foreign key (tid) references users (id)
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
    key (currency, tid),

	constraint foreign key (unit, tid) references work_units (unit, tid)
	on update cascade
	-- constraint foreign key (currency, tid) references currencies (currency, tid)
	-- on update cascade
) engine = innodb;

delimiter $$
create trigger currencies_before_insert 
before insert 
on currencies for each row 
begin
    declare tenent_id smallint;
    
    set tenent_id = new.tid;
    if new.tid=null then
        set tenent_id=0;
    end if;
    if exists(select currency from currencies where tid in (tenent_id, 0) and currency=new.currency limit 1) then
        set @msgerr = concat("duplicate key currency value ", new.currency); 
        signal sqlstate '45000' 
        set message_text = @msgerr;
    end if;
end$$

-- insted of foreign key update cascade
create trigger currencies_after_update 
after update
on currencies for each row 
begin
    -- currency is system defined
    -- this should be very rare
    -- need an index on works.currency
    if old.tid=0 then
        update works set currency=new.currency where currency=old.currency;
    else
        -- update user defined currency
        update works set currency=new.currency where tid=old.tid and currency=old.currency;
    end if;
end$$
-- instesd foreign key
-- check if value exists in parent table when insert/update currency
create procedure currency_exists
(in tenent_id smallint, in valute char(3))
begin
    -- check existence as a foreign key
    if 0=exists(select currency from currencies where tid in (tenent_id, 0) and currency=valute limit 1) then
        set @msgerr = concat("no parent value for key currency: ", valute); 
        signal sqlstate '45000' 
        set message_text = @msgerr;
    end if;
end$$

create trigger works_before_insert 
before insert 
on works for each row 
begin
    call currency_exists(new.tid, new.currency);
end$$

create trigger works_before_update 
before update 
on works for each row 
begin
    call currency_exists(new.tid, new.currency);
end$$
delimiter ;

-- every work pass to ordered stages
create table work_stages (
	tid smallint unsigned not null,

	stage varchar(20) not null,
	description varchar(150) null default "",
	ordered tinyint unsigned not null,

	primary key (stage, tid),
	unique key (tid, ordered),

	constraint foreign key (tid) references users (id)
) engine = innodb;

create table works_stages (
	tid smallint unsigned not null,
	work_id bigint unsigned not null,
	stage varchar(20) not null,

	constraint foreign key (work_id, tid) references works (id, tid),
	constraint foreign key (stage, tid) references work_stages (stage, tid)
    on update cascade
) engine = innodb;

-- constraint for entries label
create table entries_code (
  tid smallint unsigned not null,
  
  code varchar(50) not null,
  description varchar(255) null,

  unique key (code, tid),

	constraint foreign key (tid) references users (id)
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
	
	constraint foreign key (tid) references users (id),
	constraint foreign key (works_id) references works (id),
	constraint foreign key (inputs_id) references inputs (id)
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
(@tid, null, 'Gabriel Braila', '0723158571', 'gb@mob.ro', true, 'Bucuresti, Ilioara 1A', 0, 0),
(@tid, null, 'Stoian Teodora', '0728032259', 'stoian.teodoara@gmail.com', false, 'Bucuresti Dristor', 0, 0),
(@tid, null, 'Gabor Toni', '0721032259', 'gt@gmail.com', true , 'Afumati, Centura', 0, 0),
(@tid, null, 'Bari Irinel', '0798032259', 'bari@gmail.com', true, 'Undeva cu credit', 0, 0),
(@tid, null, 'Wonder woman', '0728032659', 'ww@gmail.com', false, 'Undeva in spatiu', 0, 0);
insert into person_phones values
(@tid, 1, '072548677'),(@tid, 1, '0745879652'),
(@tid, 2, '0736852497'),
(@tid, 3, '074998965');
insert into person_emails values
(@tid, 1, 'bg@bg.br'),(@tid, 1, 'ab@ab.com'),
(@tid, 2, 'ba@ba.ro'),
(@tid, 3, 'cd@cd.com');
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
(@tid, null, 'sc volt-media srl', 'ro16728168', 'j40/14133/2004', false, true, default);
select last_insert_id() into @lastid;
insert into company_ibans values
(@tid, @lastid, 'rncb12345678974512', 'reifeissenbank suc. baba novac');
insert into company_addresses values
(@tid, @lastid, null, 'grivitei nr 37', null);
insert into companies values
(@tid, null, 'sc tipografix house srl', 'ro22345120', 'j40/12133/2014', false, true, default);
select last_insert_id() into @lastid;
insert into company_ibans values
(@tid, @lastid, 'rodev345678974512', 'procredit bank titan'),
(@tid, @lastid, 'as435345675676', 'procredit bank titan');
insert into company_addresses values
(@tid, @lastid, null, 'str. Stefan cel Mare', st_srid(point(80.0, 10.0), 4326));
commit;
select 'work_unit';
insert into work_units values (@tid, 'buc'), (@tid, 'ore'), (@tid, 'mp'), (@tid, 'proiect');
select 'currencies';
-- get currencies list from https://www.iban.com/currency-codes.html
insert into currencies (currency) values ('AFN'),('ALL'),('DZD'),('USD'),('EUR'),('AOA'),('XCD'),('ARS'),('AMD'),('AWG'),('AUD'),('AZN'),('BSD'),('BHD'),('BDT'),('BBD'),('BYR'),('BZD'),('XOF'),('BMD'),('BTN'),('INR'),('BOB'),('BOV'),('BAM'),('BWP'),('NOK'),('BRL'),('BND'),('BGN'),('BIF'),('CVE'),('KHR'),('XAF'),('CAD'),('KYD'),('CLF'),('CLP'),('CNY'),('COP'),('COU'),('KMF'),('CDF'),('NZD'),('CRC'),('HRK'),('CUC'),('CUP'),('ANG'),('CZK'),('DKK'),('DJF'),('DOP'),('EGP'),('SVC'),('ERN'),('ETB'),('FKP'),('FJD'),('XPF'),('GMD'),('GEL'),('GHS'),('GIP'),('GTQ'),('GBP'),('GNF'),('GYD'),('HTG'),('HNL'),('HKD'),('HUF'),('ISK'),('IDR'),('XDR'),('IRR'),('IQD'),('ILS'),('JMD'),('JPY'),('JOD'),('KZT'),('KES'),('KPW'),('KRW'),('KWD'),('KGS'),('LAK'),('LBP'),('LSL'),('ZAR'),('LRD'),('LYD'),('CHF'),('MOP'),('MKD'),('MGA'),('MWK'),('MYR'),('MVR'),('MRU'),('MUR'),('XUA'),('MXN'),('MXV'),('MDL'),('MNT'),('MAD'),('MZN'),('MMK'),('NAD'),('NPR'),('NIO'),('NGN'),('OMR'),('PKR'),('PAB'),('PGK'),('PYG'),('PEN'),('PHP'),('PLN'),('QAR'),('RON'),('RUB'),('RWF'),('SHP'),('WST'),('STN'),('SAR'),('RSD'),('SCR'),('SLL'),('SGD'),('XSU'),('SBD'),('SOS'),('SSP'),('LKR'),('SDG'),('SRD'),('SZL'),('SEK'),('CHE'),('CHW'),('SYP'),('TWD'),('TJS'),('TZS'),('THB'),('TOP'),('TTD'),('TND'),('TRY'),('TMT'),('UGX'),('UAH'),('AED'),('USN'),('UYI'),('UYU'),('UZS'),('VUV'),('VEF'),('VND'),('YER'),('ZMW'),('ZWL');
insert into currencies values (@tid, 'blk');
select 'works';
insert into works values (@tid, null, 'D.T.P catalog "Șhaorma de Aur"', 1, 'proiect', 138, 'eur');
insert into works values (@tid, null, 'pliante "Țone de șârmărîe"', 1000, 'buc', 105, 'ron');
insert into works values (@tid, null, 'banner plastic printare fontă', 5, 'mp', 50, 'usd');
select 'work stages';
insert into work_stages values
(@tid, 'inițializată', 'datele initiale se extrag din comanda bruta (email, telefon, etc)', 1),
(@tid, 'verificată', 'datele inițiale sunt aprobate, comanda e formulată corect', 2),
(@tid, 'dată în lucru', 'comanda se trimite în atelier, pentru execuție', 3),
(@tid, 'finalizată', 'comanda a fost executată', 4);
select 'works_stages';
insert into works_stages values
(@tid, 1, 'inițializată'), (@tid, 1, 'verificată'),
(@tid, 2, 'inițializată'), (@tid, 2, 'verificată'), (@tid, 2, 'dată în lucru'),
(@tid, 3, 'inițializată'), (@tid, 3, 'verificată'), (@tid, 3, 'dată în lucru'), (@tid, 3, 'finalizată');
select 'entries_code';
insert into entries_code values (@tid, 'DCL A4 150g', 'hartie dcl marime a4 gramaj 150g');
insert into entries_code values (@tid, 'DCL A4 200g', 'hartie dcl marime a4 gramaj 200g');
insert into entries_code values (@tid, 'DCL A4 300g', 'hartie dcl marime a4 gramaj 300g');
insert into entries_code values (@tid, 'DCL SRA3 300g', 'hartie dcl marime sra3 gramaj 300g');
select 'inputs';
insert into inputs values (@tid, null,  'DCL A4 150g', 2500, default);
insert into inputs (tid, entry, quantity) values (@tid, 'DCL A4 200g', 1500);
insert into inputs values (@tid, null,  'DCL SRA3 300g', 5800, null);
insert into inputs values (@tid, null, 'DCL A4 300g', 1500, null);
