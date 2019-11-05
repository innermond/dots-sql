start transaction;
insert into companies values
(null, 'sc volt-media srl', 'ro16728168', 'j40/14133/2004', false, true, default);
select last_insert_id() into @lastid;
insert into company_ibans values
(null, @lastid, 'rncb12345678974512', 'reifeissenbank suc. baba novac');
insert into companies values
(null, 'sc tipografix house srl', 'ro22345120', 'j40/12133/2014', false, true, default);
select last_insert_id() into @lastid;
insert into company_ibans values
(null, @lastid, 'DK1820005000015611', 'procredit bank titan'),
(null, @lastid, 'DK7752950010016924', 'procredit bank titan');
commit;
