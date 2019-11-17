-- work_units exists as constraints for works
create table work_units (
	tid smallint,
	unit varchar(30),
	primary key (unit, tid),

	foreign key (tid) references users (id)
);

-- currencies exists as constraints for works
create table currencies (
	tid smallint not null default 0, -- 0 means default values
	currency char(3),
	primary key (currency, tid),

	foreign key (tid) references users (id)
);

-- works
create table works (
	tid smallint,
	id bigserial,
	primary key (id, tid), 

	label varchar(100) not null,
	quantity float not null default 1,
	unit varchar(30) not null default 'buc',
	unitprice numeric(15, 2),
	currency char(3) not null default 'ron',


	foreign key (unit, tid) references work_units (unit, tid)
	on update cascade
	-- foreign key (currency, tid) references currencies (currency, tid)
	-- on update cascade
);
create index on works (currency, tid);
/*
delimiter $$
create procedure currency_system_defined_exists_or_err
(in tenent_id smallint, in valute char(3))
begin
    if tenent_id!=0 and exists(select currency from currencies where tid=0 and currency=valute limit 1) then
        set @msgerr = concat("duplicate key currency value ", valute); 
        signal sqlstate '45000' 
        set message_text = @msgerr;
    end if;
end$$
-- check if system defined currency values exists already
create trigger currencies_before_insert 
before insert 
on currencies for each row 
begin
    call currency_system_defined_exists_or_err(new.tid, new.currency);
end$$
 -- update only there is no other system defined
create trigger currencies_before_update 
before update
on currencies for each row 
begin
    call currency_system_defined_exists_or_err(new.tid, new.currency);
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
create procedure currency_exists_or_err
(in tenent_id smallint, in valute char(3))
begin
    -- check existence as a foreign key
    if 0=exists(select currency from currencies where tid in (tenent_id, 0) and currency=valute limit 1) then
        set @msgerr = concat("no parent value for key currency: ", valute); 
        signal sqlstate '45000' 
        set message_text = @msgerr;
    end if;
end$$

-- ensure currency value exists in currencies.currency
create trigger works_before_insert 
before insert
on works for each row 
begin
    call currency_exists_or_err(new.tid, new.currency);
end$$

-- ensure currency value exists in currencies.currency
create trigger works_before_update 
before update 
on works for each row 
begin
    call currency_exists_or_err(new.tid, new.currency);
end$$
delimiter ;
*/
-- every work pass to ordered stages
create table work_stages (
	tid smallint not null,
	stage varchar(20) not null,
	description varchar(150) null,
	ordered int not null,

	-- stage is unique for an entire tid
	primary key (stage, tid),
	unique (tid, ordered),

	foreign key (tid) references users (id)
);

create table works_stages (
	tid smallint not null,
	work_id bigint not null,
	stage varchar(20) not null,
	primary key (work_id, stage, tid),

	foreign key (work_id, tid) references works (id, tid),
	foreign key (stage, tid) references work_stages (stage, tid)
    on update cascade
);

