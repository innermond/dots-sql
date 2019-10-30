drop procedure if exists add_works;
delimiter //
create procedure add_works
(in peak int)
begin

	declare	label varchar(100);
	declare quantity float;
	declare unit varchar(30);
	declare unitprice numeric(15,2);
	declare currency char(3);

	declare oneormore boolean;
	declare lid_company int unsigned;

	declare i int default 0;

	declare duplicate_key condition for 1062; 
	declare continue handler for duplicate_key select 'duplicate key' as msg;
	
	start transaction;
		while i < peak do
			select left(to_base64(sha(rand())), 100) into label;
			select floor((rand() * (10-1+1))+1) into quantity;
			select 'buc' into unit; 
			select floor((rand() * (100-1+1))+1) into unitprice;
			select 'RON' into currency; 
			insert into works values
			(null, label, quantity, unit, unitprice, currency);

			set i = i + 1;

		end while;
	commit;
end //
delimiter ;
