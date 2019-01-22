insert into persons values
(null, 'Gabriel Braila', '0723158571', 'gb@mob.ro', 1, 'Bucuresti, Ilioara 1A', 0, 0),
(default, 'Stoian Teodora', '0728032259', 'stoian.teodoara@gmail.com', false, 'Bucuresti Dristor', 0, 0),
(default, 'Gabor Toni', '0721032259', 'gt@gmail.com', true , 'Afumati, Centura', 0, 0),
(default, 'Bari Irinel', '0798032259', 'bari@gmail.com', b'1', 'Undeva cu credit', 0, 0),
(default, 'Wonder woman', '0728032659', 'ww@gmail.com', b'0', 'Undeva in spatiu', 0, 0);
insert into person_phones values
(1, '072548677'),(1, '0745879652'),
(2, '0736852497'),
(3, '074998965');
insert into users
(id, person_id, username, password) values
(default, 1, "gabiuser1", "gabipass1"),
(default, 1, "gabiuser2", "gabipass2"),
(default, 2, "teouser1", "teopass1");
