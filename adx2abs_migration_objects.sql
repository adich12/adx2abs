-- drop table migration_steps;
-- create table migration_steps(step_id number not null, step_name varchar2(30) not null, step_description varchar2(1000), step_position number not null, is_step_critical char(1) not null, step_plsql varchar2(60) );
-- create table migration_log(run_id number, exec_start_time timestamp not null, execution_end_time timestamp, run_description varchar2(1000), execution_status varchar2(20) not null);
-- create table migration_steps_log(run_id number not null, step_id number not null, exec_start_time timestamp not null, execution_end_time timestamp, execution_status varchar2(20), execution_status_details VARCHAR2(1000));
-- create table migration_debug(run_id number not null, step_id number not null, exec_start_time timestamp not null, execution_end_time timestamp, execution_status varchar2(20), execution_status_details VARCHAR2(1000));


  -------- SOCS SOCS SOCS
  
drop table REF_SOC_STG;
CREATE TABLE "ABS"."REF_SOC_STG" 
   (	
  run_id number not null enable,
    "V_ID" VARCHAR2(30 BYTE) , 
	"SOC" VARCHAR2(20 BYTE) NOT NULL ENABLE, 
	"VERSION_ID" NUMBER NOT NULL ENABLE, 
	"VERSION_TYPE" VARCHAR2(20 BYTE) NOT NULL ENABLE, 
	"SOC_DESCRIPTION" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"EFFECTIVE_DATE" DATE NOT NULL ENABLE, 
	"EXPIRY_DATE" DATE, 
  "V_ID_OLD" VARCHAR2(30 BYTE) , 
  "SOC_OLD" VARCHAR2(20 BYTE) NOT NULL ENABLE, 
	"VERSION_ID_OLD" NUMBER NOT NULL ENABLE, 
	"VERSION_TYPE_OLD" VARCHAR2(20 BYTE) NOT NULL ENABLE, 
	"SOC_DESCRIPTION_OLD" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"EFFECTIVE_DATE_OLD" DATE NOT NULL ENABLE, 
	"EXPIRY_DATE_OLD" DATE,
  ,is_new_soc_or_version    char(1) not null enable -- N=NEW SOC,V=NEW VERSION
   ) 
 --  partition by range(run_id) interval(1)
 -- (Partition P1 values less than (2))
 ;
  
 create or replace view ref_adx_mob_socs as
 select Distinct info.OFFER_NAME || '|' || info.OFFER_VERSION_ID as v_id
 , info.OFFER_NAME as soc
 , info.OFFER_VERSION_TYPE as version_type
 , info.OFFER_DESCRIPTION as soc_description
 , info.OFFER_EFFECTIVE_DATE as effective_date
 , info.OFFER_EXPIRATION_DATE as expiry_date
  , info.OFFER_VERSION_ID as VERSION_ID
  ,UC_PRIT_TYPE
  ,FLAT_QUANTITY_UOM
from mob_pp_uc_info info;

----  PACKAGES PACKAGES PACKAGES
create table ref_packages_stg(
  run_id number not null enable,
  "V_ID" VARCHAR2(30 BYTE) NOT NULL ENABLE, 
	"PACKAGE_ID" NUMBER NOT NULL ENABLE, 
	"VERSION_ID" NUMBER NOT NULL ENABLE, 
	"VERSION_TYPE" VARCHAR2(16 BYTE) NOT NULL ENABLE, 
	"SOC_V_ID" VARCHAR2(30 BYTE) NOT NULL ENABLE, 
	"EFFECTIVE_DATE" DATE NOT NULL ENABLE, 
	"EXPIRY_DATE" DATE, 
	"DESCRIPTION" VARCHAR2(200 BYTE), 
	"PRIORITY" NUMBER NOT NULL ENABLE,
    "V_ID_OLD" VARCHAR2(30 BYTE) NOT NULL ENABLE, 
	"PACKAGE_ID_OLD" NUMBER NOT NULL ENABLE, 
	"VERSION_ID_OLD" NUMBER NOT NULL ENABLE, 
	"VERSION_TYPE_OLD" VARCHAR2(16 BYTE) NOT NULL ENABLE, 
	"SOC_V_ID_OLD" VARCHAR2(30 BYTE) NOT NULL ENABLE, 
	"EFFECTIVE_DATE_OLD" DATE NOT NULL ENABLE, 
	"EXPIRY_DATE_OLD" DATE, 
	"DESCRIPTION_OLD" VARCHAR2(200 BYTE), 
	"PRIORITY_OLD" NUMBER NOT NULL ENABLE,
  is_new_pack_or_version    char(1) not null enable -- N=NEW SOC,V=NEW VERSION

   ) -- partition by range(run_id) interval(1)
   ;
   
 -- PACKAGES VIEW FOR ADX PP_UC_INFO column translation
 
   create or replace view ref_adx_mob_packs as
 select Distinct adx_pack.OFFER_NAME || '|' || adx_pack.OFFER_VERSION_ID as soc_v_id,
          adx_pack.PACKAGE_ID || '|' || adx_pack.PACKAGE_VERSION_ID as V_ID,
          adx_pack.PACKAGE_ID,
          adx_pack.PACKAGE_VERSION_ID as VERSION_ID,
          adx_pack.PACKAGE_VERSION_TYPE as version_type,
          adx_pack.PACKAGE_EFFECTIVE_DATE as effective_date,
          adx_pack.PACKAGE_EXPIRATION_DATE as expiry_date,
          adx_pack.PACKAGE_NAME as description,
          adx_pack.PACKAGE_PRIORITY as priority,
          UC_PRIT_TYPE,
          FLAT_QUANTITY_UOM
from mob_pp_uc_info adx_pack;

   
   INSERT INTO REF_PACKAGES (V_ID, PACKAGE_ID, VERSION_ID, VERSION_TYPE, SOC_V_ID, EFFECTIVE_DATE,  EXPIRY_DATE,  DESCRIPTION, PRIORITY)
--select count(*) from (
select distinct info.PACKAGE_ID || '|' || info.PACKAGE_VERSION_ID, info.PACKAGE_ID, info.PACKAGE_VERSION_ID, info.PACKAGE_VERSION_TYPE, info.OFFER_NAME || '|' || info.OFFER_VERSION_ID ,
info.PACKAGE_EFFECTIVE_DATE, info.PACKAGE_EXPIRATION_DATE, info.PACKAGE_NAME, info.PACKAGE_PRIORITY
from pp_uc_info info
where
((info.uc_prit_type in ('Flat') and info.FLAT_QUANTITY_UOM like '%Bytes')
OR info.uc_prit_type in ('Flat per quantity'))
and not exists (select 1 from REF_PACKAGES where REF_PACKAGES.V_ID = (info.PACKAGE_ID || '|' || info.PACKAGE_VERSION_ID));
--)
