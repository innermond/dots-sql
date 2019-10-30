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

	declare iban char(34);
	declare bankname varchar(50);
	declare oneormore boolean;
	declare lid_company int unsigned;

	declare i int default 0;

	declare duplicate_key condition for 1062; 
	declare continue handler for duplicate_key select 'duplicate key' as msg;
	
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
			(null, longname, tin, rn, is_client, is_contractor, default);
			
			set oneormore = elt(floor(rand()*3+1), 0, 1, 2);
			select left(uuid(), 50) into bankname;
			select last_insert_id() into lid_company;
			select left(uuid(), 34) into iban;
			insert into company_addresses values
			(lid_company, address);
			insert into ibans values
			(lid_company, iban, bankname);

			select left(uuid(), 34) into iban;
			if oneormore = 0 then -- same bank one more iban
				insert into ibans values
				(lid_company, iban, bankname);

				elseif oneormore = 1 then -- new bank + new iban
				select left(uuid(), 50) into bankname;
				insert into ibans values
				(lid_company, iban, bankname);
					
				else -- new iban for old bank + new bank + new iban
				insert into ibans values
				(lid_company, iban, bankname);
				select left(uuid(), 50) into bankname;
				select left(uuid(), 34) into iban;
				insert into ibans values
				(lid_company, iban, bankname);

			end if;
			set i = i + 1;

		end while;
	commit;
end //
delimiter ;
