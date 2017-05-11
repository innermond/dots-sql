-- persons
create table persons (
  id int unsigned not null primary key auto_increment,
  longname varchar(50) not null,
  phone varchar(15) null, -- unique index allow unknown values as nulls
  email varchar(30) null, 
  is_male bit(1) null, -- here null is unknown value
  address varchar(200) not null default '',
	is_client boolean not null default false, -- a person can be client or contractor or both
	is_contractor boolean not null default false,
	key ix_cc (is_client,is_contractor),
  unique key (phone),
  unique key (email)
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

create table users (
  id int unsigned not null primary key auto_increment,
  person_id int unsigned not null,
  username varchar(8) not null,
  password varchar(64) not null,
  salt varchar(64) not null,
  unique key (username, password),
  unique key (salt),
  constraint foreign key (person_id) references persons (id)
) engine = innodb;

-- create salt when inserts occur

delimiter //

create trigger users_before_insert
before insert on users for each row
begin
	set NEW.salt = sha2(uuid(), 256);
	set NEW.password = sha2(concat(NEW.password, NEW.salt), 256);
end; //

delimiter ;
