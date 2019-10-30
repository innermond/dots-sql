-- get user roles
select u.id, u.username, u.password, u.api_key, group_concat(ur.role_name) roles from users u join user_roles ur on u.id = ur.user_id where u.username = 'gabiuser1' group by u.id;
-- create company
insert into companies (?...) values(?...)
update companies set ? = ? where id=?
delete from companies where id=?
-- create company with iban
insert into companies (?...) values(?...)
select last_insertid() into lastid
insert into ibans (company_id, ?...) values (last_id,?...)

