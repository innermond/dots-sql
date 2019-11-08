start transaction;
select 'users'; 
-- test passords are gabiuser1 gabiuser2 teouser1
insert into users
(id, username, password) values
(default, "gabiuser1", "$2a$14$Aij9nZ5Dym2JJiiAc2nY..ZIlCTZrtGJSRqU9VwifPsdK8KL3Vzky"), 
(default, "gabiuser2", "$2a$14$15TQeheQKVkI7bysOpeETe99ktHTH8xMrxuqd4oAunRRfz3JLf6Uy"), 
(default, "teouser1", "$2a$14$klL5o18v1rub9FZzM50DDOg3ntE/GxZTLv8uYFd8KtF5wkxcU2Uqi"); 
set @tid=last_insert_id();
select 'persons';
insert into persons values
(null, @tid, 'Gabriel Braila', '0723158571', 'gb@mob.ro', true, 'Bucuresti, Ilioara 1A', 0, 0, 1),
(default, @tid, 'Stoian Teodora', '0728032259', 'stoian.teodoara@gmail.com', false, 'Bucuresti Dristor', 0, 0, 3),
(default, @tid, 'Gabor Toni', '0721032259', 'gt@gmail.com', true , 'Afumati, Centura', 0, 0, 2),
(default, @tid, 'Bari Irinel', '0798032259', 'bari@gmail.com', true, 'Undeva cu credit', 0, 0, 2),
(default, @tid, 'Wonder woman', '0728032659', 'ww@gmail.com', false, 'Undeva in spatiu', 0, 0, 3);
insert into person_phones values
(1, '072548677'),(1, '0745879652'),
(2, '0736852497'),
(3, '074998965');
select 'roles';
insert into roles values
('anonymous'),
('user'),
('admin'),
('superadmin');
select 'user_roles';
insert into user_roles values
(1, 'superadmin'),
(1, 'admin'),
(1, 'user'),
(2, 'admin'),
(3, 'user');
commit;
