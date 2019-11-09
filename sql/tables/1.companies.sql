-- companies
create table companies (
    -- for internal use 
    id mediumint unsigned not null auto_increment,
    -- tenent id user id
    tid smallint unsigned not null,

    longname varchar(50) not null,
    tin varchar(30) not null, -- taxpayer identification number, in RO is cui
    rn varchar(30), -- registration number, in RO is J
    is_client boolean not null default true, -- a company can be client or contractor or both
    is_contractor boolean not null default false,
    prefixname char(3) generated always as (left(longname,3)),
    
		primary key (id, tid), 
		unique key (tin),
    unique key (rn),
    key ix_cc (is_client,is_contractor),
    key ix_prefix3 (prefixname),
    
		constraint  foreign key (tid) references users (id)
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
) engine = innodb;

create table company_ibans (
    company_id mediumint unsigned not null,
    tid smallint unsigned not null,

    iban char(34), -- International Bank Account Number
    bankname varchar(50),

    primary key (company_id, iban, tid),
    constraint  foreign key (company_id, tid) references companies (id, tid)
    on delete cascade
) engine = innodb;

