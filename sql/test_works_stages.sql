drop procedure if exists test_works_stages;
delimiter $$
create procedure test_works_stages()
begin
	declare continue handler for sqlexception
	begin
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		set @fullerror  = concat('ERROR ', @errno, ' (', @sqlstate, ') ', @text);
		select @fullerror;
	end;
	start transaction;
	insert into works_stages (work_id) values(100);
	insert into works_stages (work_id, stage) values(1, 'non-existent stage');
	rollback;
end $$
delimiter ;
call test_works_stages;
