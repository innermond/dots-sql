-- constraint for entries label
create table entries_code (
	code varchar(50) not null primary key
) engine = innodb;

-- an entry is a collection of traits - represents constraint of inputs label
create table entries (
	code varchar(50) not null,
	traits_id int unsigned not null,
	constraint entries_code_fk_entries_code_code foreign key (code) references entries_code (code)
	on delete restrict
	on update cascade,
	constraint entries_traits_id_fk_traits_id foreign key (traits_id) references traits (id)
	on delete restrict
) engine = innodb;
