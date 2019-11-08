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
