create or replace PACKAGE BODY scoring_pkg AS  -- body

   -- Cursor de vendedores cuyas calificaciones sufrieron modificaciones
   -- o cuya reputacion hay que actualizar porque es "vieja" (de mas de 1 semana)
   CURSOR SELLER_CUR( pInterval NUMBER ) IS 
    SELECT R.USER_ID USER_ID, 
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
    AND TRUNC(MODIFIED) >= ( SYSDATE - pInterval ) 
    UNION
    SELECT USER_ID
    FROM SCORE
    WHERE TRUNC(MODIFIED) >= ( SYSDATE - 7 )
) A, (
    SELECT USER_ID, CREATED, SCORE
    FROM REVIEW
    WHERE ROLE = 'SELLER'
    AND STATUS = 'PUBLISHED'
) R
WHERE A.USER_ID = R.USER_ID
GROUP BY R.USER_ID;
   
   -- Procedimiento que actualiza la reputacion de un vendedor 
   PROCEDURE update_seller_scoring( pUserId NUMBER, 
	  p7Positive NUMBER, p7Negative NUMBER, p7Neutral NUMBER,
	  p30Positive NUMBER, p30Negative NUMBER, p30Neutral NUMBER,
	  p180Positive NUMBER, p180Negative NUMBER, p180Neutral NUMBER,
	  pScoreTotal NUMBER, pCountTotal NUMBER
	  ) AS
	  vRATIO NUMBER(10,9):=0;
   BEGIN

		IF pCountTotal <=0 THEN 
			vRATIO:=0;
		ELSE 
			vRATIO:=round(pScoreTotal/pCountTotal,2) ;
		END IF;

	   --Intento la actualización
       UPDATE SCORE 
	   SET  
	   	LAST_WEEK_POSITIVE = p7Positive,
		LAST_WEEK_NEUTRAL = p7Neutral,
		LAST_WEEK_NEGATIVE  = p7Negative,
		LAST_MONTH_POSITIVE = p30Positive,
		LAST_MONTH_NEUTRAL = p30Neutral,
		LAST_MONTH_NEGATIVE = p30Negative,
		LAST_6MONTH_POSITIVE = p180Positive,
		LAST_6MONTH_NEUTRAL = p180Neutral,
		LAST_6MONTH_NEGATIVE = p180Negative,
		SCORE = vRATIO,
		MODIFIED = sysdate
	   WHERE USER_ID = pUserId;
	   -- Si no existe, inserto el registro
	   IF SQL%NOTFOUND then
         INSERT INTO SCORE ( USER_ID, 
				LAST_WEEK_POSITIVE, LAST_WEEK_NEUTRAL, LAST_WEEK_NEGATIVE,
				LAST_MONTH_POSITIVE, LAST_MONTH_NEUTRAL, LAST_MONTH_NEGATIVE,
				LAST_6MONTH_POSITIVE, LAST_6MONTH_NEUTRAL, LAST_6MONTH_NEGATIVE,
				SCORE, STATUS, CREATED, MODIFIED ) 
         VALUES ( pUserId,
				p7Positive, p7Neutral, p7Negative,
				p30Positive, p30Neutral, p30Negative,
				p180Positive, p180Neutral, p180Negative,
				vRATIO, 'ACTIVE', SYSDATE, SYSDATE
				);
       END IF;
	   COMMIT;
   END update_seller_scoring;

   -- Procedimiento que calcula el puntaje de los vendedores
   PROCEDURE calculate_seller_scoring( ndays NUMBER )  AS
      v7Positive NUMBER(10);
	  v7Negative NUMBER(10);
	  v7Neutral NUMBER(10);
	  v30Positive NUMBER(10);
	  v30Negative NUMBER(10);
	  v30Neutral NUMBER(10);
	  v180Positive NUMBER(10);
	  v180Negative NUMBER(10);
	  v180Neutral NUMBER(10);
	  vScoreTotal NUMBER(10);
	  vCountTotal NUMBER(10);
   BEGIN

	  -- Por cada seller,
	  FOR S IN SELLER_CUR(ndays) LOOP	
		-- Insertar el puntaje actualizado
		update_seller_scoring( S.USER_ID, 
						S.v7Positive, S.v7Negative, S.v7Neutral, 
						S.v30Positive, S.v30Negative, S.v30Neutral, 
						S.v180Positive, S.v180Negative, S.v180Neutral, 
						S.vScoreTotal, S.vCountTotal
						); 
	  END LOOP;

   END calculate_seller_scoring;
END scoring_pkg;
