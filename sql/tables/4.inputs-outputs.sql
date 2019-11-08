-- constraint for entries label
create table entries_code (
  tid int unsigned not null,
  
  code varchar(50) not null,
  description varchar(255) null

  unique key (code, tid)
) engine = innodb;

-- inputs
create table inputs (
	id int unsigned not null primary key auto_increment,
    tid int unsigned not null,
	
    entry varchar(50) not null,
	quantity float not null default 1,
	updated datetime null on update current_timestamp,
	
    unique key (entry, tid),
	constraint inputs_entry_fk_entries_code foreign key (entry) references entries_code (code)
	on delete restrict
	on update cascade
) engine = innodb;

-- inputs history
create table inputs_history (
	id int unsigned not null primary key auto_increment,
    tid int unsigned not null,
	
    entry varchar(50) not null,
	quantity float not null default 1,
	created datetime null default current_timestamp,
	
    constraint inputs_history_entry_fk_entries_code foreign key (entry) references entries_code (code)
) engine = innodb;

-- outputs
create table outputs (
	works_id int unsigned not null,
	inputs_id int unsigned not null,
	quantity float not null default 0,
	
    constraint outputs_works_id_fk_works_id foreign key (works_id) references works (id)
	on delete restrict,
	constraint outputs_inputs_id_fk_inputs_id foreign key (inputs_id) references inputs (id)
	on delete restrict
) engine = innodb;

