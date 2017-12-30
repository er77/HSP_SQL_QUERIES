/*
Get forms with members 

*/

  SELECT
      OBJ0.OBJECT_ID FRM_ID 
	, OBJ0.OBJECT_NAME AS FRM_NAME 
    , OBJ2.OBJECT_ID DIM_ID 
	, OBJ2.OBJECT_NAME AS DIM_NAME
	, LAYT.LAYOUT_TYPE LAYOUT_ORDER
    , decode(LAYT.LAYOUT_TYPE
          ,0, 'POV'
          ,1, 'Page'
          ,2, 'Row'
          ,3, 'Col')  LAYOUT
    , LAYT.ordinal orders

    ,  (LAYOUT_TYPE||REMAINDER(DEF_MBR.OBJDEF_ID,100)) SEGMENT_ID
    , FRM_DEF.STYLE SECTION_STYLE_ID  
    , decode ( FRM_DEF.STYLE
               ,8,'HIDE'
               ,0,'SHOW'
               ,'UNKNOWN') SECTION_STYLE_TYPE      
	, DECODE(DEF_MBR.SUBST_VAR,NULL,OBJ1.OBJECT_NAME,'&'||DEF_MBR.SUBST_VAR)  AS Member  
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
    , decode(LAYOUT_TYPE ,2, '99',LAYOUT_TYPE)||DEF_MBR.OBJDEF_ID||FRM_DEF.LOCATION|| LAYT.ordinal  SORT_ORDER 
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
  order by sort_order 
