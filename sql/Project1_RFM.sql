-- Recency(R): 기준일(2026-06-30) 대비 마지막 거래일까지의 경과일 (정상 거래 is_modified='N' 기준)
USE salesdb;
SELECT customer_code AS `거래처`
       , MAX(txn_date) AS `마지막거래일`
       , DATEDIFF('2026-06-30', MAX(txn_date)) AS `R_경과일`
FROM sales
WHERE is_modified = 'N'
GROUP BY customer_code
ORDER BY `R_경과일`;

-- R 점수화: 경과일을 20/40/60/80% 분위로 5등급화 (경과일이 짧을수록 높은 점수)
USE salesdb;
SELECT customer_code AS `거래처`
	, DATEDIFF('2026-06-30', MAX(txn_date)) AS `경과일`
	,CASE WHEN DATEDIFF('2026-06-30', MAX(txn_date)) <= 0 THEN 5
		  WHEN DATEDIFF('2026-06-30', MAX(txn_date)) <= 30.6 THEN 4
          WHEN DATEDIFF('2026-06-30', MAX(txn_date)) <= 181 THEN 3
          WHEN DATEDIFF('2026-06-30', MAX(txn_date)) <= 498.2 THEN 2
		  ELSE 1 END AS `R_점수`
FROM sales
WHERE is_modified = 'N'
GROUP BY customer_code
ORDER BY R_점수 DESC;

-- Frequency(F): 거래처별 정상 거래 건수 (수정전표 is_modified='N' 제외)
USE salesdb;
SELECT customer_code AS `거래처`
       , COUNT(*) AS `F_거래건수`
FROM sales
WHERE is_modified = 'N'
GROUP BY customer_code
ORDER BY `F_거래건수` DESC;

-- F 점수화: 거래 건수를 5등급화 (건수가 많을수록 높은 점수)
USE salesdb;
SELECT customer_code AS `거래처`
	, CASE WHEN COUNT(*) >= 29.4 THEN 5
     WHEN COUNT(*) >= 12.0 THEN 4
     WHEN COUNT(*) >= 4.2  THEN 3
     WHEN COUNT(*) >= 1.6  THEN 2
     ELSE 1 END AS `F_점수`
FROM sales
WHERE is_modified = 'N'
GROUP BY customer_code;

-- Monetary(M): 거래처별 전체 순매출 (정정 반영, 전체 전표 합산)
USE salesdb;
SELECT customer_code AS `거래처`
	, SUM(total_amount) AS `매출`
FROM sales
GROUP BY customer_code
ORDER By customer_code ASC;

-- M 점수화: 매출을 5등급화 (매출이 클수록 높은 점수)
USE salesdb;
SELECT customer_code AS `거래처`
	, CASE WHEN SUM(total_amount) >= 1954950550.20 THEN 5
     WHEN SUM(total_amount) >= 598260146 THEN 4
     WHEN SUM(total_amount) >= 118687683.40 THEN 3
     WHEN SUM(total_amount) >= 15066763.80 THEN 2
     ELSE 1 END AS `M_점수`
FROM sales
GROUP BY customer_code;


-- RFM 통합 점수: R,F는 정상 거래(is_modified='N'), M은 전체 순매출 기준으로 한 번에 산출
USE salesdb;
SELECT customer_code AS `거래처`
		-- R: 경과일 => 5등급 (짧을수록 높음)
		, CASE WHEN DATEDIFF('2026-06-30', MAX(CASE WHEN is_modified = 'N' THEN txn_date END)) <= 0 THEN 5
			   WHEN DATEDIFF('2026-06-30', MAX(CASE WHEN is_modified = 'N' THEN txn_date END)) <= 30.6 THEN 4
               WHEN DATEDIFF('2026-06-30', MAX(CASE WHEN is_modified = 'N' THEN txn_date END)) <= 181 THEN 3
               WHEN DATEDIFF('2026-06-30', MAX(CASE WHEN is_modified = 'N' THEN txn_date END)) <= 498.2 THEN 2
               ELSE 1 END AS `R_점수`
		-- F: 정상 거래 건수 => 5등급 (많을수록 높음)
		, CASE WHEN COUNT(CASE WHEN is_modified = 'N' THEN 1 END ) >= 29.4 THEN 5
			   WHEN COUNT(CASE WHEN is_modified = 'N' THEN 1 END ) >=  12.0 THEN 4
               WHEN COUNT(CASE WHEN is_modified = 'N' THEN 1 END ) >=  4.2 THEN 3
               WHEN COUNT(CASE WHEN is_modified = 'N' THEN 1 END ) >=  1.6 THEN 2
               ELSE 1 END AS `F_점수`
		-- M: 전체 순매출 => 5등급 (클수록 높음)
		, CASE WHEN SUM(total_amount) >= 1954950550.20 THEN 5
			   WHEN SUM(total_amount) >= 598260146 THEN 4
               WHEN SUM(total_amount) >= 118687683.40 THEN 3 
               WHEN SUM(total_amount) >= 15066763.80 THEN 2
               ELSE 1 END AS `M_점수`
FROM sales
GROUP BY customer_code
ORDER BY `거래처`;

