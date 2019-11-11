select 'work_unit';
insert into work_units values (@tid, 'buc'), (@tid, 'ore'), (@tid, 'mp'), (@tid, 'proiect');
select 'currencies';
-- get currencies list from https://www.iban.com/currency-codes.html
insert into currencies (currency) values ('AFN'),('ALL'),('DZD'),('USD'),('EUR'),('AOA'),('XCD'),('ARS'),('AMD'),('AWG'),('AUD'),('AZN'),('BSD'),('BHD'),('BDT'),('BBD'),('BYR'),('BZD'),('XOF'),('BMD'),('BTN'),('INR'),('BOB'),('BOV'),('BAM'),('BWP'),('NOK'),('BRL'),('BND'),('BGN'),('BIF'),('CVE'),('KHR'),('XAF'),('CAD'),('KYD'),('CLF'),('CLP'),('CNY'),('COP'),('COU'),('KMF'),('CDF'),('NZD'),('CRC'),('HRK'),('CUC'),('CUP'),('ANG'),('CZK'),('DKK'),('DJF'),('DOP'),('EGP'),('SVC'),('ERN'),('ETB'),('FKP'),('FJD'),('XPF'),('GMD'),('GEL'),('GHS'),('GIP'),('GTQ'),('GBP'),('GNF'),('GYD'),('HTG'),('HNL'),('HKD'),('HUF'),('ISK'),('IDR'),('XDR'),('IRR'),('IQD'),('ILS'),('JMD'),('JPY'),('JOD'),('KZT'),('KES'),('KPW'),('KRW'),('KWD'),('KGS'),('LAK'),('LBP'),('LSL'),('ZAR'),('LRD'),('LYD'),('CHF'),('MOP'),('MKD'),('MGA'),('MWK'),('MYR'),('MVR'),('MRU'),('MUR'),('XUA'),('MXN'),('MXV'),('MDL'),('MNT'),('MAD'),('MZN'),('MMK'),('NAD'),('NPR'),('NIO'),('NGN'),('OMR'),('PKR'),('PAB'),('PGK'),('PYG'),('PEN'),('PHP'),('PLN'),('QAR'),('RON'),('RUB'),('RWF'),('SHP'),('WST'),('STN'),('SAR'),('RSD'),('SCR'),('SLL'),('SGD'),('XSU'),('SBD'),('SOS'),('SSP'),('LKR'),('SDG'),('SRD'),('SZL'),('SEK'),('CHE'),('CHW'),('SYP'),('TWD'),('TJS'),('TZS'),('THB'),('TOP'),('TTD'),('TND'),('TRY'),('TMT'),('UGX'),('UAH'),('AED'),('USN'),('UYI'),('UYU'),('UZS'),('VUV'),('VEF'),('VND'),('YER'),('ZMW'),('ZWL');
insert into currencies values (@tid, 'blk');
select 'works';
insert into works values (@tid, null, 'D.T.P catalog "Șhaorma de Aur"', 1, 'proiect', 138, 'eur');
insert into works values (@tid, null, 'pliante "Țone de șârmărîe"', 1000, 'buc', 105, 'ron');
insert into works values (@tid, null, 'banner plastic printare fontă', 5, 'mp', 50, 'usd');
select 'work stages';
insert into work_stages values
(@tid, 'inițializată', 'datele initiale se extrag din comanda bruta (email, telefon, etc)', 1),
(@tid, 'verificată', 'datele inițiale sunt aprobate, comanda e formulată corect', 2),
(@tid, 'dată în lucru', 'comanda se trimite în atelier, pentru execuție', 3),
(@tid, 'finalizată', 'comanda a fost executată', 4);
select 'works_stages';
insert into works_stages values
(@tid, 1, 'inițializată'), (@tid, 1, 'verificată'),
(@tid, 2, 'inițializată'), (@tid, 2, 'verificată'), (@tid, 2, 'dată în lucru'),
(@tid, 3, 'inițializată'), (@tid, 3, 'verificată'), (@tid, 3, 'dată în lucru'), (@tid, 3, 'finalizată');
