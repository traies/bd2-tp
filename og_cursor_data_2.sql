/*
    ORIGINAL COUNT: THIS SHOULD BE DONE 9 TIMES FOR EACH ELEMENT IN PREVIOUS
                    CURSOR (1701)
*/

set timing on;
EXPLAIN PLAN FOR 
SELECT COUNT(1)
		FROM REVIEW R, SALE S
		WHERE R.USER_ID = 5
		AND R.SALE_ID = S.ID
		AND R.ROLE = 'SELLER'
		AND R.CREATED > SYSDATE - 7
		AND R.STATUS = 'PUBLISHED' 
		AND R.SCORE = 'POSITIVE'
		;
        
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

/*
    Transcurrido: 00:00:00.097
    consistent gets: 5
    
        ----------------------------------------------------------------------------------------------
    | Id  | Operation                    | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
    ----------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT             |               |     1 |    41 |     6   (0)| 00:00:01 |
    |   1 |  SORT AGGREGATE              |               |     1 |    41 |            |          |
    |*  2 |   TABLE ACCESS BY INDEX ROWID| REVIEW        |     1 |    41 |     6   (0)| 00:00:01 |
    |*  3 |    INDEX RANGE SCAN          | ROLE_USER_IDX |     2 |       |     3   (0)| 00:00:01 |
    ----------------------------------------------------------------------------------------------
                                                                                                                                                                                                                             
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    Predicate Information (identified by operation id):
    ---------------------------------------------------
     
       2 - filter("R"."SCORE"='POSITIVE' AND "R"."STATUS"='PUBLISHED' AND 
                  "R"."CREATED">SYSDATE@!-7 AND "R"."SALE_ID" IS NOT NULL)
       3 - access("R"."ROLE"='SELLER' AND "R"."USER_ID"=5)

*/