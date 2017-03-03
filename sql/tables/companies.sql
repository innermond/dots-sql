-- companies
create table companies (
  id int unsigned not null primary key auto_increment,
  longname varchar(50) not null,
	tin varchar(30) not null, -- taxpayer identification number, in RO is cui
	rn varchar(30), -- registration number, in RO is J
	address varchar(200),
	is_client boolean not null default true, -- a company can be client or contractor or both
	is_contractor boolean not null default false,
	unique key (tin),
	unique key (rn)
) engine = innodb;

create table ibans (
  company_id int unsigned not null,
	iban char(34), -- International Bank Account Number
	bankname varchar(50),
	unique key (iban),
	constraint  foreign key (company_id) references companies (id)
	on delete cascade
) engine = innodb;
