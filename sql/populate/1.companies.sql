start transaction;
insert into companies values
(@tid, null, 'sc volt-media srl', 'ro16728168', 'j40/14133/2004', false, true, default);
select last_insert_id() into @lastid;
insert into company_ibans values
(@tid, @lastid, 'rncb12345678974512', 'reifeissenbank suc. baba novac');
insert into company_addresses values
(@tid, @lastid, null, 'grivitei nr 37', null);
insert into companies values
(@tid, null, 'sc tipografix house srl', 'ro22345120', 'j40/12133/2014', false, true, default);
select last_insert_id() into @lastid;
insert into company_ibans values
(@tid, @lastid, 'rodev345678974512', 'procredit bank titan'),
(@tid, @lastid, 'as435345675676', 'procredit bank titan');
insert into company_addresses values
(@tid, @lastid, null, 'str. Stefan cel Mare', st_srid(point(80.0, 10.0), 4326));
commit;
