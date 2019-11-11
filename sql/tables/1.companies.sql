-- companies
create table companies (
    tid smallint unsigned not null,
    id tinyint unsigned not null auto_increment,

    longname varchar(50) not null,
    tin varchar(30) not null, -- taxpayer identification number, in RO is cui
    rn varchar(30), -- registration number, in RO is J
    is_client boolean not null default true, -- a company can be client or contractor or both
    is_contractor boolean not null default false,
		is_mine boolean not null default false, -- can emit bills
    prefixname char(3) generated always as (left(longname,3)),
    
		primary key (id, tid), 
		unique key (tin, rn),
    key (is_client, tid),
    key (is_contractor, tid),
    key (is_mine, tid),
    key (prefixname, tid),
    
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

