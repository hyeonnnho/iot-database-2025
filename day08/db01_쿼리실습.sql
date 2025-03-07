-- 실무실습 계속

-- 서브쿼리 계속
/* 문제 1 - 사원의 급여 정보 중 업무별(job) 최소 급여를 받는 사원의 이름, 성을 name으로 별칭, 업무, 급여, 입사일로 출력(21행)
*/
SELECT CONCAT(E1.first_name, ' ', E1.last_name) AS 'name'
	 , E1.job_id
     , E1.salary
     , E1.hire_date
  FROM employees AS E1
 WHERE (E1.job_id, E1.salary) IN (SELECT E.job_id
									   , MIN(E.salary) AS salary
									FROM employees AS E
								   GROUP BY E.job_id);

-- 집합연산자 : 테이블 내용을 합쳐서 조회

-- 조건부 논리 표현식 제어 : CASE -> if문이랑 동일
/* 샘플문제 1 - 프로젝트 성공으로 급여 인상이 결정됨.
	사원 현재 107명 19개 업무에 소속되어 근무 중. 회사 업무 Distinct job_id 5개 업무에서 일하는 사원.
    HR_REP(10), MK_REP(12), PR_REP(15), SA_REP(18), IT_PROG(20%) 5개 업무를 제외하고는 나머지는 동결(107행)
*/
SELECT employee_id
	 , CONCAT(first_name, ' ', last_name) AS 'name'
     , job_id
     , salary
     , CASE job_id WHEN 'HR_REP' THEN salary * 1.10
				   WHEN 'MR_REP' THEN salary * 1.12
                   WHEN 'PR_REP' THEN salary * 1.15
                   WHEN 'SR_REP' THEN salary * 1.18
                   WHEN 'IT_PROG' THEN salary * 1.20
	   END AS 'NewSalary'
FROM employees;

/* 문제 3 : 월별로 입사한 사원수가 아래와 같이 행별로 출력되도록 하시오.(12행)
*/
-- 행변환 함수 CAST(), CONVERT()
SELECT CAST('-09' AS UNSIGNED); -- UNSIGEND(양수만 숫자형)
SELECT CONVERT('-09', SIGNED); -- SIGNED(음수 포함 숫자형)
SELECT CONVERT(00009, CHAR);
SELECT CONVERT('20250307', DATE);

-- GROUP BY 설정 문제 해결
 select @@sql_mode; 
 SET SESSION sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
/* Error Code: 1055. 
Expression #2 of SELECT list is not in GROUP BY clause and contains nonaggregated column 'hr.employees.hire_date' 
			which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by
*/ 

-- 컬럼을 입사일 중 월만 추출해서 숫자로 변경
SELECT CONVERT(DATE_FORMAT(hire_date, '%m'), signed)
  FROM employees
 GROUP BY CONVERT(DATE_FORMAT(hire_date, '%m'), signed);

-- case문을 사용 1월부터 12월까지 expand
SELECT CASE CONVERT(DATE_FORMAT(hire_date, '%m'), signed) WHEN 1 THEN COUNT(*) ELSE 0 END AS '1월' -- 1월 만들어서 나머지는 복사 수정
     , CASE CONVERT(DATE_FORMAT(hire_date, '%m'), signed) WHEN 2 THEN COUNT(*) ELSE 0 END AS '2월'
     , CASE CONVERT(DATE_FORMAT(hire_date, '%m'), signed) WHEN 3 THEN COUNT(*) ELSE 0 END AS '3월'
     , CASE CONVERT(DATE_FORMAT(hire_date, '%m'), signed) WHEN 4 THEN COUNT(*) ELSE 0 END AS '4월'
     , CASE CONVERT(DATE_FORMAT(hire_date, '%m'), signed) WHEN 5 THEN COUNT(*) ELSE 0 END AS '5월'
     , CASE CONVERT(DATE_FORMAT(hire_date, '%m'), signed) WHEN 6 THEN COUNT(*) ELSE 0 END AS '6월'
     , CASE CONVERT(DATE_FORMAT(hire_date, '%m'), signed) WHEN 7 THEN COUNT(*) ELSE 0 END AS '7월'
     , CASE CONVERT(DATE_FORMAT(hire_date, '%m'), signed) WHEN 8 THEN COUNT(*) ELSE 0 END AS '8월'
     , CASE CONVERT(DATE_FORMAT(hire_date, '%m'), signed) WHEN 9 THEN COUNT(*) ELSE 0 END AS '9월'
     , CASE CONVERT(DATE_FORMAT(hire_date, '%m'), signed) WHEN 10 THEN COUNT(*) ELSE 0 END AS '10월'
     , CASE CONVERT(DATE_FORMAT(hire_date, '%m'), signed) WHEN 11 THEN COUNT(*) ELSE 0 END AS '11월'
     , CASE CONVERT(DATE_FORMAT(hire_date, '%m'), signed) WHEN 12 THEN COUNT(*) ELSE 0 END AS '12월'
  FROM employees
 GROUP BY CONVERT(DATE_FORMAT(hire_date, '%m'), signed)
 ORDER BY CONVERT(DATE_FORMAT(hire_date, '%m'), signed);
 
-- ROLLUP
/* 샘플 - 부서와 업무별 급여합계를 구하고 신년도 급여 수준 레벨을 지정하려고 함.
			부서 번호와 업무를 기분으로 전해 행을 그룹별로 나누어 급여합계와 인원 수를 출력(20행)
*/
SELECT department_id, job_id
	 , CONCAT('$', FORMAT(SUM(salary), 0)) AS 'Salary SUM'
     , COUNT(employee_id) AS 'COUNT EMPs'
  FROM employees
 GROUP BY department_id, job_id
 ORDER BY department_id;

-- 각 총계
SELECT department_id, job_id
	 , CONCAT('$', FORMAT(SUM(salary), 0)) AS 'Salary SUM'
     , COUNT(employee_id) AS 'COUNT EMPs'
  FROM employees
 GROUP BY department_id, job_id
  WITH ROLLUP; -- GROUP BY 의 컬럼이 하나면 총계는 하나, 컬럼이 두개면 첫번째 컬럼별로 소계, 두 컬럼의 합산이 총계로
  
/* 문제1 - 이전 문제를 활용, 집계 결과가 아니면 (ALL-DEPTs)라고 출력, 업무에 대한 집계 결과가 아니면(ALL-JOBs)를 출력
			ROLLUP으로 만들어진 소계면 (ALL-JOBs), 총계면 (ALL-DEPTs)
*/
SELECT CASE GROUPING(department_id) WHEN 1 THEN '(ALL-DEPTs)' ELSE IFNULL(department_id, '부서없음') END AS 'Dept#'
	 , CASE GROUPING(job_id) WHEN 1 THEN '(ALL-JOBs)' ELSE job_id END AS 'Jobs'
	 , CONCAT('$', FORMAT(SUM(salary), 0)) AS 'Salary SUM'
     , COUNT(employee_id) AS 'COUNT EMPs'
     , FORMAT(AVG(salary) * 12, 0) AS 'Avg Ann_sal'
     -- , GROUPING(department_id) -- GROUP BY 와 WITH ROLLUP을 사용할 때 그룹핑이 어떻게 되는지 확인하는 함수
     -- , GROUPING(job_id)
  FROM employees
 GROUP BY department_id, job_id
  WITH ROLLUP;
  
-- RANK
/* 샘플 - 분석함수 NTILE() 사용, 부서별 급여 합계를 구하시오. 급여가 제일 큰 것이 1, 제일 작은 것이 4가 되도록 등급을 나누시오.(12행)
*/
SELECT department_id
	 , SUM(salary) AS 'Sum Salary'
     , NTILE (4) OVER (ORDER BY SUM(salary) DESC) AS 'Bucket#' -- 범위별로 등급 매기는 키워드
  FROM employees
 GROUP BY department_id;
 
/* 문제1 - 부서별 급여를 기준으로 내림차순 정렬하시오. 이때 다음 세가지 함수를 이용하여, 순위를 출력하시오(107행)
*/
SELECT employee_id
	 , last_name
     , salary
     , department_id
     , RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS 'RNAK' -- 1, 1, 3 순위매기기 RANK
     , DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS 'Dense_RANK' -- 1, 1, 2 순위매기기 RANK
     , ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS 'Row_Number' -- 행번호 매기기
  FROM employees
 ORDER BY department_id ASC, salary DESC;
 
SELECT employee_id
	 , last_name
     , salary
     , department_id
  FROM employees
 ORDER BY department_id ASC, salary DESC;


  