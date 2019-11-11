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

