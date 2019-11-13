drop procedure if exists add_users;
delimiter $$
create procedure add_users
(in peak int)
begin
    declare usr varchar(16);
    declare pwd varchar(64);
    declare i int default 0;
    start transaction;
        while i < peak do
			select left(uuid(), 16) into usr;
			select left(to_base64(sha(rand())), 64) into pwd;
            insert into users values
            (null, usr, pwd);
            set i=i+1;
        end while;
    commit;
end$$
delimiter ;
