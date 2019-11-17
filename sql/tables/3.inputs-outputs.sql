-- constraint for entries label
create table entries_code (
  tid smallint not null,
  
  code varchar(50) not null,
  description varchar(255) null,

  unique (code, tid),

	foreign key (tid) references users (id)
);

-- inputs
create table inputs (
	tid smallint not null,
	id bigint not null,

	entry varchar(50) not null,
	quantity float not null default 1,
	updated timestamp not null default now(), -- on update current_timestamp,
	
	primary key (id, tid),
	
	foreign key (entry, tid) references entries_code (code, tid)
	on update cascade
);

-- outputs
create table outputs (
	tid smallint not null,
	works_id bigint not null,
	inputs_id bigint not null,
	quantity float not null default 0,
	
	foreign key (works_id, tid) references works (id, tid),
	foreign key (inputs_id, tid) references inputs (id, tid)
);

