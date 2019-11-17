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

