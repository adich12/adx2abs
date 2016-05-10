-- drop table migration_steps;
-- create table migration_steps(step_id number not null, step_name varchar2(30) not null, step_description varchar2(1000), step_position number not null, is_step_critical char(1) not null, step_plsql varchar2(60) );
-- create table migration_log(run_id number, exec_start_time timestamp not null, execution_end_time timestamp, run_description varchar2(1000), execution_status varchar2(20) not null);
-- create table migration_steps_log(run_id number not null, step_id number not null, exec_start_time timestamp not null, execution_end_time timestamp, execution_status varchar2(20), execution_status_details VARCHAR2(1000));
-- create table migration_debug(run_id number not null, step_id number not null, exec_start_time timestamp not null, execution_end_time timestamp, execution_status varchar2(20), execution_status_details VARCHAR2(1000));

drop table REF_SOC_STG;
CREATE TABLE "ABS"."REF_SOC_STG" 
   (	
   run_id number not null enable,
      "V_ID_OLD" VARCHAR2(30 BYTE) not null enable, 
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
  is_new_or_changed  char(1) default 'N' not null enable -- N/C
  ,is_new_version    char(1) default 'N' not null enable -- N/Y or N/O(ld) ?? to be decided
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
 , info.OFFER_EXPIRATION_DATE as expiration_date
  , max(info.OFFER_VERSION_ID) as version_id
from mob_pp_uc_info info
group by 
info.OFFER_NAME || '|' || info.OFFER_VERSION_ID 
 , info.OFFER_NAME 
 , info.OFFER_VERSION_TYPE 
 , info.OFFER_DESCRIPTION 
 , info.OFFER_EFFECTIVE_DATE 
 , info.OFFER_EXPIRATION_DATE;

 select 'C' as is_new_or_changed, adx_soc.*, abs_soc.v_id as v_id_old, abs_soc.VERSION_ID as VERSION_ID_OLD, abs_soc.VERSION_TYPE as VERSION_TYPE_OLD, abs_soc.SOC as soc_old
        , abs_soc.SOC_DESCRIPTION as SOC_DESCRIPTION_OLd, abs_soc.EFFECTIVE_DATE as EFFECTIVE_DATE_OLD, abs_soc.EXPIRY_DATE AS EXPIRY_DATE_OLD
        CASE WHEN abs_soc.version_id != adx_soc.version_id Then 'Y' Else 'N' End  AS is_new_version
 from mob_pp_uc_info adx_soc
    , ref_soc abs_soc
 where adx_soc.soc=abs_soc.soc
    
 
 -- union 
