USE salesdb;

-- 데이터는 어느 기간을 담고 있고, 거래처는 총 몇 곳인가?
SELECT MIN(txn_date) AS `최초 거래일`
	, MAX(txn_date) AS `최종 거래일`
    , COUNT(DISTINCT customer_code) AS `총 거래처 수`
FROM sales;

-- 합계금액에 음수가 있는가? 몇 건이며 매출 계산에 어떻게 반영할 것인가?
SELECT COUNT(*) AS `총 전표수`,
       SUM(total_amount) AS `전체 합계`,
       SUM(CASE WHEN total_amount < 0 THEN 1 END) AS `음수 건수`,
       SUM(CASE WHEN total_amount < 0 THEN total_amount END) AS `음수 합계`,
       SUM(CASE WHEN total_amount > 0 THEN total_amount END) AS `음수 제외 합계`
FROM sales;

SELECT CASE WHEN total_amount < 0 THEN '음수' ELSE '양수' END AS `구분`,
       COUNT(*) AS `건수`,
       SUM(total_amount) AS `합계`
FROM sales
WHERE is_modified = 'Y'
GROUP BY 구분;

-- 거래처별 매출은 어떻게 분포하며, 특정 소수에 쏠려있는가, 고르게 퍼져있는가?
SELECT customer_code AS `거래처`
	, SUM(total_amount) AS `매출`
FROM sales
GROUP BY customer_code
ORDER BY 매출 DESC;

-- 매출은 시간이 지남에 따라 성장인지, 감소인, 정체인지?
SELECT `year` AS `연도`
	, SUM(total_amount) AS `상반기 매출`
FROM sales
WHERE MONTH(txn_date) <= 6
GROUP BY `year`
ORDER BY `year`;

