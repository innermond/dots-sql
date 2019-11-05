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
	unique key (address),
	spatial key (location),
	constraint  foreign key (company_id) references companies (id)
	on delete cascade
) engine = innodb;

create table company_ibans (
  id int unsigned not null primary key auto_increment,
  company_id int unsigned not null,
	iban char(34), -- International Bank Account Number
	bankname varchar(50),
	unique key (iban),
	constraint  foreign key (company_id) references companies (id)
	on delete cascade
) engine = innodb;

