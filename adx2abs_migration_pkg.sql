

create or replace package body adx2abs_migration
as

procedure p_start_migration(av_desc varchar2)
is
ln_run_id migration_log.run_id%type;

begin
  ln_run_id := MIGRATION_RUN_ID_SEQ.Nextval;
  pkg_ref_migration_log.p_add_main_log( ln_run_id, av_desc, 'RUNNING');
 
-- p_get_adx_data;
  
  commit;
  For cr_steps in ( Select * from migration_steps order by step_position)
  Loop
    Begin
      pkg_ref_migration_log.p_add_step_log(ln_run_id , cr_steps.step_id, 'RUNNING' --execution_status
      , null -- execution_status_details
      );
      Execute Immediate cr_steps.step_plsql||'(an_run_id=>'||to_char(ln_run_id)||')';

      pkg_ref_migration_log.p_upd_step_log(ln_run_id , cr_steps.step_id, 'SUCCESS' -- execution_status
      
      , null -- execution_status_details
      );
      commit;
      Exception
      When Others Then
        update migration_steps_log set execution_status='FAILED', execution_status_details='HERE ADD ERROR DETAILS FROM RAISED ERROR'
              ,execution_end_time=SYSTIMESTAMP
        where run_id=ln_run_id and step_id=cr_steps.step_id;
        commit;
        if cr_steps.is_step_critical = 'Y'
        then
          update migration_log set execution_end_time = SYSTIMESTAMP, execution_status='FAILED',
                 run_description='Critical step ' ||cr_steps.step_name||' failed with error '||' HERE ADD ERROR DETAILS FROM RAISED ERROR'
          where run_id=ln_run_id;
          commit;
          raise;
        end if;
      End;
  End Loop;
end;

end  adx2abs_migration;
