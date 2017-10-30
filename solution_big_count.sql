/*
    SOLUTION 1: BIG COUNT
*/

set timing on;
EXPLAIN PLAN FOR 
 SELECT A.USER_ID USER_ID, 
    COUNT(case when R.SCORE = 'POSITIVE' and TRUNC(R.CREATED) > SYSDATE - 7 then 1 else null end) v7Positive,
    COUNT(case when R.SCORE = 'NEGATIVE' and TRUNC(R.CREATED) > SYSDATE - 7 then 1 else null end) v7Negative,
    COUNT(case when R.SCORE = 'NEUTRAL' and TRUNC(R.CREATED) > SYSDATE - 7 then 1 else null end) v7Neutral,
    COUNT(case when R.SCORE = 'POSITIVE' and TRUNC(R.CREATED) > SYSDATE - 30 then 1 else null end) v30Positive,
    COUNT(case when R.SCORE = 'NEGATIVE' and TRUNC(R.CREATED) > SYSDATE - 30 then 1 else null end) v30Negative,
    COUNT(case when R.SCORE = 'NEUTRAL' and TRUNC(R.CREATED) > SYSDATE - 30 then 1 else null end) v30Neutral,
    COUNT(case when R.SCORE = 'POSITIVE' and TRUNC(R.CREATED) > SYSDATE - 180 then 1 else null end) v180Positive,
    COUNT(case when R.SCORE = 'NEGATIVE' and TRUNC(R.CREATED) > SYSDATE - 180 then 1 else null end) v180Negative,
    COUNT(case when R.SCORE = 'NEUTRAL' and TRUNC(R.CREATED) > SYSDATE - 180 then 1 else null end) v180Neutral,
    SUM(case R.SCORE when 'POSITIVE' then 1 when 'NEGATIVE' then -1 else 0 end) vScoreTotal,
    COUNT(*) vCountTotal
    FROM 
 (
    SELECT DISTINCT USER_ID 
    FROM REVIEW R
    WHERE R.ROLE = 'SELLER'
    AND TRUNC(MODIFIED) >= ( SYSDATE - 50 ) 
    UNION
    SELECT USER_ID
    FROM SCORE
    WHERE TRUNC(MODIFIED) >= ( SYSDATE - 7 )
) A LEFT JOIN (
    SELECT USER_ID, CREATED, SCORE
    FROM REVIEW
    WHERE ROLE = 'SELLER'
    AND STATUS = 'PUBLISHED'
) R
ON A.USER_ID = R.USER_ID
GROUP BY A.USER_ID;

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

/*
    1.701 filas seleccionadas. 
    Transcurrido: 00:00:00.981
    
    consistent gets: 591

        ---------------------------------------------------------------------------------------------------
    | Id  | Operation                 | Name                  | Rows  | Bytes | Cost (%CPU)| Time     |
    ---------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT          |                       |   271 | 13821 |   105   (5)| 00:00:02 |
    |   1 |  HASH GROUP BY            |                       |   271 | 13821 |   105   (5)| 00:00:02 |
    |*  2 |   HASH JOIN OUTER         |                       |   271 | 13821 |   104   (4)| 00:00:02 |
    |   3 |    VIEW                   |                       |   271 |  3523 |    43   (7)| 00:00:01 |
    |   4 |     SORT UNIQUE           |                       |   271 |  4995 |    43  (33)| 00:00:01 |
    |   5 |      UNION-ALL            |                       |       |       |            |          |
    
    PLAN_TABLE_OUTPUT                                                                                                                                                                                                                                                                                           
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    |*  6 |       INDEX FAST FULL SCAN| REVIEW_MODIFIED_INDEX |   194 |  3880 |    30   (4)| 00:00:01 |
    |*  7 |       INDEX FAST FULL SCAN| PK_SCORE              |    85 |  1275 |    11   (0)| 00:00:01 |
    |*  8 |    TABLE ACCESS FULL      | REVIEW                |  1936 | 73568 |    60   (0)| 00:00:01 |
    ---------------------------------------------------------------------------------------------------
     
    Predicate Information (identified by operation id):
    ---------------------------------------------------
     
       2 - access("A"."USER_ID"="USER_ID"(+))
       6 - filter("R"."ROLE"='SELLER' AND TRUNC(INTERNAL_FUNCTION("MODIFIED"))>=SYSDATE@!-50)
       7 - filter(TRUNC(INTERNAL_FUNCTION("MODIFIED"))>=SYSDATE@!-7)
    
    PLAN_TABLE_OUTPUT                                                                                                                                                                                                                                                                                           
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
       8 - filter("ROLE"(+)='SELLER' AND "STATUS"(+)='PUBLISHED')
*/


/*
    MODIFICACION 2: CREAR INDICE
    CREATE INDEX REVIEW_CREATED_INDEX ON REVIEW(USER_ID, CREATED, ROLE, STATUS, SCORE) TABLESPACE team6_indexes;
*/

/*
    1.701 filas seleccionadas. 
    Transcurrido: 00:00:00.954
    
    consistent gets: 499
        ---------------------------------------------------------------------------------------------------
    | Id  | Operation                 | Name                  | Rows  | Bytes | Cost (%CPU)| Time     |
    ---------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT          |                       |   271 | 13821 |    89   (6)| 00:00:01 |
    |   1 |  HASH GROUP BY            |                       |   271 | 13821 |    89   (6)| 00:00:01 |
    |*  2 |   HASH JOIN OUTER         |                       |   271 | 13821 |    88   (5)| 00:00:01 |
    |   3 |    VIEW                   |                       |   271 |  3523 |    43   (7)| 00:00:01 |
    |   4 |     SORT UNIQUE           |                       |   271 |  4995 |    43  (33)| 00:00:01 |
    |   5 |      UNION-ALL            |                       |       |       |            |          |
    
    PLAN_TABLE_OUTPUT                                                                                                                                                                                                                                                                                           
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    |*  6 |       INDEX FAST FULL SCAN| REVIEW_MODIFIED_INDEX |   194 |  3880 |    30   (4)| 00:00:01 |
    |*  7 |       INDEX FAST FULL SCAN| PK_SCORE              |    85 |  1275 |    11   (0)| 00:00:01 |
    |*  8 |    INDEX FAST FULL SCAN   | REVIEW_CREATED_INDEX  |  1936 | 73568 |    44   (0)| 00:00:01 |
    ---------------------------------------------------------------------------------------------------
     
    Predicate Information (identified by operation id):
    ---------------------------------------------------
     
       2 - access("A"."USER_ID"="USER_ID"(+))
       6 - filter("R"."ROLE"='SELLER' AND TRUNC(INTERNAL_FUNCTION("MODIFIED"))>=SYSDATE@!-50)
       7 - filter(TRUNC(INTERNAL_FUNCTION("MODIFIED"))>=SYSDATE@!-7)
    
    PLAN_TABLE_OUTPUT                                                                                                                                                                                                                                                                                           
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
       8 - filter("ROLE"(+)='SELLER' AND "STATUS"(+)='PUBLISHED')

*/