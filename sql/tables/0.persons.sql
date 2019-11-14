start transaction;
-- users
create table users (
  id smallint unsigned not null primary key auto_increment,

  username varchar(16) not null,
  password varchar(64) not null, -- is hashed

  unique key (username)
) engine = innodb; 
-- while 0 value is allowed for users.id

-- need this zero user allowing currencies to have system defined (tid=0) values
insert into users
(id, username, password) values
(0, "zerouser", "$2a$14$Aij9nZ5Dym2JJiiAc2nY..ZIlCTZrtGJSRqU9VwifPsdK8KL3Vzky");

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
) engine = innodb;

-- user_roles
create table user_roles (
	user_id smallint unsigned not null,
	role_name varchar(16) not null,

	unique key (user_id, role_name),

	constraint foreign key (user_id) references users (id),
	constraint foreign key (role_name) references roles (name)
	on update cascade
) engine = innodb;

-- persons
create table persons (
  tid smallint unsigned not null,
  id tinyint unsigned not null auto_increment,
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

  constraint foreign key (tid) references users (id)
) engine = innodb;

create table person_phones (
  tid smallint unsigned not null,
  person_id tinyint unsigned not null,

  phone varchar(15) not null,
  
  unique key (person_id, tid, phone),
  
	constraint foreign key (person_id, tid) references persons (id, tid)
) engine = innodb;

create table person_emails (
  tid smallint unsigned not null,
  person_id tinyint unsigned not null,

  email varchar(30) not null, 
  
  unique key (person_id, tid, email),
  constraint foreign key (person_id, tid) references persons (id, tid)
) engine = innodb;
commit;

