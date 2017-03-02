-- traits_holder are generic containers of traits - exists as constraints for traits
create table traits_holder (
	holder varchar(50) not null primary key
) engine = innodb;

-- represents building blocks for entries
create table traits (
	id int unsigned not null primary key auto_increment,
	holder varchar(50) not null,
	trait varchar(10) not null,
	value varchar(10) not null,
	unique key (holder, trait, value),
	constraint traits_holder_fk_traits_holder_holder foreign key (holder) references traits_holder (holder)
	on delete restrict
	on update cascade
) engine = innodb;
