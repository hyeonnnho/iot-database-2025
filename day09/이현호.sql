-- 250310 코딩테스트
-- 1번
SELECT Email
	 , Mobile
     , Names
     , Addr
  FROM membertbl;
  
-- 2번
SELECT Names AS '도서명'
	 , Author AS '저자'
     , ISBN
     , Price AS '정가'
  FROM bookstbl
 ORDER BY ISBN;
 
-- 3번
SELECT m.Names
	 , m.Levels
     , m.Addr
     , NULL AS '대여일'
  FROM membertbl AS m
 WHERE m.idx NOT IN (SELECT r.memberIdx
					FROM rentaltbl AS r)
 ORDER BY m.Levels, m.Names;

-- 4번
SELECT CASE WHEN d.Names IS NULL THEN '--합계--' ELSE d.Names END AS '장르'
	 , concat(format(SUM(b.PRICE), 0), '원') AS '총합계금액'
  FROM divtbl AS d, bookstbl as b
 WHERE d.Division = b.Division
 GROUP BY d.Names
 WITH ROLLUP;
