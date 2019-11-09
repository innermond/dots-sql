-- users
create table users (
  id smallint unsigned not null primary key auto_increment,

  username varchar(16) not null,
  password varchar(64) not null, -- is hashed

  unique key (username)
) engine = innodb;

-- roles
create table roles (
	name varchar(16) not null primary key
) engine = innodb;

-- user_roles
create table user_roles (
	user_id smallint unsigned not null,
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
  id mediumint unsigned not null auto_increment,
  tid smallint unsigned not null,
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

  constraint persons_tid_users_id foreign key (tid) references users (id)
	on delete no action
	-- TODO create a trigger on delete to set tid 0
) engine = innodb;

create table person_phones (
  person_id mediumint unsigned not null,
  tid smallint unsigned not null,

  phone varchar(15) not null,
  
  unique key (person_id, tid, phone),
  
	constraint foreign key (person_id, tid) references persons (id, tid)
  on delete cascade
) engine = innodb;

create table person_emails (
  person_id mediumint unsigned not null,
  tid smallint unsigned not null,

  email varchar(30) not null, 
  
  unique key (person_id, tid, email),
  constraint foreign key (person_id, tid) references persons (id, tid)
  on delete cascade
) engine = innodb;

