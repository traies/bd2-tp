/*
    ORIGINAL CURSOR:
*/
set timing on;
--EXPLAIN PLAN FOR 
SELECT DISTINCT SELLER_ID AS USER_ID 
   FROM SALE S
   WHERE EXISTS (
        SELECT 1
        FROM REVIEW R
        WHERE S.ID = R.SALE_ID
        AND TRUNC(MODIFIED) >= ( SYSDATE - 50 ) 
   )
   UNION
   SELECT USER_ID
   FROM SCORE
   WHERE TRUNC(MODIFIED) >= ( SYSDATE - 7 )
   ;
   
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());
/*
    1.701 filas seleccionadas. 
    Transcurrido: 00:00:00.315
    
    consistent gets: 421
        -----------------------------------------------------------------------------------
    | Id  | Operation              | Name     | Rows  | Bytes | Cost (%CPU)| Time     |
    -----------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT       |          |   463 |  7323 |    98  (16)| 00:00:02 |
    |   1 |  SORT UNIQUE           |          |   463 |  7323 |    98  (16)| 00:00:02 |
    |   2 |   UNION-ALL            |          |       |       |            |          |
    |*  3 |    HASH JOIN RIGHT SEMI|          |   378 |  6048 |    85   (3)| 00:00:01 |
    |*  4 |     TABLE ACCESS FULL  | REVIEW   |   387 |  3870 |    61   (2)| 00:00:01 |
    |   5 |     TABLE ACCESS FULL  | SALE     |  3871 | 23226 |    23   (0)| 00:00:01 |
    
    PLAN_TABLE_OUTPUT                                                                                                                                                                                                                                                                                           
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    |*  6 |    INDEX FAST FULL SCAN| PK_SCORE |    85 |  1275 |    11   (0)| 00:00:01 |
    -----------------------------------------------------------------------------------
     
    Predicate Information (identified by operation id):
    ---------------------------------------------------
     
       3 - access("S"."ID"="R"."SALE_ID")
       4 - filter(TRUNC(INTERNAL_FUNCTION("MODIFIED"))>=SYSDATE@!-50)
       6 - filter(TRUNC(INTERNAL_FUNCTION("MODIFIED"))>=SYSDATE@!-7)
*/