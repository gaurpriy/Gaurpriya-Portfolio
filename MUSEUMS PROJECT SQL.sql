-- QUERY 1 :  Fetch all the paintings which are not displayed on any museums?


SELECT *
FROM work$ w
WHERE museum_id is not null 


-- QUERY 2 :  Are there museums without any paintings?

SELECT*
FROM museum$ M
WHERE NOT EXISTS(SELECT W.museum_id
                  FROM work$ W
                   WHERE W.museum_id = M.museum_id)


-- QUERY 3 : How many paintings have an asking price of more than their regular price?

Select*
from product_size$
where regular_price < sale_price


-- QUERY 4 :  Identify the paintings whose asking price is less than 50% of its regular price

WITH S1 AS
(
Select*, .5*regular_price AS rp
from product_size$
)
SELECT W.work_id, w.name, S1.regular_price, S1.sale_price, S1.rp
FROM S1
join work$ w
on w.work_id = S1.work_id
WHERE sale_price < rp


-- QUERY 5 : Which canva size costs the most?

WITH C1 AS (
SELECT CS.label, RANK()OVER(ORDER BY sale_price desc) as rank_P, ps.sale_price  
FROM canvas_size$ CS
JOIN product_size$ PS
ON CS.size_id = PS.size_id
)
SELECT*
FROM C1
WHERE rank_P = 1

-- QUERY 6 : Delete duplicate records from  product_size, subject and image_link tables

SELECT * 
FROM product_size$
UNION 
SELECT *
FROM product_size$
order by work_id

SELECT*
FROM subject$
UNION
SELECT*
FROM subject$
ORDER BY work_id

SELECT*
FROM image_link$
UNION
SELECT*
FROM image_link$
ORDER BY work_id


-- QUERY 7 : Identify the museums with invalid city information in the given dataset

/*
THE INVALID CITY NAME HAS NUMBERS IN IT
*/

SELECT *
FROM museum$
WHERE city LIKE '%[0-9]%'

-- QUERY 8 :  Fetch the top 10 most famous painting subject.

with cte1 as(
SELECT work_id, COUNT(SUBJECT) AS COUNT_SUB
FROM subject$
GROUP BY SUBJECT, work_id
)
SELECT TOP 10*
FROM cte1
ORDER BY COUNT_SUB DESC


-- QUERY 9 : Identify the museums which are open on both Sunday and Monday. Display museum name, city.

SELECT M.name , M.city
FROM museum_hours$ MH
JOIN museum$ M
    ON MH.museum_id = M.museum_id
WHERE MH.day = 'Sunday' OR
      MH.day = 'Monday'


-- QUERY 10 : How many museums are open every single day?

WITH M AS(
SELECT  MH.museum_id,M.name, COUNT(MH.museum_id) AS DAYS_OPEN
FROM museum_hours$ MH
JOIN museum$ M
     ON MH.museum_id = M.museum_id
GROUP BY MH.museum_id, M.name
HAVING COUNT(MH.museum_id) = 7
)
SELECT COUNT(*) TOTAL_MUSEUMS_OPEN
FROM M 


-- QUERY 11 : Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)

WITH POP AS(
SELECT W.museum_id , M.name , COUNT(M.name) C_NAME
FROM work$ W
JOIN museum$ M
     ON W.museum_id = M.museum_id
GROUP BY W.museum_id , M.name
)
SELECT TOP 5*
FROM POP
ORDER BY C_NAME DESC

-- QUERY 12 : Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)

WITH POP_A AS(
SELECT A.artist_id , A.full_name, COUNT(A.artist_id) as number_paintings
FROM artist A
JOIN work$ W
     ON A.artist_id = W.artist_id
GROUP BY A.artist_id , A.full_name
)
SELECT TOP 5*
FROM POP_A
ORDER BY number_paintings DESC


-- QUERY 13 : Display the 3 least popular canva sizes


WITH P_W AS(
SELECT W.work_id, PS.size_id, W.name, W.style, W.artist_id
FROM work$ W
JOIN product_size$ PS
    ON W.work_id = PS.work_id 
)
SELECT CS.label, COUNT(CS.LABEL) AS C_LABEL
FROM P_W
JOIN canvas_size$ CS
ON P_W.size_id = CS.size_id
GROUP BY CS.label
ORDER BY C_LABEL

-- OR

WITH P_W AS(
SELECT  CS.size_id, CS.label, COUNT(CS.LABEL) AS NO_OF_PAINTINGS, DENSE_RANK() OVER (ORDER BY COUNT(CS.SIZE_ID)) AS R
FROM work$ W
JOIN product_size$ PS
    ON W.work_id = PS.work_id 
JOIN canvas_size$ CS
    ON PS.size_id = CS.size_id
GROUP BY CS.label, CS.size_id
)
SELECT*
FROM P_W
WHERE R <2


-- QUERY 14 : Which museum has the most no of most popular painting style?

WITH STYLE AS(
SELECT style, COUNT(STYLE) COUNT_STYLE, museum_id
FROM work$
GROUP BY style, museum_id
)
SELECT S.style , S.COUNT_STYLE , M.name
FROM STYLE S
JOIN museum$ M
    ON S.museum_id = M.museum_id
GROUP BY S.style, M.name, S.COUNT_STYLE
ORDER BY S.COUNT_STYLE DESC

-- QUERY 15 :  Identify the artists whose paintings are displayed in multiple countries

SELECT*
FROM artist

SELECT *
FROM museum$

WITH TOT AS (
SELECT DISTINCT A.full_name AS ARTIST_NAME , M.country COUNTRY_NAME
FROM work$ W
JOIN artist A
    ON W.artist_id = A.artist_id
JOIN museum$ M 
    ON M.museum_id = W.museum_id
) 
SELECT ARTIST_NAME, COUNT(COUNTRY_NAME) TOTAL
FROM TOT
GROUP BY ARTIST_NAME
HAVING COUNT(COUNTRY_NAME)>1
ORDER BY TOTAL DESC


-- QUERY 16 :  Display the country and the city with most no of museums. 
--             Output 2 seperate columns to mention the city and country.

WITH CTE1 AS(
SELECT DISTINCT name , city, country
FROM museum$
GROUP BY city, country, name
)
SELECT country, city , COUNT(NAME) CN
FROM CTE1
GROUP BY country, city
ORDER BY CN DESC


-- QUERY 17 :  Identify the artist and the museum where the most expensive and least expensive painting is placed.
--             Display the artist name, sale_price, painting name, museum name, museum city and canvas label

WITH CTE3 AS(
SELECT A.full_name, P.sale_price, W.name, M.name AS m_name, M.city,C.label 
FROM work$ W
JOIN artist A
     ON W.artist_id = A.artist_id
JOIN museum$ M
     ON W.museum_id = M.museum_id
JOIN product_size$ P
     ON W.work_id = P.work_id
JOIN canvas_size$ C
     ON P.size_id = C.size_id
),
CTE4 AS(
SELECT* , RANK() OVER(ORDER BY sale_price DESC) AS MAX_RN, RANK() OVER(ORDER BY sale_price) AS MIN_RN
FROM CTE3)
SELECT full_name,sale_price,name,m_name,city,label
from CTE4
where MAX_RN = 1 OR MIN_RN = 1
GROUP BY full_name,sale_price,name,m_name,city,label

--QUERY 18 : Which country has the 5th highest no of paintings?

WITH R_ANK AS(
SELECT  M.country, COUNT(W.NAME) C_PAINTINGS, RANK() OVER(ORDER BY COUNT(W.NAME) DESC ) AS RN
FROM museum$ M
JOIN work$ W
     ON M.museum_id = W.museum_id
GROUP BY M.country
)
SELECT *
FROM R_ANK
WHERE RN = 5

-- QUERY 19 : Which are the 3 most popular and 3 least popular painting styles?

WITH PL_RANK AS(
SELECT style, RANK() OVER(ORDER BY COUNT(STYLE) DESC) AS P_RANK , 
RANK() OVER(ORDER BY COUNT(STYLE) ) AS L_RANK
FROM work$
WHERE style IS NOT NULL
GROUP BY style
)
SELECT style,
CASE
    WHEN P_RANK <= 3 THEN 'MOST_POP'
	ELSE 'LEAST_POP' 
END AS POPULARITY
FROM PL_RANK
WHERE P_RANK <= 3 OR L_RANK <= 3 
ORDER BY P_RANK

-- QUERY 20 : Which artist has the most no of Portraits paintings outside USA?.
--            Display artist name, no of paintings and the artist nationality.

WITH MOST_POPULAR AS(
SELECT A.full_name, A.nationality, COUNT(W.name) AS PAINTING_COUNT, RANK() OVER(ORDER BY COUNT(W.name) DESC) AS RN
FROM work$ W
JOIN museum$ M 
     ON W.museum_id = M.museum_id
JOIN artist A
     ON A.artist_id = W.artist_id
JOIN subject$ S
     ON W.work_id = S.work_id
WHERE COUNTRY != 'USA' AND subject = 'Portraits'
GROUP BY A.full_name, A.nationality
)
SELECT full_name , nationality, PAINTING_COUNT
FROM MOST_POPULAR
WHERE RN = 1

