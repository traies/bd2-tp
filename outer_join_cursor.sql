/*
    MODIFICACION 1: NUEVO CURSOR
    
*/
    set timing on;
--    EXPLAIN PLAN FOR 
    SELECT nvl(R.USER_ID, S.USER_ID) USER_ID 
    FROM (
        SELECT DISTINCT USER_ID FROM REVIEW
        WHERE ROLE = 'SELLER'
        AND TRUNC(MODIFIED) >= ( SYSDATE - 50 ) ) R
        FULL OUTER JOIN (
        SELECT DISTINCT USER_ID FROM SCORE
        WHERE TRUNC(MODIFIED) >= ( SYSDATE - 7 ) ) S
    ON R.USER_ID = S.USER_ID;
    
    SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

/*
    1.701 filas seleccionadas. 
    Transcurrido: 00:00:00.538
    
    consistent gets: 239
        --------------------------------------------------------------------------------------------------
    | Id  | Operation                | Name                  | Rows  | Bytes | Cost (%CPU)| Time     |
    --------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT         |                       |   194 |  1358 |    42   (5)| 00:00:01 |
    |   1 |  HASH UNIQUE             |                       |   194 |  1358 |    42   (5)| 00:00:01 |
    |   2 |   VIEW                   | VW_FOJ_0              |   194 |  1358 |    41   (3)| 00:00:01 |
    |*  3 |    HASH JOIN FULL OUTER  |                       |   194 |  5044 |    41   (3)| 00:00:01 |
    |   4 |     VIEW                 |                       |    85 |  1105 |    11   (0)| 00:00:01 |
    |*  5 |      INDEX FAST FULL SCAN| PK_SCORE              |    85 |  1275 |    11   (0)| 00:00:01 |
    
    PLAN_TABLE_OUTPUT                                                                                                                                                                                                                                                                                           
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    |   6 |     VIEW                 |                       |   194 |  2522 |    30   (4)| 00:00:01 |
    |*  7 |      INDEX FAST FULL SCAN| REVIEW_MODIFIED_INDEX |   194 |  3880 |    30   (4)| 00:00:01 |
    --------------------------------------------------------------------------------------------------
     
    Predicate Information (identified by operation id):
    ---------------------------------------------------
     
       3 - access("R"."USER_ID"="S"."USER_ID")
       5 - filter(TRUNC(INTERNAL_FUNCTION("MODIFIED"))>=SYSDATE@!-7)
       7 - filter("ROLE"='SELLER' AND TRUNC(INTERNAL_FUNCTION("MODIFIED"))>=SYSDATE@!-50)
*/

