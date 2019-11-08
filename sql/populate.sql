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
start transaction;
insert into companies values
(null, @tid, 'sc volt-media srl', 'ro16728168', 'j40/14133/2004', false, true, default);
select last_insert_id() into @lastid;
insert into ibans values
(@lastid, 'rncb12345678974512', 'reifeissenbank suc. baba novac');
insert into companies values
(null, @tid, 'sc tipografix house srl', 'ro22345120', 'j40/12133/2014', false, true, default);
select last_insert_id() into @lastid;
insert into ibans values
(@lastid, 'rodev345678974512', 'procredit bank titan'),
(@lastid, 'as435345675676', 'procredit bank titan');
commit;
select 'work_unit';
insert into work_units values (@tid, 'buc'), (@tid, 'ore'), (@tid, 'mp'), (@tid, 'proiect');
select 'currencies';
-- get currencies list from https://www.iban.com/currency-codes.html
insert into currencies (currency) values ('AFN'),('ALL'),('DZD'),('USD'),('EUR'),('AOA'),('XCD'),('ARS'),('AMD'),('AWG'),('AUD'),('AZN'),('BSD'),('BHD'),('BDT'),('BBD'),('BYR'),('BZD'),('XOF'),('BMD'),('BTN'),('INR'),('BOB'),('BOV'),('BAM'),('BWP'),('NOK'),('BRL'),('BND'),('BGN'),('BIF'),('CVE'),('KHR'),('XAF'),('CAD'),('KYD'),('CLF'),('CLP'),('CNY'),('COP'),('COU'),('KMF'),('CDF'),('NZD'),('CRC'),('HRK'),('CUC'),('CUP'),('ANG'),('CZK'),('DKK'),('DJF'),('DOP'),('EGP'),('SVC'),('ERN'),('ETB'),('FKP'),('FJD'),('XPF'),('GMD'),('GEL'),('GHS'),('GIP'),('GTQ'),('GBP'),('GNF'),('GYD'),('HTG'),('HNL'),('HKD'),('HUF'),('ISK'),('IDR'),('XDR'),('IRR'),('IQD'),('ILS'),('JMD'),('JPY'),('JOD'),('KZT'),('KES'),('KPW'),('KRW'),('KWD'),('KGS'),('LAK'),('LBP'),('LSL'),('ZAR'),('LRD'),('LYD'),('CHF'),('MOP'),('MKD'),('MGA'),('MWK'),('MYR'),('MVR'),('MRU'),('MUR'),('XUA'),('MXN'),('MXV'),('MDL'),('MNT'),('MAD'),('MZN'),('MMK'),('NAD'),('NPR'),('NIO'),('NGN'),('OMR'),('PKR'),('PAB'),('PGK'),('PYG'),('PEN'),('PHP'),('PLN'),('QAR'),('RON'),('RUB'),('RWF'),('SHP'),('WST'),('STN'),('SAR'),('RSD'),('SCR'),('SLL'),('SGD'),('XSU'),('SBD'),('SOS'),('SSP'),('LKR'),('SDG'),('SRD'),('SZL'),('SEK'),('CHE'),('CHW'),('SYP'),('TWD'),('TJS'),('TZS'),('THB'),('TOP'),('TTD'),('TND'),('TRY'),('TMT'),('UGX'),('UAH'),('AED'),('USN'),('UYI'),('UYU'),('UZS'),('VUV'),('VEF'),('VND'),('YER'),('ZMW'),('ZWL');
select 'works';
insert into works values (null, @tid, 'D.T.P catalog "Șhaorma de Aur"', 1, 'proiect', 138, 'eur');
insert into works values (null, @tid, 'pliante "Țone de șârmărîe"', 1000, 'buc', 105, 'ron');
insert into works values (null, @tid, 'banner plastic printare fontă', 5, 'mp', 50, 'usd');
select 'work stages';
insert into work_stages values
(@tid, 'inițializată', 'datele initiale se extrag din comanda bruta (email, telefon, etc)', 1),
(@tid, 'verificată', 'datele inițiale sunt aprobate, comanda e formulată corect', 2),
(@tid, 'dată în lucru', 'comanda se trimite în atelier, pentru execuție', 3),
(@tid, 'finalizată', 'comanda a fost executată', 4);
select 'works_stages';
insert into works_stages values
(1, 'inițializată'), (1, 'verificată'),
(2, 'inițializată'), (2, 'verificată'), (2, 'dată în lucru'),
(3, 'inițializată'), (3, 'verificată'), (3, 'dată în lucru'), (3, 'finalizată');
select 'entries_code';
insert into entries_code values (@tid, 'DCL A4 150g', 'hartie dcl marime a4 gramaj 150g');
insert into entries_code values (@tid, 'DCL A4 200g', 'hartie dcl marime a4 gramaj 200g');
insert into entries_code values (@tid, 'DCL A4 300g', 'hartie dcl marime a4 gramaj 300g');
insert into entries_code values (@tid, 'DCL SRA3 300g', 'hartie dcl marime sra3 gramaj 300g');
select 'inputs';
insert into inputs values (null, @tid,  'DCL A4 150g', 2500, default);
insert into inputs (tid, entry, quantity) values (@tid, 'DCL A4 200g', 1500);
insert into inputs values (null, @tid,  'DCL SRA3 300g', 5800, null);
insert into inputs values (null, @tid, 'DCL A4 300g', 1500, null);
