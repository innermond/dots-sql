-- users
create table users (
  id int unsigned not null primary key auto_increment,
  username varchar(16) not null,
  password varchar(64) not null, -- is hashed
  api_key varchar(64) null,
  unique key (username),
  unique key (api_key)
) engine = innodb;

-- roles
create table roles (
	name varchar(16) not null primary key
) engine = innodb;

-- user_roles
create table user_roles (
	user_id int unsigned not null,
	role_name varchar(16) not null,
	unique key (user_id, role_name),
	constraint foreign key (user_id) references users (id)
	on delete cascade,
	constraint foreign key (role_name) references roles (name)
	on update cascade
	on delete cascade
) engine = innodb;

-- persons
create table persons (
  id int unsigned not null primary key auto_increment,
  longname varchar(50) not null,
  phone varchar(15) null, -- unique index allow unknown values as nulls
  email varchar(30) null, 
  is_male bit(1) null, -- here null is unknown value
  address varchar(200) null,
	is_client boolean not null default false, -- a person can be client or contractor or both
	is_contractor boolean not null default false,
  oid int unsigned null,
	key ix_cc (is_client,is_contractor),
  unique key (phone),
  unique key (email),
  constraint foreign key (oid) references users (id)
	on delete set null
) engine = innodb;

create table person_phones (
  person_id int unsigned not null,
  phone varchar(15) not null,
  unique key (person_id, phone),
  constraint foreign key (person_id) references persons (id)
  on delete cascade
) engine = innodb;

create table person_emails (
  person_id int unsigned not null,
  email varchar(30) not null, 
  unique key (person_id, email),
  constraint foreign key (person_id) references persons (id)
  on delete cascade
) engine = innodb;

-- create salt when inserts occur

/*
-- better handle api_key creation on the app side (golang, php, python, etc)
delimiter //

create trigger users_before_insert
before insert on users for each row
begin
	set NEW.api_key = sha2(uuid(), 256);
	set NEW.password = sha2(concat(NEW.password, NEW.api_key), 256);
end; //

delimiter ;*/
