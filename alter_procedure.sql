set term^;

create or alter procedure alter_proc2
(proc_name varchar(31),
infection char(1)
)
returns(resualt blob)
as
declare variable FIELD_TYPE varchar(31);
declare variable FIELD_TYPE2 varchar(31);
declare variable PARAMETER_NAME varchar(31);
declare variable field_length integer;
declare variable  TEXT1 varchar(32123);
declare variable  TEXT_LEN varchar(255);
declare variable  TEXT2 varchar(1023);
declare variable II integer ;
declare variable  text_zap varchar(8);
declare variable  text_zap2 varchar(8);
declare variable TEXT_TELO blob;
declare variable TEXT_ITOG blob;
declare variable TEXT_LOG blob;
declare variable TEXT_IN_PARAM blob;
declare variable TEXT_TABLE blob;
declare variable TEXT_PARAMS_INS blob;
declare variable TEXT_PARAMS_INS_FULL blob;
declare variable TEXT_PARAMS_INS2 blob;
declare variable TEXT_PARAMS_INS_FULL2 blob;
declare variable TEXT_INSERT blob;
begin
/*Создаем начало процедуры*/
TEXT1='create or alter procedure '||:proc_name||'('||ascii_char(0x0D);
II=0;
/*Добавляем входные параметры процедуры*/
TEXT_IN_PARAM='';
TEXT_PARAMS_INS_FULL='';
TEXT_PARAMS_INS_FULL2='';
for select field.rdb$field_type, field.rdb$field_length, trim(PP.rdb$PARAMETER_NAME) from rdb$procedure_parameters PP
join rdb$fields  field on PP.rdb$field_source=field.rdb$field_name
where PP.rdb$procedure_name=:proc_name
and PP.rdb$parameter_type='0'
into :FIELD_TYPE,:field_length, :PARAMETER_NAME
do
begin
/*тип данных*/
FIELD_TYPE=case  :FIELD_TYPE
when '7' then 'SMALLINT'
when '8' then 'INTEGER'
when '10' then 'FLOAT'
when '12' then 'DATE'
when '13' then 'TIME'
when '14' then 'CHAR'
when '16' then 'BIGINT'
when '27' then 'DOUBLE PRECISION'
when '35' then 'TIMESTAMP'
when '37' then 'VARCHAR'
when '261' then 'BLOB'
end;
if (II=1) then
    begin
    text_zap=','||ascii_char(0x0D);
    text_zap2=',';
    end
else 
    begin
    text_zap='';
    text_zap2='';
    end
if (:FIELD_TYPE in ('VARCHAR','CHAR'))  then
    TEXT_LEN='('||:field_length||')';
else
    TEXT_LEN= '';
TEXT2=:text_zap||:PARAMETER_NAME ||' '||trim(:FIELD_TYPE)||:TEXT_LEN;
TEXT_PARAMS_INS=:text_zap2||':'||:PARAMETER_NAME;
TEXT_PARAMS_INS_FULL=:TEXT_PARAMS_INS_FULL||:TEXT_PARAMS_INS;
TEXT_PARAMS_INS2=:text_zap2||:PARAMETER_NAME;
TEXT_PARAMS_INS_FULL2=:TEXT_PARAMS_INS_FULL2||:TEXT_PARAMS_INS2;
TEXT_IN_PARAM=:TEXT_IN_PARAM||:TEXT2;
II=1;
/* TEXT_LOG=TEXT_LOG|||:PARAMETR_NAME|'||:'||:PARAMETR_NAME; */
end
TEXT1=:TEXT1||:TEXT_IN_PARAM;
TEXT1=:TEXT1||')'||ascii_char(0x0D)||'returns (';
II=0;
/*Добавляем выходные параметры процедуры*/
for select field.rdb$field_type, field.rdb$field_length, trim(PP.rdb$PARAMETER_NAME) from rdb$procedure_parameters PP
join rdb$fields  field on PP.rdb$field_source=field.rdb$field_name
where PP.rdb$procedure_name=:proc_name
and PP.rdb$parameter_type='1'
into :FIELD_TYPE,:field_length, :PARAMETER_NAME
do
begin
/*тип данных*/
FIELD_TYPE=case  :FIELD_TYPE
when '7' then 'SMALLINT'
when '8' then 'INTEGER'
when '10' then 'FLOAT'
when '12' then 'DATE'
when '13' then 'TIME'
when '14' then 'CHAR'
when '16' then 'BIGINT'
when '27' then 'DOUBLE PRECISION'
when '35' then 'TIMESTAMP'
when '37' then 'VARCHAR'
when '261' then 'BLOB'
end;
if (II=1) then
    text_zap=','||ascii_char(0x0D);
else 
   text_zap='';
if (:FIELD_TYPE in ('VARCHAR','CHAR'))  then
TEXT_LEN='('||:field_length||')';
else
TEXT_LEN= '';
TEXT2=:text_zap||:PARAMETER_NAME ||' '||trim(:FIELD_TYPE)||:TEXT_LEN;
TEXT1=:TEXT1||:TEXT2;
II=1;
end
TEXT1=:TEXT1||')'||ascii_char(0x0D)||'as'||ascii_char(0x0D);
/*Добавляем переменные*/
select substring(rdb$procedure_source from 1 for (position('begin' in rdb$procedure_source)-1) )  from rdb$procedures where   rdb$procedure_name=:proc_name
into :TEXT_TELO;
TEXT_ITOG=:TEXT1||:TEXT_TELO||ascii_char(0x0D)||'begin'||ascii_char(0x0D);
/*Добавляем логирование*/
if (infection='1') then  begin
/*созадаем таблицу для логов */
TEXT_TABLE='CREATE TABLE '||:proc_name||'_LOG'||' ('||ascii_char(0x0D);
TEXT_TABLE=:TEXT_TABLE||:TEXT_IN_PARAM||ascii_char(0x0D)||');';
execute statement (:TEXT_TABLE);
/*добавляем метку заражения процедуры*/
TEXT_ITOG=:TEXT_ITOG||ascii_char(0x0D)||'/*herpes_start*/'||ascii_char(0x0D);
/*тут вставляем код*/
TEXT_INSERT='INSERT INTO '||:proc_name||'_LOG ('||:TEXT_PARAMS_INS_FULL2||' )'||ascii_char(0x0D)||'VALUES ('||:TEXT_PARAMS_INS_FULL||');'||ascii_char(0x0D);
TEXT_ITOG=:TEXT_ITOG||:TEXT_INSERT;
/*добавляем метку*/
TEXT_ITOG=:TEXT_ITOG||ascii_char(0x0D)||'/*herpes_end*/'||ascii_char(0x0D);
/*Добавляем хвост процы*/
select substring(rdb$procedure_source from (position('begin' in rdb$procedure_source)+5) for 32000 )  from rdb$procedures where   rdb$procedure_name=:proc_name
into :TEXT_TELO;
TEXT_ITOG=:TEXT_ITOG||:TEXT_TELO;
end
/*Удаляем логирование*/
if (infection='0') then  begin
select substring(rdb$procedure_source from (position('herpes_end' in rdb$procedure_source)+14) for 32000 )  from rdb$procedures where   rdb$procedure_name=:proc_name
into :TEXT_TELO;
TEXT_ITOG=:TEXT_ITOG||:TEXT_TELO;
end
resualt=:TEXT_ITOG;
suspend;
end^

create or alter procedure recompil_2
(
proc_name varchar(31),
infection char(1)
)
returns(resualt varchar(255))
as
declare variable TEXT blob;
declare variable TEXT_TABLE blob;
declare variable inf integer;
begin
select position('herpes' in  rdb$procedure_source) from  rdb$procedures where   rdb$procedure_name='TEST1'
into :inf;
/*Заражаем процедуру*/
if (infection='1') then
begin
/* Проверяем заражена ли проца*/
if (inf=0) then
begin
select resualt||';' from alter_proc2(:proc_name,:infection)
into :TEXT ;
execute statement (:TEXT);
resualt='Заражение выполнено!';
end
if (inf<>0) then
resualt='Проца уже заражена';
end
/*Лечим процедуру*/
if (infection='0') then
begin
/*Проверяем требуется ли лечение*/
if (inf=0) then
resualt='Лечение не требуется!';
else
begin
/*Тут код для лечения*/
select resualt||';' from alter_proc2(:proc_name,:infection)
into :TEXT ;
execute statement (:TEXT);
TEXT_TABLE='DROP TABLE '||:proc_name||'_LOG;';
execute statement (:TEXT_TABLE);
resualt='Проца вылечена!';
end
end
suspend;
end^
