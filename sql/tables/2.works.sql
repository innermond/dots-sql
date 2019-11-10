-- work_units exists as constraints for works
create table work_units (
	tid smallint unsigned not null,

	unit varchar(30) not null,

	primary key (unit, tid),

	constraint foreign key (tid) references users (id)
	on update cascade
) engine = innodb;

-- currencies exists as constraints for works
create table currencies (
	tid smallint unsigned not null default 0, -- 0 means default values
	
	currency char(3) not null,
	
	primary key (currency, tid),

	constraint foreign key (tid) references users (id)
	on update cascade
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

	constraint foreign key (tid) references users (id)
	on update cascade,
	constraint foreign key (unit) references work_units (unit)
	on update cascade
	constraint foreign key (currency) references currencies (currency)
	on update cascade
) engine = innodb;

-- every work pass to ordered stages
create table work_stages (
	tid smallint unsigned not null,

	stage varchar(20) not null,
	description varchar(150) null default "",
	ordered tinyint unsigned not null,

	primary key (stage, tid),
	unique key (tid, ordered),

	constraint foreign key (tid) references users (id)
	on update cascade
) engine = innodb;

create table works_stages (
	work_id bigint unsigned not null,
	stage varchar(20) not null,

	constraint foreign key (work_id) references works (id)
	on update cascade,
	constraint foreign key (stage) references work_stages (stage)
	on update cascade
) engine = innodb;

