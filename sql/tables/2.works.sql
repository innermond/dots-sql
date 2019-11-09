-- work_units exists as constraints for works
create table work_units (
	tid smallint unsigned not null,

	unit varchar(30) not null,

	primary key (unit, tid)
) engine = innodb;

-- currencies exists as constraints for works
create table currencies (
	tid smallint unsigned not null default 0, -- 0 means default values
	
	currency char(3) not null,
	
	primary key (currency, tid)
) engine = innodb;

-- works
create table works (
	id bigint unsigned not null auto_increment,
	tid smallint unsigned not null,

	label varchar(100) not null default '',
	quantity float not null default 1,
	unit varchar(30) not null default 'buc',
	unitprice numeric(15, 2),
	currency char(3) not null default 'ron',

	primary key (id, tid), 

	constraint works_unit_fk_work_units_unit foreign key (unit) references work_units (unit)
	on update cascade
	on delete restrict,
	constraint currencies_label_fk_works_currency foreign key (currency) references currencies (currency)
	on update cascade
	on delete restrict
) engine = innodb;

-- every work pass to ordered stages
create table work_stages (
	tid smallint unsigned not null,

	stage varchar(20) not null,
	description varchar(150) null default "",
	ordered tinyint unsigned not null,

	primary key (stage, tid),
	unique key (tid, ordered)
) engine = innodb;

create table works_stages (
	work_id bigint unsigned not null,
	stage varchar(20) not null,

	constraint works_stages_id_fk_works_id foreign key (work_id) references works (id)
	on delete cascade,
	constraint works_stages_stage_fk_work_stages_stage foreign key (stage) references work_stages (stage)
	on update cascade
	on delete restrict
) engine = innodb;

