-- ref_sys_logs and ref_sys_log_details

CREATE OR REPLACE 
PACKAGE  pkg_ref_migration_log
AS
  procedure p_add_main_log( an_run_id migration_log.run_id%type, av_run_description migration_log.run_description%type, av_execution_status migration_log.execution_status%type);
  procedure p_upd_main_log;
  
  procedure p_add_step_log(an_run_id migration_steps_log.run_id%type, an_step_id migration_steps_log.step_id%type, av_execution_status migration_steps_log.execution_status%type, av_execution_status_details  migration_steps_log.execution_status_details%type);
  procedure p_upd_step_log(an_run_id migration_steps_log.run_id%type, an_step_id migration_steps_log.step_id%type, av_execution_status migration_steps_log.execution_status%type, av_execution_status_details  migration_steps_log.execution_status_details%type);

end pkg_ref_migration_log;
/
CREATE OR REPLACE PACKAGE BODY pkg_ref_migration_log
AS
  PROCEDURE p_add_main_log ( an_run_id migration_log.run_id%type, av_run_description migration_log.run_description%type, av_execution_status migration_log.execution_status%type)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      lv_host_name    migration_log.host_name%type;
      lv_username     migration_log.user_name%type;

      Begin
        SELECT SYS_CONTEXT ('userenv', 'host') INTO lv_host_name FROM DUAL;
        SELECT SYS_CONTEXT ('userenv', 'OS_USER') INTO lv_username FROM DUAL;
        insert into migration_log(run_id , exec_start_time , run_description , execution_status, host_name, user_name)
        values                   (an_run_id,systimestamp, av_run_description, av_execution_status,lv_host_name, lv_username);
        COMMIT;
   END p_add_main_log;

   --
   --
   
   procedure p_upd_main_log
   is
   begin
    null;
   end;

   --
   --
   
  procedure p_add_step_log(an_run_id migration_steps_log.run_id%type, an_step_id migration_steps_log.step_id%type, av_execution_status migration_steps_log.execution_status%type, av_execution_status_details  migration_steps_log.execution_status_details%type )
  is
 -- PRAGMA AUTONOMOUS_TRANSACTION;
  begin
    insert into migration_steps_log(run_id,    step_id,    exec_start_time, execution_status,    execution_status_details)
    values                         (an_run_id, an_step_id, systimestamp,    av_execution_status, av_execution_status_details);
    commit;
  end p_add_step_log;
  
  procedure p_upd_step_log(an_run_id migration_steps_log.run_id%type, an_step_id migration_steps_log.step_id%type, av_execution_status migration_steps_log.execution_status%type, av_execution_status_details  migration_steps_log.execution_status_details%type)
  is
  PRAGMA AUTONOMOUS_TRANSACTION;
  begin
    update migration_steps_log
    set execution_status = av_execution_status, execution_status_details=av_execution_status_details, execution_end_time=systimestamp
    where run_id=an_run_id and step_id=an_step_id;
    commit;
  end p_upd_step_log;
  
END pkg_ref_migration_log;
/

SHOW ERRORS;
