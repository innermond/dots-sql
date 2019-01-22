select 'entries_code';
insert into entries_code values ('DCL A4 150g', 'hartie dcl marime a4 gramaj 150g');
insert into entries_code values ('DCL A4 200g', 'hartie dcl marime a4 gramaj 200g');
insert into entries_code values ('DCL A4 300g', 'hartie dcl marime a4 gramaj 300g');
insert into entries_code values ('DCL SRA3 300g', 'hartie dcl marime sra3 gramaj 300g');
select 'inputs';
insert into inputs values (null, 'DCL A4 150g', 2500, default);
insert into inputs (entry, quantity) values ('DCL A4 200g', 1500);
insert into inputs values (null, 'DCL SRA3 300g', 5800, null);
insert into inputs values (null, 'DCL A4 300g', 1500, null);