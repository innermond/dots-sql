drop procedure if exists add_companies;
delimiter //
create procedure add_companies
(in peak int)
begin
	declare	longname varchar(50);
	declare tin varchar(30);
	declare rn varchar(30);
	declare address varchar(200);
	declare is_client boolean;
	declare is_contractor boolean;

	declare i int default 0;
	start transaction;
		while i < peak do
			select left(to_base64(sha(rand())), 50) into longname;
			select left(uuid(), 30) into tin;
			select left(uuid(), 30) into rn;
			select left(to_base64(sha(rand())), 54) into address;
			set is_client = false;
			if rand() > 0.5 then set is_client = true; end if;
			set is_contractor = false;
			if rand() > 0.5 then set is_contractor = true; end if;
			insert into companies values
			(null, longname, tin, rn, address, is_client, is_contractor);
			set i = i + 1;
		end while;
	commit;
end //
delimiter ;
