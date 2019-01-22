select 'work_unit';
insert into work_units values ('buc'), ('ore'), ('mp'), ('proiect');
select 'currencies';
insert into currencies values ('ron'), ('eur'), ('usd');
select 'works';
insert into works values (null, 'D.T.P catalog "Șhaorma de Aur"', 1, 'proiect', 138, 'eur');
insert into works values (null, 'pliante "Țone de șârmărîe"', 1000, 'buc', 105, 'ron');
insert into works values (null, 'banner plastic printare fontă', 5, 'mp', 50, 'usd');
select 'work stages';
insert into work_stages values
('inițializată', 'datele initiale se extrag din comanda bruta (email, telefon, etc)', 1),
('verificată', 'datele inițiale sunt aprobate, comanda e formulată corect', 2),
('dată în lucru', 'comanda se trimite în atelier, pentru execuție', 3),
('finalizată', 'comanda a fost executată', 4);
select 'works_stages';
insert into works_stages values
(1, 'inițializată'), (1, 'verificată'),
(2, 'inițializată'), (2, 'verificată'), (2, 'dată în lucru'),
(3, 'inițializată'), (3, 'verificată'), (3, 'dată în lucru'), (3, 'finalizată');
