set timing on;
set serveroutput on;
DECLARE

    CURSOR USER_IDS_CURSOR( pInterval NUMBER ) IS SELECT * FROM ((SELECT DISTINCT  USER_ID 
    FROM REVIEW R
    WHERE R.ROLE = 'SELLER'
    AND TRUNC(MODIFIED) >= ( SYSDATE - pInterval ) 
    )
    UNION
    (SELECT USER_ID
    FROM SCORE
    WHERE TRUNC(MODIFIED) >= ( SYSDATE - 7 ))) P ORDER BY P.USER_ID;
    
    CURSOR REP_CURSOR IS SELECT R.USER_ID, R.CREATED, R.SCORE
    FROM REVIEW R WHERE
    R.ROLE = 'SELLER'
    AND R.STATUS = 'PUBLISHED';
    
    
    TYPE idx_table IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
    
    v7positive idx_table;
    v7negative idx_table;
    v7neutral idx_table;
    v30positive idx_table;
    v30negative idx_table;
    v30neutral idx_table;
    v180positive idx_table;
    v180negative idx_table;
    v180neutral idx_table;
    
    idx USER_IDS_CURSOR%ROWTYPE;
    
    repx REP_CURSOR%ROWTYPE;
    
    repx_prev REP_CURSOR%ROWTYPE;
    
    do boolean;
    
    tmp PLS_INTEGER;
    
    k PLS_INTEGER;
    
BEGIN
    k := 0;
    OPEN USER_IDS_CURSOR(50);
    
    OPEN REP_CURSOR;
    
    
    LOOP
    
        do := false;
        
        FETCH USER_IDS_CURSOR INTO idx;
        k := k+1;
        EXIT WHEN USER_IDS_CURSOR%NOTFOUND;
        
        v7positive(idx.USER_ID) := 0;
        v7negative(idx.USER_ID) := 0;
        v7neutral(idx.USER_ID) := 0;
        v30positive(idx.USER_ID) := 0;
        v30negative(idx.USER_ID) := 0;
        v30neutral(idx.USER_ID) := 0;
        v180positive(idx.USER_ID) := 0;
        v180negative(idx.USER_ID) := 0;
        v180neutral(idx.USER_ID) := 0;
        
        LOOP
            
            if do THEN
                do := false;
                goto label;
            else
                FETCH REP_CURSOR INTO repx;
                do := true;
                EXIT WHEN REP_CURSOR%NOTFOUND OR repx.USER_ID != idx.USER_ID;
                do := false;
            end if;
            
            <<label>>
            
            if repx.SCORE = 'POSITIVE' then
                if repx.CREATED > SYSDATE - 7 then
                    tmp := v7positive(repx.USER_ID);
                    tmp := tmp+1;
                    v7positive(repx.USER_ID) := tmp;
                end if;
                if repx.CREATED > SYSDATE - 30 then
                    tmp := v30positive(repx.USER_ID);
                    tmp := tmp+1;
                    v30positive(repx.USER_ID) := tmp;
                end if;
                if repx.CREATED > SYSDATE - 180 then
                    tmp := v180positive(repx.USER_ID);
                    tmp := tmp+1;
                    v180positive(repx.USER_ID) := tmp;
                end if;
            elsif repx.SCORE = 'NEGATIVE' then
                if repx.CREATED > SYSDATE - 7 then
                    tmp := v7negative(repx.USER_ID);
                    tmp := tmp+1;
                    v7negative(repx.USER_ID) := tmp;
                end if;
                if repx.CREATED > SYSDATE - 30 then
                    tmp := v30negative(repx.USER_ID);
                    tmp := tmp+1;
                    v30negative(repx.USER_ID) := tmp;
                end if;
                if repx.CREATED > SYSDATE - 180 then
                    tmp := v180negative(repx.USER_ID);
                    tmp := tmp+1;
                    v180negative(repx.USER_ID) := tmp;
                end if;
            else
                if repx.CREATED > SYSDATE - 7 then
                    tmp := v7neutral(repx.USER_ID);
                    tmp := tmp+1;
                    v7neutral(repx.USER_ID) := tmp;
                end if;
                if repx.CREATED > SYSDATE - 30 then
                    tmp := v30neutral(repx.USER_ID);
                    tmp := tmp+1;
                    v30neutral(repx.USER_ID) := tmp;
                end if;
                if repx.CREATED > SYSDATE - 180 then
                    tmp := v180neutral(repx.USER_ID);
                    tmp := tmp+1;
                    v180neutral(repx.USER_ID) := tmp;
                end if;
            end if;
        END LOOP;
   END LOOP;
   dbms_output.put_line(k);
    
END;



