-- entries
create table `entries` (
	type tinyint not null default 0,
	label varchar(100) not null default '',
	amount float not null default 1
) engine = innodb;

-- types
create table `types` (
	label varchar(100) not null,
	description varchar(255)
) engine = innodb;
