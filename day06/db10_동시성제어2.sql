START TRANSACTION;

SELECT * FROM Book;

INSERT INTO Book VALUES (98, '데이터베이스', '한빛', 25000); -- 트랜잯견이 걸린 상태

UPDATE Book SET
	   price = 48000
 WHERE bookid = 98;
 
COMMIT;