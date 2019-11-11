-- constraint for entries label
create table entries_code (
  tid smallint unsigned not null,
  
  code varchar(50) not null,
  description varchar(255) null,

  unique key (code, tid),

	constraint foreign key (tid) references users (id)
) engine = innodb;

-- inputs
create table inputs (
	tid smallint unsigned not null,
	id bigint unsigned not null auto_increment,

	entry varchar(50) not null,
	quantity float not null default 1,
	updated datetime null on update current_timestamp,
	
	primary key (id, tid),
	
	constraint foreign key (entry, tid) references entries_code (code, tid)
	on update cascade
) engine = innodb;

-- outputs
create table outputs (
	tid smallint unsigned not null,
	works_id bigint unsigned not null,
	inputs_id bigint unsigned not null,
	quantity float not null default 0,
	
	constraint foreign key (tid) references users (id),
	constraint foreign key (works_id) references works (id),
	constraint foreign key (inputs_id) references inputs (id)
) engine = innodb;

