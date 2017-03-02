-- persons
create table persons (
  id int unsigned not null primary key auto_increment,
  longname varchar(50) not null,
  phone varchar(15),
  email varchar(30),
  is_male bit(1) not null,
  address varchar(200),
  unique key (phone),
  unique key (email)
) engine = innodb;

create table person_phones (
  person_id int unsigned not null,
  phone varchar(15),
  unique key (person_id, phone),
  constraint foreign key (person_id) references persons (id)
  on delete cascade
) engine = innodb;

create table person_emails (
  person_id int unsigned not null,
  email varchar(30),
  unique key (person_id, email),
  constraint foreign key (person_id) references persons (id)
  on delete cascade
) engine = innodb;

create table users (
  id int unsigned not null primary key auto_increment,
  username varchar(8),
  password varchar(60) not null,
  salt varchar(20) not null,
  secret varchar(60) not null,
  unique key (username, password),
  unique key (salt),
  unique key (secret)
) engine = innodb;
