/*

MDX generator from form definitions 

you need to change V_HSP_APP_NAME view to hardcode application name 

to get MDX create query  from V_HSP_FORMS_MDX_Q01 


*/
  
  
  CREATE OR REPLACE FORCE EDITIONABLE VIEW  "V_HSP_APP_NAME" ("APP_NAME") AS 
  select  'ZSPOXXH' app_name from dual;

 
  
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_HSP_FORMS" ("FRM_ID", "FRM_NAME", "DIM_ID", "DIM_COD", "DIM_NAME", "LAYOUT_ORDER", "AXIS_ID", "LAYOUT", "ORDERS", "SEGMENT_ID", "SECTION_ID", "SECTION_STYLE_ID", "SECTION_STYLE_TYPE", "MEMBER", "MEMBER_MDX", "SHOW_STYLE_ID", "SHOW_STYLE_CODE", "QUERY_METHOD", "QUERY_TYPE", "LOCATION", "SORT_ORDER") AS 
  SELECT
      OBJ0.OBJECT_ID FRM_ID 
  , OBJ0.OBJECT_NAME AS FRM_NAME 
    , OBJ2.OBJECT_ID DIM_ID 
    , remainder(OBJ2.OBJECT_ID,100) DIM_COD 
 , OBJ2.OBJECT_NAME AS DIM_NAME
 , LAYT.LAYOUT_TYPE LAYOUT_ORDER
    , decode(LAYT.LAYOUT_TYPE
          ,0, 3
          ,1, 2
          ,2, 1
          ,3, 0)  AXIS_ID
         
       , decode(LAYT.LAYOUT_TYPE
          ,0, 'POV'
          ,1, 'Page'
          ,2, 'Row'
          ,3, 'Col')  LAYOUT
    , LAYT.ordinal orders

 --   ,  (LAYOUT_TYPE||REMAINDER(DEF_MBR.OBJDEF_ID,100)) 
    , (LAYOUT_TYPE||REMAINDER(DEF_MBR.OBJDEF_ID,100))|| OBJ2.OBJECT_ID SEGMENT_ID
    , REMAINDER(DEF_MBR.OBJDEF_ID,100) SECTION_ID 
     , FRM_DEF.STYLE SECTION_STYLE_ID  
    , decode ( FRM_DEF.STYLE
               ,8,'HIDE'
               ,0,'SHOW'
               ,'UNKNOWN') SECTION_STYLE_TYPE      
 , DECODE(DEF_MBR.SUBST_VAR,NULL,OBJ1.OBJECT_NAME,CHR(38)||DEF_MBR.SUBST_VAR)  AS Member  
    , decode(DEF_MBR.QUERY_TYPE 
         ,5,'Children ('
         ,6,'Children ('
         ,8,'Descendants ('
         ,9,'Descendants ('
         ,12,'Siblings ('
         ,13,'Siblings ('
         ,-9,'Intersect({Descendants (' ) ||
         '['||DECODE(DEF_MBR.SUBST_VAR,NULL,OBJ1.OBJECT_NAME,CHR(38)||DEF_MBR.SUBST_VAR)||']' 
        ||  decode(DEF_MBR.QUERY_TYPE 
         ,5,') '
         ,6,'), ['||DECODE(DEF_MBR.SUBST_VAR,NULL,OBJ1.OBJECT_NAME,CHR(38)||DEF_MBR.SUBST_VAR)||']' 
         ,8,') '
         ,9,'), ['||DECODE(DEF_MBR.SUBST_VAR,NULL,OBJ1.OBJECT_NAME,CHR(38)||DEF_MBR.SUBST_VAR)||']' 
         ,12,')'
         ,13,')  ['||DECODE(DEF_MBR.SUBST_VAR,NULL,OBJ1.OBJECT_NAME,CHR(38)||DEF_MBR.SUBST_VAR)||']'
         ,-9,')},{['||DECODE(DEF_MBR.SUBST_VAR,NULL,OBJ1.OBJECT_NAME,CHR(38)||DEF_MBR.SUBST_VAR)||'].levels(0).members} )'  )  
         AS Member_MDX 
    , LAYT.STYLE SHOW_STYLE_ID
    , DECODE ( LAYT.STYLE
                , 0 , 'Start Expanded'
                , 2 , 'Member Name + Start Expanded'
                , 4 , 'Alias + Start Expanded'
                , 6 , 'Alias + Member Name + Start Expanded'
                , 8 , 'Member Name'
                , 10 , 'Member Name'
                , 12 , 'Alias'
                , 14 , 'Alias + Member Name'
                , 24 , 'Hide Dimension'
                , 32 , 'Member Name + Member Formula + Start Expanded'
                , 34 , 'Member Name + Member Formula + Start Expanded'
                , 36 , 'Alias + Member Formula + Start Expanded'
                , 38 , 'Alias + Member Name + Member Formula + Start Expanded'
                , 40 , 'Member Name + Member Formula'
                , 42 , 'Member Name + Member Formula'
                , 46 , 'Alias + Member Name + Member Formula'
                , 64 , 'Member Name + Show Consolidation + Start Expanded'
                , 66 , 'Member Name + Show Consolidation + Start Expanded'
                , 68 , 'Alias + Show Consolidation + Start Expanded'
                , 70 , 'Alias + Member Name + Show Consolidation + Start Expanded'
                , 72 , 'Member Name + Show Consolidation'
                , 74 , 'Member Name + Show Consolidation'
                , 76 , 'Alias + Show Consolidation'
                , 78 , 'Alias + Member Name + Show Consolidation'
                , 96 , 'Member Name + Member Formula + Show Consolidation + Start Expanded'
                , 100 , 'Alias + Member Formula + Show Consolidation + Start Expanded'
                , 102 , 'Alias + Member Name + Member Formula + Show Consolidation + Start Expanded'
                , 106 , 'Member Name + Member Formula + Show Consolidation'
                , 108 , 'Alias + Member Formula + Show Consolidation'
                , 110 , 'Member Name + Alias + Member Formula + Show Consolidation'
                , 'Unknown' ) SHOW_STYLE_CODE
 , decode (DEF_MBR.QUERY_TYPE
            , 8  , 'Descendants'
            , 9  , 'IDescendants'
            , 3  , 'Ancestors'
            , 4  , 'IAncestors'
            , 12 , 'Siblings'
            , 13 , 'ISiblings'
            , 21 , 'Parents'
            , 22 , 'IParents'
            , 5  , 'Children'
            , 6  , 'IChildren'
            , -9 , 'ILvl0Descendants'
            , 0  , 'Member'
            , 'Unknown' ) QUERY_Method
    , DEF_MBR.QUERY_TYPE        
    , FRM_DEF.LOCATION  
    ,    OBJ0.OBJECT_ID
     -- || lag( OBJ0.OBJECT_ID) over (order by OBJ0.OBJECT_ID||decode(LAYT.LAYOUT_TYPE ,0, 3  ,1, 2  ,2, 1  ,3, 0)||DEF_MBR.OBJDEF_ID||FRM_DEF.LOCATION|| LAYT.ordinal )
      || decode(LAYT.LAYOUT_TYPE ,0, 3  ,1, 2  ,2, 1  ,3, 0)||DEF_MBR.OBJDEF_ID||FRM_DEF.LOCATION|| LAYT.ordinal  SORT_ORDER 
FROM  HSP_OBJECT OBJ0  
 LEFT JOIN HSP_FORMOBJ_DEF  FRM_DEF ON  1=1 
  AND OBJ0.OBJECT_ID = FRM_DEF.FORM_ID 

 LEFT JOIN  HSP_FORMOBJ_DEF_MBR DEF_MBR on 1=1 
     AND DEF_MBR.OBJDEF_ID = FRM_DEF.OBJDEF_ID
  
 LEFT JOIN HSP_MEMBER MBR on 1=1 
  AND MBR.MEMBER_ID = DEF_MBR.MBR_ID  

 LEFT JOIN HSP_OBJECT OBJ2 on 1=1 
  AND OBJ2.OBJECT_ID = MBR.DIM_ID   

 LEFT JOIN HSP_OBJECT OBJ1 on 1=1 
  AND OBJ1.OBJECT_ID = MBR.MEMBER_ID   
    
 LEFT JOIN HSP_FORM_LAYOUT LAYT on 1=1 
  AND OBJ0.OBJECT_ID = LAYT.form_id
  AND MBR.DIM_ID = LAYT.dim_id
 
WHERE  1=1   
  AND OBJ0.OBJECT_TYPE=7 
  order by sort_order;

 
  
  
  CREATE OR REPLACE FORCE EDITIONABLE VIEW  "V_HSP_FORMS_MDX_01" ("FRM_ID", "FRM_ID_NEXT", "FRM_ID_PRIOR", "DIM_COD", "DIM_COD_NEXT", "DIM_COD_PRIOR", "AXIS_ID", "AXIS_ID_NEXT", "AXIS_ID_PRIOR", "SECTION_ID", "SECTION_ID_NEXT", "SECTION_ID_PRIOR", "MEMBER_MDX", "SORT_ORDER") AS 
  select
     FRM_ID
   , lead( FRM_ID) over (order by  sort_order ) FRM_ID_NEXT 
   , lag( FRM_ID) over (order by  sort_order )  FRM_ID_PRIOR
   , DIM_COD
   , lead( DIM_COD) over (order by  sort_order ) DIM_COD_NEXT 
   , lag( DIM_COD) over (order by  sort_order )  DIM_COD_PRIOR
   , AXIS_ID  
   , lead( AXIS_ID) over (order by  sort_order ) AXIS_ID_NEXT 
   , lag( AXIS_ID) over (order by  sort_order )  AXIS_ID_PRIOR   
   , section_id
   , lead( section_id) over (order by  sort_order ) section_id_next 
   , lag( section_id) over (order by  sort_order )  section_id_prior    
  -- , LISTAGG(Member_MDX, ', ') WITHIN GROUP (ORDER BY  sort_order) Member_MDX    
    , RTRIM(XMLAGG(XMLELEMENT(E,Member_MDX,',').EXTRACT('//text()') ORDER BY sort_order).GetClobVal(),',') Member_MDX

   , sort_order 
   from V_HSP_FORMS
  where 1=1
   -- and FRM_NAME like '03_03_03%'
   -- and FRM_ID = '143580'
    group by sort_order ,FRM_ID ,DIM_COD, AXIS_ID  ,section_id 
  order by sort_order;

 
  
  
 CREATE OR REPLACE   VIEW "V_HSP_FORMS_MDX_Q01"  as
  WITH  FORMS_MDX_01_RAW AS ( 
  select
     FRM_ID
   , FRM_ID_NEXT 
   , FRM_ID_PRIOR  
   , DIM_COD
   , DIM_COD_NEXT 
   , DIM_COD_PRIOR
   , AXIS_ID  
   , AXIS_ID_NEXT 
   , AXIS_ID_PRIOR   
   , section_id
   , section_id_next 
   , section_id_prior   
   , CASE 
       when FRM_ID <> FRM_ID_PRIOR and AXIS_ID =0 then CHR(10)||CHR(13)|| 'SELECT   '
     END CMD10_SELECT
   , CASE 
       when  AXIS_ID  <> AXIS_ID_PRIOR then  CHR(13)|| CHR(9)|| '  NON EMPTY { '
     END CMD20_GLOBAL_AXIS 
   , CASE 
       when  section_id  <> section_id_prior then CHR(13)|| CHR(9)|| CHR(9)|| '  { '
     END CMD21_SECTION 
    , CASE 
       when  AXIS_ID  <> AXIS_ID_PRIOR and section_id  <> section_id_prior and   DIM_COD  <> DIM_COD_NEXT and AXIS_ID=AXIS_ID_NEXT and section_id=section_id_next  then  CHR(13)|| CHR(9)|| CHR(9)||CHR(9)|| ' CrossJoin ('
       when  DIM_COD  <> DIM_COD_NEXT  and AXIS_ID=AXIS_ID_NEXT and section_id=section_id_next  then  CHR(13)|| CHR(9)|| CHR(9)||CHR(9)||  ' CrossJoin ('    
     END CMD22_CJ 
    , CASE 
       when    section_id  <> section_id_prior and   DIM_COD  <> DIM_COD_NEXT and AXIS_ID=AXIS_ID_NEXT and section_id=section_id_next  then 'CMD22_CJ_FL'
     END CMD22_CJ_FL      
    , CASE        
       when  DIM_COD  <> DIM_COD_NEXT  and AXIS_ID=AXIS_ID_NEXT and section_id=section_id_next  then AXIS_ID||section_id      
     END CMD22_CJ_partition_by  
    , CASE
       when  AXIS_ID  <> AXIS_ID_PRIOR and section_id  <> section_id_prior and   DIM_COD  <> DIM_COD_NEXT and AXIS_ID=AXIS_ID_NEXT and section_id=section_id_next  then CHR(10)||CHR(13)|| CHR(9)|| CHR(9)||CHR(9)|| ' {'
       when  DIM_COD  <> DIM_COD_NEXT  and AXIS_ID=AXIS_ID_NEXT and section_id <> section_id_PRIOR  then CHR(13)|| CHR(9)|| CHR(9)||CHR(9)||  ' {'       
       when  DIM_COD  <> DIM_COD_NEXT  and AXIS_ID=AXIS_ID_NEXT /*and section_id=section_id_next */ then CHR(13)|| CHR(9)|| CHR(9)||CHR(9)||  '  , {'    
       when  DIM_COD  <> DIM_COD_NEXT  and AXIS_ID=AXIS_ID_PRIOR /*and section_id=section_id_next */ then CHR(13)|| CHR(9)|| CHR(9)||CHR(9)||  '  , {'  
     END CMD22_CJ_1   
    , CASE
       when  AXIS_ID  <> AXIS_ID_PRIOR and section_id  <> section_id_prior and   DIM_COD  <> DIM_COD_NEXT and AXIS_ID=AXIS_ID_NEXT and section_id=section_id_next  then   ' }'
       when  DIM_COD  <> DIM_COD_NEXT  and AXIS_ID=AXIS_ID_NEXT and section_id <> section_id_PRIOR  then CHR(13)|| CHR(9)|| CHR(9)||CHR(9)||  ' }' 
       when  DIM_COD  <> DIM_COD_NEXT  and AXIS_ID=AXIS_ID_NEXT /* and section_id=section_id_next*/  then ' } ) '   
       when  DIM_COD  <> DIM_COD_NEXT  and AXIS_ID=AXIS_ID_PRIOR /* and section_id=section_id_next*/  then ' } ) ' 
     END CMD22_CJ_2  

    , CASE 
       when  section_id  <> section_id_next and AXIS_ID  =  AXIS_ID_NEXT then ' } , '
       when  section_id  <> section_id_next and AXIS_ID  <> AXIS_ID_NEXT then ' }  '
     END CMD29  
   , CASE 
       when  FRM_ID=FRM_ID_NEXT and AXIS_ID  <> AXIS_ID_NEXT then '  } on Axis('||AXIS_ID||') ,'
       when  FRM_ID <> FRM_ID_NEXT and AXIS_ID  <> AXIS_ID_NEXT then '  } on Axis('||AXIS_ID||')  FROM '
     END CMD30_AXIS       
   ,  Member_MDX 
   , sort_order 
   from V_HSP_FORMS_MDX_01
  where 1=1  
  order by sort_order
  ) 
  /*  select
      *
   from FORMS_MDX_01_RAW
  where 1=1 
     and FRM_ID = '143580' 
  order by sort_order
 /* */ 
 select 
     FRM_ID
   , RTRIM(XMLAGG(XMLELEMENT(E,FRM_ID_MDX_LINE,' ').EXTRACT('//text()') ORDER BY sort_order).GetClobVal(),' ')
        MDX_Q1
         
  from ( 
 select
     FRM_ID
   , CMD10_SELECT
   || CMD20_GLOBAL_AXIS 
   || CMD21_SECTION 
  -- || CMD22_CJ, CMD22_CJ_partition_by,CMD22_CJ_FL  
   || decode(CMD22_CJ_FL,NULL,NULL
           ,   LISTAGG(CMD22_CJ,' ') within group (order by sort_order) over ( partition by CMD22_CJ_partition_by  )  )    
    || CMD22_CJ_1 
    || Member_MDX 
    || CMD22_CJ_2     
    || CMD29  
    || CMD30_AXIS 
    || ' ' ||APP_ANME.app_name||'.'|| obj.object_name 
      as  FRM_ID_MDX_LINE
    , sort_order 
   from FORMS_MDX_01_RAW MDX
     left join hsp_form FRM on 1=1
      and FRM.form_id=MDX.frm_id 
     left join hsp_object obj on 1=1 
      and obj.object_id=frm.cube_id 
     left join v_hsp_app_name APP_ANME on 1=1 
        
  where 1=1 
   --  and FRM_ID = '143580' 
  order by sort_order ) group by FRM_ID
/*  */;


  
  
