select 'users'; 
insert into users
(id, username, password) values
(default, "gabiuser1", "$2a$04$1R5GldyuiTN/hpGUqcqchuFlyM7wib9c9J/cunII.VcanRwOv6h5C"),
(default, "gabiuser2", "$2a$04$nAwdi3Drz1OkoVSfjpiS6Ojl33Kr1jjYrbQ/fb9AinSvoB7nVYxOW"),
(default, "teouser1", "$2a$04$b9mu0F4h7TlWsVmHTZ401.12ITZImp5FWimNPZjf0p6T8WX.OIqdC");
select 'persons';
insert into persons values
<<<<<<< HEAD:sql/populate/persons.sql
(null, 'Gabriel Braila', '0723158571', 'gb@mob.ro', 1, 'Bucuresti, Ilioara 1A', 0, 0, 1),
(default, 'Stoian Teodora', '0728032259', 'stoian.teodoara@gmail.com', false, 'Bucuresti Dristor', 0, 0, 1),
(default, 'Gabor Toni', '0721032259', 'gt@gmail.com', true , 'Afumati, Centura', 0, 0, 2),
(default, 'Bari Irinel', '0798032259', 'bari@gmail.com', b'1', 'Undeva cu credit', 0, 0, 2),
(default, 'Wonder woman', '0728032659', 'ww@gmail.com', b'0', 'Undeva in spatiu', 0, 0, 3);
select 'person_phones';
=======
(null, 'Gabriel Braila', '0723158571', 'gb@mob.ro', true, 'Bucuresti, Ilioara 1A', 0, 0),
(default, 'Stoian Teodora', '0728032259', 'stoian.teodoara@gmail.com', false, 'Bucuresti Dristor', 0, 0),
(default, 'Gabor Toni', '0721032259', 'gt@gmail.com', true , 'Afumati, Centura', 0, 0),
(default, 'Bari Irinel', '0798032259', 'bari@gmail.com', true, 'Undeva cu credit', 0, 0),
(default, 'Wonder woman', '0728032659', 'ww@gmail.com', false, 'Undeva in spatiu', 0, 0);
>>>>>>> d8933f291f3aef6019b9c0b4ea1afc5af910d4c4:sql/populate/3.persons.sql
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
