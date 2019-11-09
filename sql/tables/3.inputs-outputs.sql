-- constraint for entries label
create table entries_code (
  tid smallint unsigned not null,
  
  code varchar(50) not null,
  description varchar(255) null,

  unique key (code, tid),

	constraint foreign key (tid) references users (id)
	on delete restrict
) engine = innodb;

-- inputs
create table inputs (
	id bigint unsigned not null auto_increment,
	tid smallint unsigned not null,

	entry varchar(50) not null,
	quantity float not null default 1,
	updated datetime null on update current_timestamp,
	
	primary key (id, tid),
	
	constraint inputs_entry_fk_entries_code foreign key (entry, tid) references entries_code (code, tid)
	on delete restrict
	on update cascade
) engine = innodb;

-- outputs
create table outputs (
	works_id bigint unsigned not null,
	tid smallint unsigned not null,
	inputs_id bigint unsigned not null,
	quantity float not null default 0,
	
	constraint outputs_works_id_fk_works_id foreign key (works_id) references works (id)
	on delete restrict,
	constraint outputs_inputs_id_fk_inputs_id foreign key (inputs_id) references inputs (id)
	on delete restrict,
	constraint outputs_users_id_fk_tid foreign key (tid) references users (id)
	on delete restrict
) engine = innodb;

