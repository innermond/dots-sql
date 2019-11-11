-- work_units exists as constraints for works
create table work_units (
	tid smallint unsigned not null,
	unit varchar(30) not null,

	primary key (unit, tid),

	constraint foreign key (tid) references users (id)
) engine = innodb;

-- currencies exists as constraints for works
create table currencies (
	tid smallint unsigned not null default 0, -- 0 means default values
	currency char(3) not null,
	
	primary key (currency, tid),

	constraint foreign key (tid) references users (id)
) engine = innodb;

-- works
create table works (
	tid smallint unsigned not null,
	id bigint unsigned not null auto_increment,

	label varchar(100) not null default '',
	quantity float not null default 1,
	unit varchar(30) not null default 'buc',
	unitprice numeric(15, 2),
	currency char(3) not null default 'ron',

	primary key (id, tid), 
    key (currency, tid),

	constraint foreign key (unit, tid) references work_units (unit, tid)
	on update cascade
	-- constraint foreign key (currency, tid) references currencies (currency, tid)
	-- on update cascade
) engine = innodb;

delimiter $$
-- check if system defined or user defined currency values exists already
-- insert only new values regarding systems ones and user (tid, currency)
-- so other users (differnt tid) can have same currency value
create trigger currencies_before_insert 
before insert 
on currencies for each row 
begin
    declare tenent_id smallint;
    
    set tenent_id = new.tid;
    if new.tid=null then
        set tenent_id=0;
    end if;
    if exists(select currency from currencies where tid in (tenent_id, 0) and currency=new.currency limit 1) then
        set @msgerr = concat("duplicate key currency value ", new.currency); 
        signal sqlstate '45000' 
        set message_text = @msgerr;
    end if;
end$$

-- insted of foreign key update cascade
create trigger currencies_after_update 
after update
on currencies for each row 
begin
    -- currency is system defined
    -- this should be very rare
    -- need an index on works.currency
    if old.tid=0 then
        update works set currency=new.currency where currency=old.currency;
    else
        -- update user defined currency
        update works set currency=new.currency where tid=old.tid and currency=old.currency;
    end if;
end$$
-- instesd foreign key
-- check if value exists in parent table when insert/update currency
create procedure currency_exists
(in tenent_id smallint, in valute char(3))
begin
    -- check existence as a foreign key
    if 0=exists(select currency from currencies where tid in (tenent_id, 0) and currency=valute limit 1) then
        set @msgerr = concat("no parent value for key currency: ", valute); 
        signal sqlstate '45000' 
        set message_text = @msgerr;
    end if;
end$$

create trigger works_before_insert 
before insert 
on works for each row 
begin
    call currency_exists(new.tid, new.currency);
end$$

create trigger works_before_update 
before update 
on works for each row 
begin
    call currency_exists(new.tid, new.currency);
end$$
delimiter ;

-- every work pass to ordered stages
create table work_stages (
	tid smallint unsigned not null,

	stage varchar(20) not null,
	description varchar(150) null default "",
	ordered tinyint unsigned not null,

	primary key (stage, tid),
	unique key (tid, ordered),

	constraint foreign key (tid) references users (id)
) engine = innodb;

create table works_stages (
	tid smallint unsigned not null,
	work_id bigint unsigned not null,
	stage varchar(20) not null,

	constraint foreign key (work_id, tid) references works (id, tid),
	constraint foreign key (stage, tid) references work_stages (stage, tid)
    on update cascade
) engine = innodb;

