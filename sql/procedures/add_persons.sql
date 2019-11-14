drop procedure if exists add_persons;
delimiter $$
create procedure add_persons
(in i int, in peak int)
begin
    declare lname varchar(50);
    declare phon varchar(15);
    declare em varchar(30);
    declare is_m boolean;
    declare addr varchar(200);
    declare is_cli boolean;
    declare is_con boolean;
    declare tid smallint;
    declare pid tinyint;
    declare ii int default 0;
    start transaction;
        while i < peak do
			select left(uuid(), 50) into lname;
			select left(to_base64(sha(rand())), 15) into phon;
			select left(to_base64(sha(rand())), 30) into em;
			set is_m = false;
			if rand() > 0.5 then set is_m = true; end if;
			select left(to_base64(sha(rand())), 200) into addr;
			set is_cli = false;
			if rand() > 0.5 then set is_cli = true; end if;
			set is_con = false;
			if rand() > 0.5 then set is_con = true; end if;
            set tid=i;
            if i > 65535 then
                set tid=mod(i,65535);
            end if;
            select next value for persons_seq into pid;
            insert into persons values
			(tid, pid, lname, phon, em, is_m, addr, is_cli, is_con);
		    set ii=0;
            while ii < 3 do 
                select left(to_base64(sha(rand())), 15) into phon;
                insert into person_phones values
                (tid, pid, phon);
                set ii=ii+1;
            end while;
            set ii=0;
            while ii < 5 do 
                select left(to_base64(sha(rand())), 30) into em;
                insert into person_emails values
                (tid, pid, em);
                set ii=ii+1;
            end while;
            set i=i+1;
        end while;
    commit;
end$$
delimiter ;
