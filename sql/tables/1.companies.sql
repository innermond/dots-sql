-- companies
create table companies (
    tid smallint not null,
    id smallserial,
		primary key (id, tid), 

    longname varchar(50) not null,
    tin varchar(30) not null, -- taxpayer identification number, in RO is cui
    rn varchar(30), -- registration number, in RO is J
    is_client boolean not null default true, -- a company can be client or contractor or both
    is_contractor boolean not null default false,
		is_mine boolean not null default false, -- can emit bills
    prefixname char(3) generated always as (substring(longname from 1 for 3)) stored,
    
		unique (tin, rn),
		foreign key (tid) references users (id)
);
create index on companies (is_client, tid);
create index on companies (is_contractor, tid);
create index on companies (is_mine, tid);
create index on companies (prefixname, tid);

create table company_addresses (
    tid smallint not null,
    company_id smallint not null,
		id smallint not null,
		address varchar(200),
		-- location point not null srid 4326,
		unique (address),
		-- spatial key (location),
		foreign key (company_id, tid) references companies (id, tid)
		on delete cascade
);

create table company_ibans (
		tid smallint not null,
		company_id smallint not null,
		iban char(34), -- International Bank Account Number
    primary key (company_id, tid, iban),
		bankname varchar(50),
		unique (iban),
		foreign key (company_id, tid) references companies (id, tid)
		on delete cascade
);

