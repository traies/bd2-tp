set timing on;

DECLARE

CURSOR CURSOR_50( pInterval NUMBER ) IS SELECT USER_ID FROM ((SELECT DISTINCT  USER_ID 
FROM REVIEW R
WHERE R.ROLE = 'SELLER'
AND TRUNC(MODIFIED) >= ( SYSDATE - pInterval ) 
)
UNION
(SELECT USER_ID
FROM SCORE
WHERE TRUNC(MODIFIED) >= ( SYSDATE - 7 )))  P ORDER BY P.USER_ID;

asdf INTEGER;
BEGIN
     
     
      FOR SELLER_REC IN CURSOR_50(50) LOOP
		-- Buscar el puntaje recibido en las ventas de la ultima semana
		SELECT COUNT(1) into asdf
		FROM REVIEW R, SALE S
		WHERE R.USER_ID = SELLER_REC.USER_ID
		AND R.SALE_ID = S.ID
		AND R.ROLE = 'SELLER'
		AND R.CREATED > SYSDATE - 7
		AND R.STATUS = 'PUBLISHED' 
		AND R.SCORE = 'POSITIVE'
		;
		SELECT COUNT(1) into asdf
		FROM REVIEW R, SALE S
		WHERE R.USER_ID = SELLER_REC.USER_ID
		AND R.SALE_ID = S.ID
		AND R.ROLE = 'SELLER'
		AND R.CREATED > SYSDATE - 7
		AND R.STATUS = 'PUBLISHED' 
		AND R.SCORE = 'NEGATIVE'
		;
		SELECT COUNT(1) into asdf
		FROM REVIEW R, SALE S
		WHERE R.USER_ID = SELLER_REC.USER_ID
		AND R.SALE_ID = S.ID
		AND R.ROLE = 'SELLER'
		AND R.CREATED > SYSDATE - 7
		AND R.STATUS = 'PUBLISHED' 
		AND R.SCORE = 'NEUTRAL'
		;
		-- Buscar el puntaje recibido en las ventas del ultimo mes
		SELECT COUNT(1) into asdf
		FROM REVIEW R, SALE S
		WHERE R.USER_ID = SELLER_REC.USER_ID
		AND R.SALE_ID = S.ID
		AND R.ROLE = 'SELLER'
		AND R.CREATED > SYSDATE - 30
		AND R.STATUS = 'PUBLISHED' 
		AND R.SCORE = 'POSITIVE'
		;
		SELECT COUNT(1) into asdf
		FROM REVIEW R, SALE S
		WHERE R.USER_ID = SELLER_REC.USER_ID
		AND R.SALE_ID = S.ID
		AND R.CREATED > SYSDATE - 30
		AND R.ROLE = 'SELLER'
		AND R.STATUS = 'PUBLISHED' 
		AND R.SCORE = 'NEGATIVE'
		;
		SELECT COUNT(1) into asdf
		FROM REVIEW R, SALE S
		WHERE R.USER_ID = SELLER_REC.USER_ID
		AND R.SALE_ID = S.ID
		AND R.CREATED > SYSDATE - 30
		AND R.ROLE = 'SELLER'
		AND R.STATUS = 'PUBLISHED' 
		AND R.SCORE = 'NEUTRAL'
		;
		-- Buscar el puntaje recibido en las ventas de los ultimos seis meses	
		SELECT COUNT(1) into asdf
		FROM REVIEW R, SALE S
		WHERE R.USER_ID = SELLER_REC.USER_ID
		AND R.SALE_ID = S.ID
		AND R.CREATED > SYSDATE - 180
		AND R.ROLE = 'SELLER'
		AND R.STATUS = 'PUBLISHED' 
		AND R.SCORE = 'POSITIVE'
		;
		SELECT COUNT(1) into asdf
		FROM REVIEW R, SALE S
		WHERE R.USER_ID = SELLER_REC.USER_ID
		AND R.SALE_ID = S.ID
		AND R.CREATED > SYSDATE - 180
		AND R.ROLE = 'SELLER'
		AND R.STATUS = 'PUBLISHED' 
		AND R.SCORE = 'NEGATIVE'
		;
		SELECT COUNT(1) into asdf
		FROM REVIEW R, SALE S
		WHERE R.USER_ID = SELLER_REC.USER_ID
		AND R.SALE_ID = S.ID
		AND R.CREATED > SYSDATE - 180
		AND R.ROLE = 'SELLER'
		AND R.STATUS = 'PUBLISHED' 
		AND R.SCORE = 'NEUTRAL'
		;
        /*
		-- Buscar el puntaje recibido en las ventas totales	
		SELECT  nvl(sum(CASE SCORE WHEN 'POSITIVE' THEN 1 WHEN 'NEGATIVE' THEN -1 ELSE 0 END),0), COUNT(1)
		FROM REVIEW R, SALE S
		WHERE R.USER_ID = SELLER_REC.USER_ID
		AND R.SALE_ID = S.ID
		AND R.ROLE = 'SELLER'
		AND R.STATUS = 'PUBLISHED' ;
        */
	  END LOOP;
      
      END;
