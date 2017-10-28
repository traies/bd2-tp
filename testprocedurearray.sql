set timing on;
set serveroutput on;
DECLARE

    CURSOR USER_IDS_CURSOR( pInterval NUMBER ) IS 
        SELECT DISTINCT(USER_ID) FROM 
            (
                (SELECT DISTINCT  USER_ID 
                FROM REVIEW R
                WHERE R.ROLE = 'SELLER'
                AND TRUNC(MODIFIED) >= ( SYSDATE - pInterval ))
            UNION
                (SELECT USER_ID
                FROM SCORE
                WHERE TRUNC(MODIFIED) >= ( SYSDATE - 7 ))
            ) 
        P ORDER BY P.USER_ID;
    
    CURSOR REP_CURSOR IS 
        SELECT R.USER_ID, R.CREATED, R.SCORE
        FROM REVIEW R WHERE
        R.ROLE = 'SELLER'
        AND R.STATUS = 'PUBLISHED'
        ORDER BY R.USER_ID;
    
    
    TYPE idx_table IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    
    v7positive idx_table;
    v7negative idx_table;
    v7neutral idx_table;
    v30positive idx_table;
    v30negative idx_table;
    v30neutral idx_table;
    v180positive idx_table;
    v180negative idx_table;
    v180neutral idx_table;
    vScoreTotal idx_table;
    vCountTotal idx_table;
    
    idx USER_IDS_CURSOR%ROWTYPE;
    
    repx REP_CURSOR%ROWTYPE;
    
    tmp PLS_INTEGER;
    
    
BEGIN
    OPEN USER_IDS_CURSOR(50);
    OPEN REP_CURSOR;
        
    FETCH USER_IDS_CURSOR INTO idx;
    if USER_IDS_CURSOR%NOTFOUND then 
        return;
    end if;
    
    v7positive(idx.USER_ID) := 0;
    v7negative(idx.USER_ID) := 0;
    v7neutral(idx.USER_ID) := 0;
    v30positive(idx.USER_ID) := 0;
    v30negative(idx.USER_ID) := 0;
    v30neutral(idx.USER_ID) := 0;
    v180positive(idx.USER_ID) := 0;
    v180negative(idx.USER_ID) := 0;
    v180neutral(idx.USER_ID) := 0;
    vScoreTotal(idx.USER_ID) := 0;
    vCountTotal(idx.USER_ID) := 0;
        
    LOOP
        

        FETCH REP_CURSOR INTO repx;
        EXIT WHEN REP_CURSOR%NOTFOUND;
        
        if repx.USER_ID != idx.USER_ID then 
            while not USER_IDS_CURSOR%NOTFOUND and repx.USER_ID != idx.USER_ID and idx.USER_ID < repx.USER_ID loop
                FETCH USER_IDS_CURSOR INTO idx;
            end loop;
            EXIT WHEN USER_IDS_CURSOR%NOTFOUND;
            IF idx.USER_ID < repx.USER_ID then
                continue;
            end if;
            
            v7positive(idx.USER_ID) := 0;
            v7negative(idx.USER_ID) := 0;
            v7neutral(idx.USER_ID) := 0;
            v30positive(idx.USER_ID) := 0;
            v30negative(idx.USER_ID) := 0;
            v30neutral(idx.USER_ID) := 0;
            v180positive(idx.USER_ID) := 0;
            v180negative(idx.USER_ID) := 0;
            v180neutral(idx.USER_ID) := 0;
            vScoreTotal(idx.USER_ID) := 0;
            vCountTotal(idx.USER_ID) := 0;
        
        end if;
        
        vCountTotal(idx.USER_ID) := vCountTotal(idx.USER_ID) + 1;
        
        if repx.SCORE = 'POSITIVE' then
        
            vScoreTotal(idx.USER_ID) := vScoreTotal(idx.USER_ID) + 1;
            
            if TRUNC(repx.CREATED) > SYSDATE - 7 then
                v7positive(repx.USER_ID) := v7positive(repx.USER_ID) + 1;
            end if;
            if TRUNC(repx.CREATED) > SYSDATE - 30 then
                v30positive(repx.USER_ID) := v30positive(repx.USER_ID) + 1;
            end if;
            if TRUNC(repx.CREATED) > SYSDATE - 180 then
                v180positive(repx.USER_ID) := v180positive(repx.USER_ID) + 1;
            end if;
            
        elsif repx.SCORE = 'NEGATIVE' then
        
            vScoreTotal(idx.USER_ID) := vScoreTotal(idx.USER_ID) - 1;
        
            if TRUNC(repx.CREATED) > SYSDATE - 7 then
                v7negative(repx.USER_ID) := v7negative(repx.USER_ID) + 1;
            end if;
            if TRUNC(repx.CREATED) > SYSDATE - 30 then
               v30negative(repx.USER_ID) := v30negative(repx.USER_ID) + 1;
            end if;
            if TRUNC(repx.CREATED) > SYSDATE - 180 then
               v180negative(repx.USER_ID) := v180negative(repx.USER_ID) + 1;
            end if;
            
        else
        
            if TRUNC(repx.CREATED) > SYSDATE - 7 then
                v7neutral(repx.USER_ID) := v7neutral(repx.USER_ID) + 1;
            end if;
            if TRUNC(repx.CREATED) > SYSDATE - 30 then
                v30neutral(repx.USER_ID) := v30neutral(repx.USER_ID) + 1;
            end if;
            if TRUNC(repx.CREATED) > SYSDATE - 180 then
                v180neutral(repx.USER_ID) := v180neutral(repx.USER_ID) + 1;
            end if;
            
        end if;
    END LOOP;
    
    CLOSE USER_IDS_CURSOR;
    CLOSE REP_CURSOR;
    
    OPEN USER_IDS_CURSOR(50);
    
    LOOP
        FETCH USER_IDS_CURSOR INTO idx;
        EXIT WHEN USER_IDS_CURSOR%NOTFOUND;
        if (vCountTotal.exists(idx.USER_ID)) then
            SCORING_PKG.update_seller_scoring(idx.USER_ID, 
              v7Positive(idx.USER_ID), v7Negative(idx.USER_ID), v7Neutral(idx.USER_ID),
              v30Positive(idx.USER_ID), v30Negative(idx.USER_ID), v30Neutral(idx.USER_ID),
              v180Positive(idx.USER_ID), v180Negative(idx.USER_ID), v180Neutral(idx.USER_ID),
              vScoreTotal(idx.USER_ID), vCountTotal(idx.USER_ID));
        else
            SCORING_PKG.update_seller_scoring(idx.USER_ID, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        end if;
    
    END LOOP;
    
END;



