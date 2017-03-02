delimiter $
drop trigger if exists before_insert_outputs;
create trigger before_insert_outputs before insert on outputs
	for each row
	begin
		declare inputs_qty float;
		select quantity from inputs where ai_col = NEW.inputs_id into inputs_qty;
		if inputs_qty < NEW.quantity then
			set NEW.borrowed = NEW.quantity - inputs_qty;
			set NEW.quantity = inputs_qty;
		end if;
	end;$
drop trigger if exists before_update_outputs;
create trigger before_update_outputs before update on outputs
	for each row
	begin
		declare inputs_qty float;
		select quantity from inputs where ai_col = NEW.inputs_id into inputs_qty;
		if inputs_qty < NEW.quantity then
			set NEW.borrowed = NEW.quantity - inputs_qty;
			set NEW.quantity = inputs_qty;
		end if;
	end;$


drop trigger if exists after_insert_outputs;
create trigger after_insert_outputs after insert on outputs
	for each row
	begin
		update inputs set quantity = quantity - NEW.quantity where ai_col = NEW.inputs_id;
	end;$
drop trigger if exists after_update_outputs;
create trigger after_update_outputs after update on outputs
	for each row
	begin
		update inputs set quantity = quantity - NEW.quantity where ai_col = NEW.inputs_id;
	end;$
delimiter ;

-- ensures that for "proiect" units the coresponding quantity will be 1
delimiter $
drop trigger if exists before_insert_works;
create trigger before_insert_works before insert on works
	for each row
	begin
		if NEW.unit = 'proiect' then
			set NEW.quantity = 1;
		end if;
	end;$
drop trigger if exists before_update_works;
create trigger before_update_works before update on works
	for each row
	begin
		if NEW.unit = 'proiect' then
			set NEW.quantity = 1;
		end if;
	end;$
delimiter ;
