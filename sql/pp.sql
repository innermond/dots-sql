start transaction;
-- users
create table users (
  id smallserial primary key,

  username varchar(16) not null,
  password varchar(64) not null, -- is hashed

  unique (username)
); 
-- while 0 value is allowed for users.id

-- need this zero user allowing currencies to have system defined (tid=0) values
/*insert into users
(id, username, password) values
(0, "zerouser", "$2a$14$Aij9nZ5Dym2JJiiAc2nY..ZIlCTZrtGJSRqU9VwifPsdK8KL3Vzky");
*/
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
);

-- user_roles
create table user_roles (
	user_id smallint not null check (user_id > 0),
	role_name varchar(16) not null,

	unique (user_id, role_name),

	foreign key (user_id) references users (id),
	foreign key (role_name) references roles (name)
	on update cascade
);

-- persons
-- persons sequence
-- every tid in persons will have a maximum 100 persons associated
create sequence persons_id_seq maxvalue 100 cycle;

create table persons (
  tid smallint not null,
  id smallint not null default nextval('persons_id_seq'),
  primary key (id, tid), 
  
  longname varchar(50) not null,
  phone varchar(15) null, -- unique index allow unknown values as nulls
  email varchar(30) null, 
  is_male boolean null, -- here null is unknown value
  address varchar(200) null,
  is_client boolean not null default false, -- a person can be client or contractor or both
  is_contractor boolean not null default false,
  
  --index (is_client, is_contractor),
  unique (phone, tid),
  unique (email, tid),

  foreign key (tid) references users (id)
);

alter sequence persons_id_seq owned by persons.id;

create table person_phones (
  tid smallint not null,
  person_id smallint not null,

  phone varchar(15) not null,
  
  unique (person_id, tid, phone),
	foreign key (person_id, tid) references persons (id, tid)
);

create table person_emails (
  tid smallint not null,
  person_id smallint not null,

  email varchar(30) not null, 
  
  unique (person_id, tid, email),
  foreign key (person_id, tid) references persons (id, tid)
);
commit;

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

-- work_units exists as constraints for works
create table work_units (
	tid smallint,
	unit varchar(30),
	primary key (unit, tid),

	foreign key (tid) references users (id)
);

-- currencies exists as constraints for works
create table currencies (
	tid smallint not null default 0, -- 0 means default values
	currency char(3),
	primary key (currency, tid),

	foreign key (tid) references users (id)
);

-- works
create table works (
	tid smallint,
	id bigserial,
	primary key (id, tid), 

	label varchar(100) not null,
	quantity float not null default 1,
	unit varchar(30) not null default 'buc',
	unitprice numeric(15, 2),
	currency char(3) not null default 'ron',


	foreign key (unit, tid) references work_units (unit, tid)
	on update cascade
	-- foreign key (currency, tid) references currencies (currency, tid)
	-- on update cascade
);
create index on works (currency, tid);
/*
delimiter $$
create procedure currency_system_defined_exists_or_err
(in tenent_id smallint, in valute char(3))
begin
    if tenent_id!=0 and exists(select currency from currencies where tid=0 and currency=valute limit 1) then
        set @msgerr = concat("duplicate key currency value ", valute); 
        signal sqlstate '45000' 
        set message_text = @msgerr;
    end if;
end$$
-- check if system defined currency values exists already
create trigger currencies_before_insert 
before insert 
on currencies for each row 
begin
    call currency_system_defined_exists_or_err(new.tid, new.currency);
end$$
 -- update only there is no other system defined
create trigger currencies_before_update 
before update
on currencies for each row 
begin
    call currency_system_defined_exists_or_err(new.tid, new.currency);
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
create procedure currency_exists_or_err
(in tenent_id smallint, in valute char(3))
begin
    -- check existence as a foreign key
    if 0=exists(select currency from currencies where tid in (tenent_id, 0) and currency=valute limit 1) then
        set @msgerr = concat("no parent value for key currency: ", valute); 
        signal sqlstate '45000' 
        set message_text = @msgerr;
    end if;
end$$

-- ensure currency value exists in currencies.currency
create trigger works_before_insert 
before insert
on works for each row 
begin
    call currency_exists_or_err(new.tid, new.currency);
end$$

-- ensure currency value exists in currencies.currency
create trigger works_before_update 
before update 
on works for each row 
begin
    call currency_exists_or_err(new.tid, new.currency);
end$$
delimiter ;
*/
-- every work pass to ordered stages
create table work_stages (
	tid smallint not null,
	stage varchar(20) not null,
	description varchar(150) null,
	ordered int not null,

	-- stage is unique for an entire tid
	primary key (stage, tid),
	unique (tid, ordered),

	foreign key (tid) references users (id)
);

create table works_stages (
	tid smallint not null,
	work_id bigint not null,
	stage varchar(20) not null,
	primary key (work_id, stage, tid),

	foreign key (work_id, tid) references works (id, tid),
	foreign key (stage, tid) references work_stages (stage, tid)
    on update cascade
);

-- constraint for entries label
create table entries_code (
  tid smallint not null,
  
  code varchar(50) not null,
  description varchar(255) null,

  unique (code, tid),

	foreign key (tid) references users (id)
);

-- inputs
create table inputs (
	tid smallint not null,
	id bigint not null,

	entry varchar(50) not null,
	quantity float not null default 1,
	updated timestamp not null default now(), -- on update current_timestamp,
	
	primary key (id, tid),
	
	foreign key (entry, tid) references entries_code (code, tid)
	on update cascade
);

-- outputs
create table outputs (
	tid smallint not null,
	works_id bigint not null,
	inputs_id bigint not null,
	quantity float not null default 0,
	
	foreign key (works_id, tid) references works (id, tid),
	foreign key (inputs_id, tid) references inputs (id, tid)
);

