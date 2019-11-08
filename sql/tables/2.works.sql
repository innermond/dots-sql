-- work_units exists as constraints for works
create table work_units (
    tid int unsigned not null,
	unit varchar(30) not null primary key
) engine = innodb;

create table default_currencies (
	currency char(3) not null primary key
) engine = innodb;

-- currencies exists as constraints for works
create table my_currencies (
    tid int unsigned not null,
	currency char(3) not null primary key
) engine = innodb;

create view currencies as (
    select currency from default_currencies
    union
    select currency from my_currencies where tid=@tid
);

-- works
create table works (
	id int unsigned not null primary key auto_increment,
    tid int unsigned not null,

	label varchar(100) not null default '',
	quantity float not null default 1,
	unit varchar(30) not null default 'buc',
	unitprice numeric(15, 2),
	currency char(3) not null default 'ron',
	
    constraint works_unit_fk_work_units_unit foreign key (unit) references work_units (unit)
	on update cascade
	on delete restrict,
	constraint currencies_label_fk_works_currency foreign key (currency) references currencies (currency)
	on update cascade
	on delete restrict
) engine = innodb;

-- every work pass to ordered stages
create table work_stages (
<<<<<<< HEAD
	id int unsigned not null primary key auto_increment,
	stage varchar(20) not null default "",
	description varchar(150) null default "",
	ordered int unsigned not null,
	unique key (stage, ordered)
=======
    tid int unsigned not null,

	stage varchar(20) not null primary key,
	description varchar(150) null default "",
	ordered int unsigned not null,

	unique key (ordered, tid)
>>>>>>> 89e6d8a85b0c3b2675b5a5c9db07067d949b973f
) engine = innodb;

create table works_stages (
	work_id int unsigned not null,
	stage varchar(20) not null,

	constraint works_stages_id_fk_works_id foreign key (work_id) references works (id)
	on delete cascade,
	constraint works_stages_stage_fk_work_stages_stage foreign key (stage) references work_stages (stage)
	on update cascade
	on delete restrict
) engine = innodb;

