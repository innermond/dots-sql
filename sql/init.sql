drop database if exists printoo;
-- create utf8-mb4 database
create database printoo character set = utf8mb4 collate = utf8mb4_unicode_ci;
use printoo;
-- database needs to store date in utc +0:00
set global time_zone = '+0:00';
set global sql_mode = 'no_auto_value_on_zero';

