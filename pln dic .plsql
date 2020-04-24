create or replace 
PACKAGE BODY           "PLN_GETMETA_PCKG" AS

     Function getDBSchemaName  (vApplicationName VARCHAR2 ) RETURN VarChar2 as 
    vSchemaName VarChar2(40);
    BEGIN
    vSchemaName:='ccccccc';
       if (upper(vApplicationName) like 'POULTRY') then 
         vSchemaName := 'HP_POULTRY';
       end if;  
       if (upper(vApplicationName) like 'COSTS') then 
         vSchemaName := 'HP_COSTS';
       end if; 
       
        if (upper(vApplicationName) like 'CONSOL%') then 
         vSchemaName := 'HP_CONSOL';
       end if;
       
         if (upper(vApplicationName) like 'D3') then 
         vSchemaName := 'HP_DEVEL2';
       end if;
       
    -- SELECT aa.DB_SCHEMA_NAME into vSchemaName FROM XX_META_APP_RDB_V aa where upper(aa.APPLICATION_NAME)=upper(vApplicationName);   
    /*
    CREATE OR REPLACE FORCE VIEW "INT_TRSB"."XX_META_APP_RDB_V" ("APPLICATION_ID", "APPLICATION_NAME", "DB_SCHEMA_NAME")
AS
  SELECT a.APP_ID application_id,
    UPPER(a.NAME) application_name,
    UPPER(RDB_USER) DB_schema_name
  FROM HYPPROD.HSPSYS_APPLICATION a
  LEFT JOIN HYPPROD.HSPSYS_DATASOURCE b
  ON a.DATASOURCE_ID=b.DATASOURCE_ID
  ORDER BY 1;
    */
      return vSchemaName;
    END;
    
     Function getSQLOpenPeriods (vApplicationName VARCHAR2 ,vPeriod Varchar2, vEntity Varchar2, vOwner Varchar2, vScenario Varchar2, vYear Varchar2) RETURN VarChar2
     as
     vSqlScenarioPeriods varchar2 (32000) := '
     with periods_id as 
 (          select ''Jan'' mon,  1 mon_id from dual 
  union all select ''Feb'' mon,  2 mon_id from dual
  union all select ''Mar'' mon,  3 mon_id from dual
  union all select ''Apr'' mon,  4 mon_id from dual
  union all select ''May'' mon,  5 mon_id from dual
  union all select ''Jun'' mon,  6 mon_id from dual
  union all select ''Jul'' mon,  7 mon_id from dual
  union all select ''Aug'' mon,  8 mon_id from dual
  union all select ''Sep'' mon,  9 mon_id from dual
  union all select ''Oct'' mon, 10 mon_id from dual
  union all select ''Nov'' mon, 11 mon_id from dual
  union all select ''Dec'' mon, 12 mon_id from dual
   )
, prc_st as (  SELECT --aa.PLAN_UNIT_ID,
  --aa.SCENARIO_ID,
 scn.object_name scenario_name ,
 syid.object_name START_YEAR,
 eyid.object_name END_YEAR,
 spid.object_name START_PERIOD,
 cast (pedst.mon_id as number ) START_PERIOD_ID,
 epid.object_name END_PERIOD,
 cast (peden.mon_id as number )  end_PERIOD_ID,
  --aa.VERSION_ID,
 --ver.object_name VERSION_name, 
 -- aa.ENTITY_ID,
 ent.object_name entity_name, 
 -- aa.OWNER_ID,
 own.object_name owner_name,  
 -- aa.ORIGINATOR_ID,
 -- org.object_name originator_name,   
 -- aa.PREV_OWNER_ID,
 -- aa.LAST_ACTION,
  aa.PROCESS_STATE 
FROM #ReplaceSchemaName#.HSP_PLANNING_UNIT aa
left join #ReplaceSchemaName#.hsp_object scn on scn.object_id = aa.SCENARIO_ID 
left join #ReplaceSchemaName#.hsp_object ver on ver.object_id = aa.VERSION_ID 
left join #ReplaceSchemaName#.hsp_object ent on ent.object_id = aa.ENTITY_ID 
left join #ReplaceSchemaName#.hsp_object own on own.object_id = aa.OWNER_ID 
--left join hsp_object org on org.object_id = aa.ORIGINATOR_ID 
left join #ReplaceSchemaName#.HSP_SCENARIO scnDet on scnDet.SCENARIO_ID = aa.SCENARIO_ID
left join #ReplaceSchemaName#.hsp_object syid on scnDet.START_YR_ID=syid.object_id
left join #ReplaceSchemaName#.hsp_object eyid on scnDet.END_YR_ID=eyid.object_id
left join #ReplaceSchemaName#.hsp_object spid on scnDet.START_TP_ID=spid.object_id
left join #ReplaceSchemaName#.hsp_object epid on scnDet.END_TP_ID=epid.object_id 
left join periods_id pedst on  pedst.mon =  spid.object_name
left join periods_id peden on  peden.mon =  epid.object_name 
where 
  ( ( (select mon_id from periods_id where UPPER(mon) = UPPER(''#vPeriod#'')) - pedst.mon_id  ) >=0  and ( peden.mon_id   -(select mon_id from periods_id where UPPER(mon) = UPPER(''#vPeriod#'')) ) > 0  
    and UPPER(syid.object_name) = UPPER(''#vYear#'') )  
   or  
    ( ( (select mon_id from periods_id where UPPER(mon) = UPPER(''#vPeriod#'')) - 1 ) >=0  and ( peden.mon_id   -(select mon_id from periods_id where UPPER(mon) = UPPER(''#vPeriod#'')) ) > 0  
    and UPPER( eyid.object_name ) = UPPER(''#vYear#'') )  
  
  )
 select * from prc_st 
where 
 (  PROCESS_STATE =1 
and ( UPPER(scenario_name) = UPPER(''#vScenario#'') and UPPER(entity_name) = UPPER(''#vEntity#''))  )
or 
 (
   PROCESS_STATE <> 1 
and ( UPPER(scenario_name) = UPPER(''#vScenario#'') and UPPER(entity_name) = UPPER(''#vEntity#'') and UPPER(nvl(owner_name,''####'')) =UPPER(''#vOwner#'')) ) 
     ';
     
     begin
 RETURN replace(replace(replace(replace(replace(replace(vSqlScenarioPeriods,'#ReplaceSchemaName#', getDBSchemaName  (vApplicationName )),'#vPeriod#',vPeriod),'#vEntity#', vEntity ),'#vOwner#', vOwner ),'#vScenario#',vScenario),'#vYear#',vYear);
     end;
     --,vPeriod,'#vPeriod#'), vEntity ,'#vEntity#') vOwner ,'#vOwner#')

    Function getSQLDimensions (vApplicationName VARCHAR2 ) RETURN VarChar2 as        
     vSQLDimensions VarChar2(32000) := ' 
    select object_id dimension_id , object_name dimension_name from #ReplaceSchemaName#.hsp_object where object_type=2
     ';        
    begin
    return null;
    end ;
    
 Function getSQLScenarioPeriods (vApplicationName VARCHAR2 ) RETURN VarChar2 as 
  vSQLScenarioPeriods VarChar2(32000) := ' select * from (
  select scn_name Scenario,sy_name StartYear,ey_name EndYear,sp_name StartPeriod,a1.month_id Sp_ID, ep_name EndPeriod,a2.month_id Ep_ID  
  from #ReplaceSchemaName#.HSP_SCENARIO scnDet
      left join (select syid.object_id scn_id, syid.object_name scn_name from  #ReplaceSchemaName#.hsp_object syid ) syid on scnDet.SCENARIO_ID=syid.scn_id
      left join (select syid.object_id sy_id,  syid.object_name sy_name  from  #ReplaceSchemaName#.hsp_object syid ) syid on scnDet.START_YR_ID=syid.sy_id
      left join (select eyid.object_id ey_id,  eyid.object_name ey_name  from  #ReplaceSchemaName#.hsp_object eyid ) eyid on scnDet.END_YR_ID=eyid.ey_id
      left join (select spid.object_id sp_id,  spid.object_name sp_name  from  #ReplaceSchemaName#.hsp_object spid ) spid on scnDet.START_TP_ID=spid.sp_id
      left join (select epid.object_id ep_id,  epid.object_name ep_name  from  #ReplaceSchemaName#.hsp_object epid ) epid on scnDet.END_TP_ID=epid.ep_id 
      left join XX_SRV_PERIODS a1 on a1.month_name=upper( sp_name )
      left join XX_SRV_PERIODS a2 on a2.month_name=upper( ep_name )  
       ) dd ';  
 begin 
   RETURN replace(vSQLScenarioPeriods,'#ReplaceSchemaName#',getDBSchemaName  (vApplicationName ));
 end ;
 
    

  Function getSQLMetaData (vApplicationName VarChar2,vDimensionName VarChar2) RETURN VarChar2 AS
    vSQLMetaData VarChar2(32000) := '
   with hsp_objects as (  SELECT /*+ FULL ( #ReplaceSchemaName#.hsp_object) CACHE( #ReplaceSchemaName#.hsp_object) */ 
              a.object_id child_id,
                            a.parent_id,
                            a.object_name child ,
                            d.object_name parent,
                            NVL(c.object_name,''NONE'') alias ,
                            a.position ,
                            a.generation ,
                            ALIASTBL_ID,
                            a.HAS_CHILDREN ,
                            a.object_type,
                            f.UDA_VALUE ,
                             attr.object_name ATRR_NAME
                          FROM  #ReplaceSchemaName#.hsp_object a   
                              LEFT JOIN ( select * from  #ReplaceSchemaName#.hsp_alias where  aliastbl_id=14) b  ON a.object_id=b.member_id
                              LEFT JOIN  #ReplaceSchemaName#.hsp_object c   ON c.object_id=b.alias_id
                              LEFT JOIN  #ReplaceSchemaName#.hsp_object d   ON d.object_id =a.parent_id 
                              LEFT JOIN  #ReplaceSchemaName#.HSP_MEMBER_TO_UDA e   ON e.Member_id =a.object_id 
                              LEFT JOIN  #ReplaceSchemaName#.HSP_UDA f   ON e.uda_id =f.uda_id 
                              LEFT JOIN  #ReplaceSchemaName#.HSP_MEMBER_TO_ATTRIBUTE MA   ON ''''||mA.MEMBER_ID =''''||a.object_id
                              LEFT JOIN  #ReplaceSchemaName#.hsp_object attr ON ''''||attr.object_id =''''||ma.ATTR_MEM_ID 
                              )
   , dic_parent_child as (select  *
                            FROM  hsp_objects a
                             start with
                              upper(parent) like upper('''||upper(vDimensionName) ||''') 
                            connect by
                              prior child_id=parent_id    )
   select PARENT,CHILD,ALIAS,child_id,UDA_VALUE,ATRR_NAME  from  dic_parent_child
  ';
  BEGIN       
    RETURN replace(replace(vSQLMetaData,'#ReplaceSchemaName#', getDBSchemaName  (vApplicationName )),'#ReplaceDimension#',vDimensionName);
  END getSQLMetaData;
  
  
 Function getSQLSecurityMetaDatav (vApplicationName VARCHAR2 ) RETURN VarChar2
   as  
   vSQLSecurityMetaDatav VarChar2(32000) := '
select * from (with hyp_objects as (  SELECT /*+ FULL (#ReplaceSchemaName#.hsp_object) CACHE(#ReplaceSchemaName#.hsp_object) */ 
              a.object_id child_id,
                            a.parent_id,
                            a.object_name child_name ,
                            d.object_name parent_name,
                            NVL(c.object_name,''NONE'') child_alias ,
                            a.position ,
                            a.generation ,
                            a.ALIASTBL_ID,
                            a.HAS_CHILDREN ,
                            a.object_type
                          FROM #ReplaceSchemaName#.hsp_object a   
                              LEFT JOIN ( select * from #ReplaceSchemaName#.hsp_alias where  aliastbl_id=14 ) b  ON a.object_id=b.member_id
                              LEFT JOIN #ReplaceSchemaName#.hsp_object c   ON c.object_id=b.alias_id
                              LEFT JOIN #ReplaceSchemaName#.hsp_object d   ON d.object_id =a.parent_id )
   , hyp_users as (          
              SELECT USER_ID,
                upper(child_name) user_name,
                "ROLE",  
                HUB_ROLES
              FROM #ReplaceSchemaName#.HSP_USERS a
              inner join  hyp_objects b on USER_ID=b.Child_id  )  
    , hyp_USERS_AND_GROUPS as (
                select aa.group_id , group_name,user_id,user_name ,role user_role,hub_roles user_hub_roles
                      from  #ReplaceSchemaName#.HSP_USERSINGROUP aa 
                left join   (  select  distinct   CHILD_NAME  group_name , child_id group_id 
                                          FROM  hyp_objects a
                                           start with
                                             OBJECT_TYPE = ''6'' 
                                           connect by
                                          prior child_id=parent_id
                             )  ab on ab.group_id=aa.group_id
                left join hyp_users ac on ac.user_id=aa.user_id ) 
     ,hyp_SECURITY as ( select hac.USER_id group_id, a.child_name group_name,
               object_id, b.child_name object_name, b.HAS_CHILDREN ,
               CASE   WHEN hac.access_mode = -1 THEN ''None''
                       WHEN hac.access_mode = 3 THEN ''Write''
                      WHEN hac.access_mode = 1 THEN ''Read''
                           ELSE ''UnKnown''
                 END   access_type,
               CASE   WHEN hac.flags = 0 THEN ''MEMBER''
                      WHEN hac.flags = 9 THEN ''@IDESCENDANTS''
                      WHEN hac.flags = 8 THEN ''@DESCENDANTS''
                      WHEN hac.flags = 6 THEN ''@ICHILDREN''
                      WHEN flags = 5 THEN ''@CHILDREN''
                      ELSE ''UnKnown''
                 END   member_type              
                 from #ReplaceSchemaName#.hsp_access_control hac
              left join hyp_objects a on a.Child_ID = hac.USER_ID
              left join hyp_objects b on b.Child_ID = hac.object_ID ) 
      , hyp_sec as (
               SELECT object_id,object_name,access_type, member_type , aa.USER_name , ab.HAS_CHILDREN
                        FROM hyp_USERS_AND_GROUPS aa
                         left join hyp_SECURITY ab  on upper(aa.USER_name)= upper(ab.group_name)
                        where  object_id is not null
                        union all 
               SELECT distinct object_id,object_name,access_type,member_type,aa.USER_name, ab.HAS_CHILDREN
                         FROM hyp_USERS_AND_GROUPS aa
                          left join hyp_SECURITY ab  on upper(aa.GROUP_name)= upper(ab.group_name)
                        where object_id is not null         
      )      
select object_id,object_name,max(access_type) access_type, member_type ,  USER_name, HAS_CHILDREN from hyp_sec 
group by  object_id,object_name, member_type ,  USER_name, HAS_CHILDREN ) ff
  ';
  BEGIN 
     RETURN replace(vSQLSecurityMetaDatav,'#ReplaceSchemaName#',getDBSchemaName  (vApplicationName ));
  END getSQLSecurityMetaDatav;
  
  
  Function getSQLSecurityUsers (vApplicationName VARCHAR2 ) RETURN VarChar2
    as 
     vSQLSecurityUsers VarChar2(32000) := '
  with hyp_objects as (  SELECT /*+ FULL (#ReplaceSchemaName#.hsp_object) CACHE(#ReplaceSchemaName#.hsp_object) */ 
              a.object_id child_id,
                            a.parent_id,
                            a.object_name child_name ,
                            d.object_name parent_name,
                            NVL(c.object_name,''NONE'') child_alias ,
                            a.position ,
                            a.generation ,
                            a.ALIASTBL_ID,
                            a.HAS_CHILDREN ,
                            a.object_type
                          FROM #ReplaceSchemaName#.hsp_object a   
                              LEFT JOIN ( select * from #ReplaceSchemaName#.hsp_alias where  aliastbl_id=14 ) b  ON a.object_id=b.member_id
                              LEFT JOIN #ReplaceSchemaName#.hsp_object c   ON c.object_id=b.alias_id
                              LEFT JOIN #ReplaceSchemaName#.hsp_object d   ON d.object_id =a.parent_id )
     SELECT USER_ID,
                upper(child_name) user_name,
                "ROLE",  
                HUB_ROLES
              FROM #ReplaceSchemaName#.HSP_USERS a
              inner join  hyp_objects b on USER_ID=b.Child_id   
  ';
  BEGIN 
     RETURN replace(vSQLSecurityUsers,'#ReplaceSchemaName#',getDBSchemaName  (vApplicationName ));
  END getSQLSecurityUsers;
 
  
   Function getSqlOpenWorkFlow (vApplicationName VARCHAR2 ,  vEntity Varchar2, vOwner Varchar2, vScenario Varchar2, vVersion Varchar2) RETURN VarChar2
     as
     vSqlOpenWorkFlow varchar2 (32000) := ' with x_str as(
   SELECT
   upper(ver.object_name) version_name,
   upper(scn.object_name) scenario_name,
 upper(ent.object_name) entity_name,   
 upper( own.object_name ) owner_name,   
  aa.PROCESS_STATE 
FROM #ReplaceSchemaName#.HSP_PLANNING_UNIT aa
left join #ReplaceSchemaName#.hsp_object scn on scn.object_id = aa.SCENARIO_ID 
left join #ReplaceSchemaName#.hsp_object ver on ver.object_id = aa.VERSION_ID 
left join #ReplaceSchemaName#.hsp_object ent on ent.object_id = aa.ENTITY_ID 
left join #ReplaceSchemaName#.hsp_object own on own.object_id = aa.OWNER_ID 
left join #ReplaceSchemaName#.HSP_SCENARIO scnDet on scnDet.SCENARIO_ID = aa.SCENARIO_ID
 ) 
 select * from x_str ab ,
      ( select 1 cnt from dual 
          union all 
       select 2 cnt from dual 
      ) aa
 where ( upper(version_name) = upper(''#vVersion#'') and upper(scenario_name) like upper(''#vScenario#'') ) and 
      ( ( aa.cnt=1  and upper(entity_name) like upper(''#vEntity#'') and owner_name is null and PROCESS_STATE=1 )
   or   ( aa.cnt=2  and upper(entity_name) like upper(''#vEntity#'') and upper(owner_name) = upper(''vOwner'')  )
  )' ;
  begin 
       begin
 RETURN  replace(replace(replace(replace(replace(vSqlOpenWorkFlow,'#ReplaceSchemaName#', getDBSchemaName  (vApplicationName )),'#vScenario#',vScenario),'#vEntity#', vEntity ),'#vOwner#', vOwner ),'#vVersion#',vVersion) ;
     end;
  end;
  
FUNCTION getUsersList (vApplicationName VARCHAR2) RETURN users_t 
    PIPELINED as 
  --   PRAGMA AUTONOMOUS_TRANSACTION;
    TYPE tEmpCurTyp_Curr IS REF CURSOR;  
    vSqlUsersCursor    tEmpCurTyp_Curr;  
    vSqlUserRecord    users_r ; 
    vCount Number;
begin
   OPEN vSqlUsersCursor FOR  getSQLSecurityUsers(vApplicationName) ;
   vCount :=0;
 LOOP
   FETCH vSqlUsersCursor INTO vSqlUserRecord;  -- fetch next row
   EXIT WHEN vSqlUsersCursor%NOTFOUND;   
    Pipe Row(vSqlUserRecord);  
    vCount:=vCount+1;
 END LOOP;

   CLOSE vSqlUsersCursor; 
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return;
    WHEN  NO_DATA_NEEDED THEN
      return;
    WHEN OTHERS THEN
    dbms_output.put_line('SQLCODE ' || SQLCODE || '; SQLERRM: ' || SQLERRM);
      RAISE;
 ROLLBACK;   
end;

 

FUNCTION getDimensionHierarshi (vApplicationName VARCHAR2,vDimensionName VARCHAR2) RETURN medata_t 
    PIPELINED as
   --  PRAGMA AUTONOMOUS_TRANSACTION;
    TYPE tEmpCurTyp_Curr IS REF CURSOR;  
    vSqlMetaCursor    tEmpCurTyp_Curr;  
    vSqlMetaRecord    medata_r ;
    vCount number;
    vTextBuffer VarChar2(32000) ;
begin 
   vTextBuffer := getSQLMetaData(vApplicationName,vDimensionName) ;
   -- dbms_output.put_line(vTextBuffer);
   OPEN vSqlMetaCursor FOR  vTextBuffer;

   vCount :=0;
 LOOP
   FETCH vSqlMetaCursor INTO vSqlMetaRecord;  -- fetch next row
   EXIT WHEN vSqlMetaCursor%NOTFOUND;   
    Pipe Row(vSqlMetaRecord);  
   vCount :=vCount +1 ; 
 END LOOP;
 
   CLOSE vSqlMetaCursor; 
 EXCEPTION
     WHEN NO_DATA_FOUND THEN
      return;
    WHEN  NO_DATA_NEEDED THEN
      return;
    WHEN OTHERS THEN
    dbms_output.put_line(vTextBuffer);
    dbms_output.put_line('SQLCODE ' || SQLCODE || '; SQLERRM: ' || SQLERRM);
      RAISE;
 ROLLBACK;    
end getDimensionHierarshi;

FUNCTION getDimensionCostsHierarshi (vDimensionName VARCHAR2) RETURN medata_t 
    PIPELINED as 
begin
  for vCurr in 
   ( select * from table (getDimensionHierarshi('Costs',vDimensionName))
    ) loop
      pipe row (vCurr);
    end loop;
end ;
 

FUNCTION getUserSecurityShort  (vApplicationName VARCHAR2, vUserName VARCHAR2) RETURN security_t  
    PIPELINED AS
   --  PRAGMA AUTONOMOUS_TRANSACTION;
  TYPE tEmpCurTyp_Curr IS REF CURSOR;  
  vSqlSecCursor    tEmpCurTyp_Curr; 
  vSecurity_record security_r ;  
  vCount Number;
begin 
   OPEN vSqlSecCursor FOR getSQLSecurityMetaDatav(vApplicationName)  
           || ' where USER_name like upper(''' || vUserName || ''') '  ;
   vCount :=0;        
 LOOP
   FETCH vSqlSecCursor INTO vSecurity_record;  -- fetch next row
   EXIT WHEN vSqlSecCursor%NOTFOUND;   
        Pipe Row(vSecurity_record);
   vCount :=vCount+1;     
 END LOOP;
 
   CLOSE vSqlSecCursor; 

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      return;
    WHEN  NO_DATA_NEEDED THEN
      return;
    WHEN OTHERS THEN
    dbms_output.put_line('SQLCODE ' || SQLCODE || '; SQLERRM: ' || SQLERRM);
    RAISE;
 ROLLBACK;    
end ;
 

FUNCTION getUserSecurityFull (vApplicationName VARCHAR2, vUserName VARCHAR2) RETURN security_t  
    PIPELINED AS
   --  PRAGMA AUTONOMOUS_TRANSACTION;
  TYPE tEmpCurTyp_Curr IS REF CURSOR;  
  vSqlSecCursor    tEmpCurTyp_Curr; 
  vSecurity_record security_r ;  
  
  vSqlSecChildCursor    tEmpCurTyp_Curr; 
  vSecurityChild_record medata_r ; 
  vCount Number;
begin 
   OPEN vSqlSecCursor FOR getSQLSecurityMetaDatav(vApplicationName)  
           || ' where USER_name like upper(''' || vUserName || ''') and member_type like ''MEMBER'''  ;
   vCount :=0;        
 LOOP
   FETCH vSqlSecCursor INTO vSecurity_record;  -- fetch next row
   EXIT WHEN vSqlSecCursor%NOTFOUND;   
        Pipe Row(vSecurity_record);
   vCount:=vCount+1;     
 --  dbms_output.put_line(vCount);
 END LOOP;
 
   CLOSE vSqlSecCursor; 
 

OPEN vSqlSecCursor FOR getSQLSecurityMetaDatav(vApplicationName)  
           || ' where USER_name like upper(''' || vUserName || ''') and member_type not like ''MEMBER'''  ;
 LOOP
   FETCH vSqlSecCursor INTO vSecurity_record;  -- fetch next row
   EXIT WHEN vSqlSecCursor%NOTFOUND;   
     vSecurity_record.member_type := 'MEMBER' ;
     
        Pipe Row(vSecurity_record);
       OPEN vSqlSecChildCursor FOR getSQLMetaData(vApplicationName,vSecurity_record.object_name);        
          LOOP
             FETCH vSqlSecChildCursor INTO vSecurityChild_record;  -- fetch next row
             EXIT WHEN vSqlSecChildCursor%NOTFOUND;  
                vSecurity_record.object_id := vSecurityChild_record.child_id ;
                vSecurity_record.object_name := vSecurityChild_record.child_name ;
                vSecurity_record.HAS_CHILDREN:= '0' ;
              --vSecurity_record.member_type := 'MEMBER' ;
              Pipe Row(vSecurity_record);
                vCount:=vCount+1; 
          END LOOP;   
 END LOOP;
  
EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return;
    WHEN  NO_DATA_NEEDED THEN
      return;
    WHEN OTHERS THEN
    dbms_output.put_line('SQLCODE ' || SQLCODE || '; SQLERRM: ' || SQLERRM);
      RAISE;
 ROLLBACK;   
end getUserSecurityFull;
  
     

END PLN_GETMETA_PCKG;