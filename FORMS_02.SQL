/*
https://community.oracle.com/thread/2414336?tstart=15
Nice example to get Attributes and permitions for forms 

*/

SELECT 
  o.OBJECT_NAME AS Form_Name
  , (
      SELECT 
        wm_concat(flo.OBJECT_NAME)
      FROM 
        HSP_FORM_LAYOUT fl
      INNER JOIN 
        HSP_OBJECT flo on fl.DIM_ID = flo.OBJECT_ID
      WHERE 
        fl.FORM_ID = f.FORM_ID AND fl.LAYOUT_TYPE = 0
    )
    AS POV_Dimensions
  , (
      SELECT 
        wm_concat(flo.OBJECT_NAME)
      FROM 
        HSP_FORM_LAYOUT fl
      INNER JOIN 
        HSP_OBJECT flo on fl.DIM_ID = flo.OBJECT_ID
      WHERE fl.FORM_ID = f.FORM_ID AND fl.LAYOUT_TYPE = 1
    )
    AS Page_Dimensions
  , (
      SELECT 
        wm_concat(flo.OBJECT_NAME)
      FROM
        HSP_FORM_LAYOUT fl
      INNER JOIN 
        HSP_OBJECT flo on fl.DIM_ID = flo.OBJECT_ID
      WHERE 
        fl.FORM_ID = f.FORM_ID AND fl.LAYOUT_TYPE = 2
    )
    AS Row_Dimensions
  , (
      SELECT 
        wm_concat(flo.OBJECT_NAME)
      FROM
        HSP_FORM_LAYOUT fl   
      INNER JOIN 
        HSP_OBJECT flo on fl.DIM_ID = flo.OBJECT_ID
      WHERE
        fl.FORM_ID = f.FORM_ID AND fl.LAYOUT_TYPE = 3
    )
    AS Column_Dimensions
  , (
      SELECT 
        wm_concat(fla.OBJECT_NAME)
      FROM 
        HSP_FORM_ATTRIBUTES fa
      INNER JOIN 
          HSP_OBJECT fla on fa.DIM_ID = fla.OBJECT_ID
      WHERE 
          fa.FORM_ID = f.FORM_ID    
    )
    AS Attribute_Dimensions
  , (
      SELECT 
        wm_concat(fc.CALC_NAME || CASE fc.RUN_ON_LOAD WHEN 1 THEN ' (Run on load)' ELSE '' END || CASE fc.RUN_ON_SAVE WHEN 1 THEN ' (Run on save)' ELSE '' END)
      AS CALCs
      FROM 
        HSP_FORM_CALCS fc
      WHERE 
        fc.FORM_ID = f.FORM_ID
    )
    AS Calcs
  , (
      SELECT 
        wm_concat(aco.OBJECT_NAME)
      FROM 
        HSP_ACCESS_CONTROL ac
      INNER JOIN 
        HSP_OBJECT aco ON aco.OBJECT_ID = ac.USER_ID
      WHERE 
        ac.OBJECT_ID = f.FORM_ID AND ac.ACCESS_MODE = 3
    )
    AS Users_Write
  , (
      SELECT 
        wm_concat(aco.OBJECT_NAME)
      FROM 
        HSP_ACCESS_CONTROL ac
      INNER JOIN 
        HSP_OBJECT aco ON aco.OBJECT_ID = ac.USER_ID
      WHERE 
        ac.OBJECT_ID = f.FORM_ID AND ac.ACCESS_MODE = 1
      )
    AS Users_Read
  , (
      SELECT 
        wm_concat(aco.OBJECT_NAME)
      FROM 
        HSP_ACCESS_CONTROL ac
      INNER JOIN 
        HSP_OBJECT aco ON aco.OBJECT_ID = ac.USER_ID
      WHERE 
        ac.OBJECT_ID = f.FORM_ID AND ac.ACCESS_MODE = -1
    )
    AS Users_Denied
  , o.MODIFIED AS Last_Modified
  , o.MODIFIED_BY AS Modified_By    
FROM
  HSP_FORM f
INNER JOIN
  HSP_OBJECT o ON f.FORM_ID = o.OBJECT_ID
