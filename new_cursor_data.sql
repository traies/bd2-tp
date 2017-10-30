/*
    MODIFICACION 1: ADD FOREIGN KEYS
    ALTER TABLE SCORE ADD CONSTRAINT SCOREUSERFK FOREIGN KEY USER_ID REFERENCES EUSER(ID);
    ALTER TABLE REVIEW ADD CONSTRAINT REVIEW_SALE_FK FOREIGN KEY SALE_ID REFERENCES SALE(ID);
    ALTER TABLE REVIEW ADD CONSTRAINT REVIEW_USER_FK FOREIGN KEY USER_ID REFERENCES EUSER(ID);
    
    EFECTO: NO CAMBIA NADA EN LOS COSTOS
*/

/*
    MODIFICACION 2: NUEVO CURSOR
    
*/
    set timing on;
--    EXPLAIN PLAN FOR 
    SELECT DISTINCT USER_ID 
    FROM REVIEW R
    WHERE R.ROLE = 'SELLER'
    AND TRUNC(MODIFIED) >= ( SYSDATE - 50 ) 
    UNION
    SELECT USER_ID
    FROM SCORE
    WHERE TRUNC(MODIFIED) >= ( SYSDATE - 7 )
    ;
    
    SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

/*
    1.701 filas seleccionadas. 
    Transcurrido: 00:00:00.366
    
    consistent gets: 421
        -----------------------------------------------------------------------------------
    | Id  | Operation              | Name     | Rows  | Bytes | Cost (%CPU)| Time     |
    -----------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT       |          |   271 |  4995 |    74  (19)| 00:00:01 |
    |   1 |  SORT UNIQUE           |          |   271 |  4995 |    74  (19)| 00:00:01 |
    |   2 |   UNION-ALL            |          |       |       |            |          |
    |*  3 |    TABLE ACCESS FULL   | REVIEW   |   194 |  3880 |    61   (2)| 00:00:01 |
    |*  4 |    INDEX FAST FULL SCAN| PK_SCORE |    85 |  1275 |    11   (0)| 00:00:01 |
    -----------------------------------------------------------------------------------
    
    PLAN_TABLE_OUTPUT                                                                                                                                                                                                                                                                                           
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     
    Predicate Information (identified by operation id):
    ---------------------------------------------------
     
       3 - filter("R"."ROLE"='SELLER' AND 
                  TRUNC(INTERNAL_FUNCTION("MODIFIED"))>=SYSDATE@!-50)
       4 - filter(TRUNC(INTERNAL_FUNCTION("MODIFIED"))>=SYSDATE@!-7)
*/

/*
    MODIFICACION 3: NUEVO INDICE
    CREATE INDEX REVIEW_MODIFIED_INDEX on REVIEW(MODIFIED,USER_ID, ROLE) tablespace team6_indexes;
*/

/*
    1.701 filas seleccionadas. 
    Transcurrido: 00:00:00.364
    
    consistent gets: 239
        ------------------------------------------------------------------------------------------------
    | Id  | Operation              | Name                  | Rows  | Bytes | Cost (%CPU)| Time     |
    ------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT       |                       |   271 |  4995 |    43  (33)| 00:00:01 |
    |   1 |  SORT UNIQUE           |                       |   271 |  4995 |    43  (33)| 00:00:01 |
    |   2 |   UNION-ALL            |                       |       |       |            |          |
    |*  3 |    INDEX FAST FULL SCAN| REVIEW_MODIFIED_INDEX |   194 |  3880 |    30   (4)| 00:00:01 |
    |*  4 |    INDEX FAST FULL SCAN| PK_SCORE              |    85 |  1275 |    11   (0)| 00:00:01 |
    ------------------------------------------------------------------------------------------------
    
    PLAN_TABLE_OUTPUT                                                                                                                                                                                                                                                                                           
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     
    Predicate Information (identified by operation id):
    ---------------------------------------------------
     
       3 - filter("R"."ROLE"='SELLER' AND TRUNC(INTERNAL_FUNCTION("MODIFIED"))>=SYSDATE@!-50
                  )
       4 - filter(TRUNC(INTERNAL_FUNCTION("MODIFIED"))>=SYSDATE@!-7)

*/


