
--데이터셋
https://www.kaggle.com/datasets/juhi1994/superstore

--데이터의 주문일자의 범위
select min(order_date) ,max(order_date)
from super

--어떤 도시에서 주문을 많이했을까?
select city , count(order_id) as "도시별 주문수"
from super
group by city
order by count(order_id) desc



--가장 많이 주문한 고객은 몇번을 주문했을까??

select customer_id ,count(customer_id)
from super
group by customer_id
order by count(customer_id) desc


--주문하면 평균적으로 몇일 뒤에 발송할까??
select round(avg(ship_date-order_date),2)
from super



--월별 매출 분석
select to_char(order_date,'yyyymm') as order_month ,round(sum(sales) ,2) as sale
from super
group by to_char(order_date,'yyyymm')
order by order_month asc


--분기별 매출 분석
select to_char(order_date,'yyyy') year,
round(sum(case when to_char(order_date,'q')=1 then sales end)) "1분기",
round(sum(case when to_char(order_date,'q')=1 then sales end) / sum(sales),2) "1분기 매출 비중",
round(sum(case when to_char(order_date,'q')=2 then sales end)) "2분기",
round(sum(case when to_char(order_date,'q')=2 then sales end) / sum(sales),2) "2분기 매출 비중",
round(sum(case when to_char(order_date,'q')=3 then sales end)) "3분기",
round(sum(case when to_char(order_date,'q')=3 then sales end) / sum(sales),2) "3분기 매출 비중",
round(sum(case when to_char(order_date,'q')=4 then sales end)) "4분기",
round(sum(case when to_char(order_date,'q')=4 then sales end) / sum(sales),2) "4분기 매출 비중"
from super
group by to_char(order_date,'yyyy')
order by 1;


--요일별 매출 분석
select to_char(order_date,'yyyy') year,
round(sum(case when to_char(order_date,'day')='월요일' then sales end)) "월요일",
round(sum(case when to_char(order_date,'day')='화요일' then sales end)) "화요일",
round(sum(case when to_char(order_date,'day')='수요일' then sales end)) "수요일",
round(sum(case when to_char(order_date,'day')='목요일' then sales end)) "목요일",
round(sum(case when to_char(order_date,'day')='금요일' then sales end)) "금요일",
round(sum(case when to_char(order_date,'day')='토요일' then sales end)) "토요일",
round(sum(case when to_char(order_date,'day')='일요일' then sales end)) "일요일"

from super
group by to_char(order_date,'yyyy')
order by 1;

--요일별 매출 비중
select to_char(order_date,'yyyy') year,
round(sum(case when to_char(order_date,'day')='월요일' then sales end)/ sum(sales),2) "월요일",
round(sum(case when to_char(order_date,'day')='화요일' then sales end)/ sum(sales),2) "화요일",
round(sum(case when to_char(order_date,'day')='수요일' then sales end)/ sum(sales),2) "수요일",
round(sum(case when to_char(order_date,'day')='목요일' then sales end)/ sum(sales),2) "목요일",
round(sum(case when to_char(order_date,'day')='금요일' then sales end)/ sum(sales),2) "금요일",
round(sum(case when to_char(order_date,'day')='토요일' then sales end)/ sum(sales),2) "토요일",
round(sum(case when to_char(order_date,'day')='일요일' then sales end)/ sum(sales),2) "일요일"

from super
group by to_char(order_date,'yyyy')
order by 1;


--서브카테고리별 매출 분석
select  sub_category ,cust_cnt,
    dense_rank() over (order by cust_cnt desc ) as cust_cnt_ranking,
    round(sum_sales) as sc_sales, 
    round( sum_sales *100/ (select sum(sales) from super),2 ) as sales_ratio,
    dense_rank() over (order by sum_sales desc) as sales_ranking,
    round(sum_disc *100/ (select sum(discount) from super),2 ) as discount_ratio,
    dense_rank() over (order by sum_disc desc) as discount_ranking,
    case when sum_disc >= avg(sum_disc) over() then 'high' else 'low' end as compare_avg_discount
from (select count(customer_id) as cust_cnt,  sub_category, sum(sales) as sum_sales, sum(discount) as sum_disc 
from super 
group by  sub_category)
order by sc_sales desc

storage와 tables는 평균보다 낮은 할인이 적용됐지만 storage는 구매 고객수가 많고
tables는 물건의 개별 단가가 높기 때문에 매출 상위 Top 5에 들었다고 판단하였다.

furnishings와 paper는 평균보다 큰 할인이 적용되고 구매 고객수또한 많았지만 개별단가가 높지 않아서 큰 매출을 올리지 못한 것으로 판단하였다.




--첫 구매일자 구하기

with first_order_date  as
(
select  customer_id,min(order_date) as "첫구매일자"
from super 
group by customer_id
),
order_record as
(
select s.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "구매월",
       to_char(s.order_date,'yyyymmdd') as "구매일자",
       f.첫구매일자,
       to_char(f.첫구매일자, 'yyyymm') AS "첫구매월",
       case when to_char(f.첫구매일자)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
left join first_order_date f on s.customer_id=f.customer_id 
)

select * 
from order_record

--클래식 리텐션
with first_order_date  as
(
select distinct customer_id, min(order_date) as "최초구매일자" --가입기록이나 다른 로그가 없기 때문에 유저가 최초로 물건을 구매한 날짜로 설정 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "구매월",
       to_char(s.order_date,'yyyymmdd') as "구매일자",
       f.최초구매일자 as "최초구매일자",
       to_char(f.최초구매일자, 'yyyymm') AS "최초구매월",
       case when to_char(f.최초구매일자)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select 최초구매월
       ,count(distinct case when 구매월=최초구매월 then customer_id end) "0개월"
       ,count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '1' month) then customer_id end) "1개월"
       ,count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '2' month) then customer_id end) "2개월"
       ,count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '3' month) then customer_id end) "3개월"
       ,count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '4' month) then customer_id end) "4개월"
       ,count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '5' month) then customer_id end) "5개월"
       ,count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '6' month) then customer_id end) "6개월"
       ,count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '7' month) then customer_id end) "7개월"
       ,count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '8' month) then customer_id end) "8개월"
       ,count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '9' month) then customer_id end) "9개월"
       ,count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '10' month) then customer_id end) "10개월"
       ,count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '11' month) then customer_id end) "11개월"
       ,count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '12' month) then customer_id end) "12개월"

from order_record
group by 최초구매월
 


--클래식리텐션 비율 (2014년부터 1년간)
with first_order_date  as
(
select distinct customer_id, min(order_date) as "최초구매일자" --가입기록이나 다른 로그가 없기 때문에 유저가 최초로 물건을 구매한 날짜로 설정 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "구매월",
       to_char(s.order_date,'yyyymmdd') as "구매일자",
       f.최초구매일자 as "최초구매일자",
       to_char(f.최초구매일자, 'yyyymm') AS "최초구매월",
       case when to_char(f.최초구매일자)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select 최초구매월
       ,count(distinct case when 구매월=최초구매월 then customer_id end) "month0"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '1' month) then customer_id end)/ count(distinct customer_id),2) "pct_1"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '2' month) then customer_id end)/ count(distinct customer_id),2) "pct_2"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '3' month) then customer_id end)/ count(distinct customer_id),2) "pct_3"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '4' month) then customer_id end)/ count(distinct customer_id),2) "pct_4"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '5' month) then customer_id end)/ count(distinct customer_id),2) "pct_5"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '6' month) then customer_id end)/ count(distinct customer_id),2) "pct_6"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '7' month) then customer_id end)/ count(distinct customer_id),2) "pct_7"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '8' month) then customer_id end)/ count(distinct customer_id),2) "pct_8"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '9' month) then customer_id end)/ count(distinct customer_id),2) "pct_9"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '10' month) then customer_id end)/ count(distinct customer_id),2) "pct_10"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '11' month) then customer_id end)/ count(distinct customer_id),2) "pct_11"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '12' month) then customer_id end)/ count(distinct customer_id),2) "pct_12"
      
from order_record
where 최초구매월 like '2014%'
group by 최초구매월



--2014년 1년 이후의 데이터 (2015)
with first_order_date  as
(
select distinct customer_id, min(order_date) as "최초구매일자" --가입기록이나 다른 로그가 없기 때문에 유저가 최초로 물건을 구매한 날짜로 설정 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "구매월",
       to_char(s.order_date,'yyyymmdd') as "구매일자",
       f.최초구매일자 as "최초구매일자",
       to_char(f.최초구매일자, 'yyyymm') AS "최초구매월",
       case when to_char(f.최초구매일자)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select 최초구매월
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '13' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 1m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '14' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 2m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '15' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 3m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '16' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 4m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '17' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 5m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '18' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 6m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '19' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 7m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '20' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 8m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '21' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 9m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '22' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 10m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '23' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 11m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '24' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 12m"
       
from order_record
where 최초구매월 like '2014%'
group by 최초구매월





--2014년 2년 이후의 데이터 (2016)
with first_order_date  as
(
select distinct customer_id, min(order_date) as "최초구매일자" --가입기록이나 다른 로그가 없기 때문에 유저가 최초로 물건을 구매한 날짜로 설정 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "구매월",
       to_char(s.order_date,'yyyymmdd') as "구매일자",
       f.최초구매일자 as "최초구매일자",
       to_char(f.최초구매일자, 'yyyymm') AS "최초구매월",
       case when to_char(f.최초구매일자)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select 최초구매월
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '25' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 1m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '26' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 2m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '27' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 3m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '28' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 4m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '29' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 5m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '30' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 6m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '31' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 7m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '32' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 8m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '33' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 9m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '34' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 10m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '35' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 11m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '36' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 12m"
       
from order_record
where 최초구매월 like '2014%'
group by 최초구매월



--2014년 3년 이후의 데이터 (2017)
with first_order_date  as
(
select distinct customer_id, min(order_date) as "최초구매일자" --가입기록이나 다른 로그가 없기 때문에 유저가 최초로 물건을 구매한 날짜로 설정 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "구매월",
       to_char(s.order_date,'yyyymmdd') as "구매일자",
       f.최초구매일자 as "최초구매일자",
       to_char(f.최초구매일자, 'yyyymm') AS "최초구매월",
       case when to_char(f.최초구매일자)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select 최초구매월
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '37' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 1m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '38' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 2m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '39' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 3m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '40' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 4m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '41' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 5m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '42' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 6m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '43' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 7m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '44' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 8m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '45' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 9m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '46' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 10m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '47' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 11m"
from order_record
where 최초구매월 like '2014%'
group by 최초구매월




--클래식리텐션 비율 (2015년부터 1년간)
with first_order_date  as
(
select distinct customer_id, min(order_date) as "최초구매일자" --가입기록이나 다른 로그가 없기 때문에 유저가 최초로 물건을 구매한 날짜로 설정 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "구매월",
       to_char(s.order_date,'yyyymmdd') as "구매일자",
       f.최초구매일자 as "최초구매일자",
       to_char(f.최초구매일자, 'yyyymm') AS "최초구매월",
       case when to_char(f.최초구매일자)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select 최초구매월
       ,count(distinct case when 구매월=최초구매월 then customer_id end) "month0"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '1' month) then customer_id end)/ count(distinct customer_id),2) "pct_1"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '2' month) then customer_id end)/ count(distinct customer_id),2) "pct_2"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '3' month) then customer_id end)/ count(distinct customer_id),2) "pct_3"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '4' month) then customer_id end)/ count(distinct customer_id),2) "pct_4"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '5' month) then customer_id end)/ count(distinct customer_id),2) "pct_5"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '6' month) then customer_id end)/ count(distinct customer_id),2) "pct_6"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '7' month) then customer_id end)/ count(distinct customer_id),2) "pct_7"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '8' month) then customer_id end)/ count(distinct customer_id),2) "pct_8"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '9' month) then customer_id end)/ count(distinct customer_id),2) "pct_9"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '10' month) then customer_id end)/ count(distinct customer_id),2) "pct_10"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '11' month) then customer_id end)/ count(distinct customer_id),2) "pct_11"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '12' month) then customer_id end)/ count(distinct customer_id),2) "pct_12"
      
from order_record
where 최초구매월 like '2015%'
group by 최초구매월



--2015년 1년 이후의 데이터 (2016)
with first_order_date  as
(
select distinct customer_id, min(order_date) as "최초구매일자" --가입기록이나 다른 로그가 없기 때문에 유저가 최초로 물건을 구매한 날짜로 설정 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "구매월",
       to_char(s.order_date,'yyyymmdd') as "구매일자",
       f.최초구매일자 as "최초구매일자",
       to_char(f.최초구매일자, 'yyyymm') AS "최초구매월",
       case when to_char(f.최초구매일자)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select 최초구매월
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '13' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 1m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '14' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 2m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '15' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 3m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '16' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 4m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '17' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 5m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '18' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 6m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '19' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 7m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '20' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 8m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '21' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 9m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '22' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 10m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '23' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 11m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '24' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 12m"
       
from order_record
where 최초구매월 like '2015%'
group by 최초구매월


--2015년 2년 이후의 데이터 (2017)
with first_order_date  as
(
select distinct customer_id, min(order_date) as "최초구매일자" --가입기록이나 다른 로그가 없기 때문에 유저가 최초로 물건을 구매한 날짜로 설정 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "구매월",
       to_char(s.order_date,'yyyymmdd') as "구매일자",
       f.최초구매일자 as "최초구매일자",
       to_char(f.최초구매일자, 'yyyymm') AS "최초구매월",
       case when to_char(f.최초구매일자)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select 최초구매월
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '25' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 1m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '26' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 2m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '27' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 3m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '28' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 4m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '29' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 5m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '30' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 6m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '31' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 7m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '32' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 8m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '33' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 9m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '34' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 10m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '35' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 11m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '36' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 12m"
       
from order_record
where 최초구매월 like '2015%'
group by 최초구매월


       
       
--클래식리텐션 비율 (2016년부터 1년간)
with first_order_date  as
(
select distinct customer_id, min(order_date) as "최초구매일자" --가입기록이나 다른 로그가 없기 때문에 유저가 최초로 물건을 구매한 날짜로 설정 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "구매월",
       to_char(s.order_date,'yyyymmdd') as "구매일자",
       f.최초구매일자 as "최초구매일자",
       to_char(f.최초구매일자, 'yyyymm') AS "최초구매월",
       case when to_char(f.최초구매일자)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select 최초구매월
       ,count(distinct case when 구매월=최초구매월 then customer_id end) "month0"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '1' month) then customer_id end)/ count(distinct customer_id),2) "pct_1"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '2' month) then customer_id end)/ count(distinct customer_id),2) "pct_2"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '3' month) then customer_id end)/ count(distinct customer_id),2) "pct_3"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '4' month) then customer_id end)/ count(distinct customer_id),2) "pct_4"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '5' month) then customer_id end)/ count(distinct customer_id),2) "pct_5"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '6' month) then customer_id end)/ count(distinct customer_id),2) "pct_6"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '7' month) then customer_id end)/ count(distinct customer_id),2) "pct_7"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '8' month) then customer_id end)/ count(distinct customer_id),2) "pct_8"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '9' month) then customer_id end)/ count(distinct customer_id),2) "pct_9"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '10' month) then customer_id end)/ count(distinct customer_id),2) "pct_10"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '11' month) then customer_id end)/ count(distinct customer_id),2) "pct_11"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '12' month) then customer_id end)/ count(distinct customer_id),2) "pct_12"
      
from order_record
where 최초구매월 like '2016%'
group by 최초구매월

       
       
--2016년 1년 이후의 데이터 (2017)
with first_order_date  as
(
select distinct customer_id, min(order_date) as "최초구매일자" --가입기록이나 다른 로그가 없기 때문에 유저가 최초로 물건을 구매한 날짜로 설정 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "구매월",
       to_char(s.order_date,'yyyymmdd') as "구매일자",
       f.최초구매일자 as "최초구매일자",
       to_char(f.최초구매일자, 'yyyymm') AS "최초구매월",
       case when to_char(f.최초구매일자)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select 최초구매월
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '13' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 1m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '14' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 2m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '15' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 3m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '16' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 4m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '17' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 5m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '18' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 6m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '19' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 7m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '20' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 8m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '21' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 9m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '22' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 10m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '23' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 11m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '24' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 12m"
       
from order_record
where 최초구매월 like '2016%'
group by 최초구매월

       


--클래식리텐션 비율 (2017년부터 1년간)
with first_order_date  as
(
select distinct customer_id, min(order_date) as "최초구매일자" --가입기록이나 다른 로그가 없기 때문에 유저가 최초로 물건을 구매한 날짜로 설정 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "구매월",
       to_char(s.order_date,'yyyymmdd') as "구매일자",
       f.최초구매일자 as "최초구매일자",
       to_char(f.최초구매일자, 'yyyymm') AS "최초구매월",
       case when to_char(f.최초구매일자)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select 최초구매월
       ,count(distinct case when 구매월=최초구매월 then customer_id end) "month0"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '1' month) then customer_id end)/ count(distinct customer_id),2) "pct_1"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '2' month) then customer_id end)/ count(distinct customer_id),2) "pct_2"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '3' month) then customer_id end)/ count(distinct customer_id),2) "pct_3"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '4' month) then customer_id end)/ count(distinct customer_id),2) "pct_4"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '5' month) then customer_id end)/ count(distinct customer_id),2) "pct_5"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '6' month) then customer_id end)/ count(distinct customer_id),2) "pct_6"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '7' month) then customer_id end)/ count(distinct customer_id),2) "pct_7"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '8' month) then customer_id end)/ count(distinct customer_id),2) "pct_8"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '9' month) then customer_id end)/ count(distinct customer_id),2) "pct_9"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '10' month) then customer_id end)/ count(distinct customer_id),2) "pct_10"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '11' month) then customer_id end)/ count(distinct customer_id),2) "pct_11"
       ,round(count(distinct case when to_date(구매월,'yyyymm')=to_date(최초구매월,'yyyymm') + (interval '12' month) then customer_id end)/ count(distinct customer_id),2) "pct_12"
      
from order_record
where 최초구매월 like '2017%'
group by 최초구매월

     


--할인율 계산

with first_order_date  as
(
select distinct customer_id, min(order_date) as "최초구매일자" --가입기록이나 다른 로그가 없기 때문에 유저가 최초로 물건을 구매한 날짜로 설정 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       s.discount,
       to_char(s.order_date,'yyyymm') as "구매월",
       to_char(s.order_date,'yyyymmdd') as "구매일자",
       f.최초구매일자 as "최초구매일자",
       to_char(f.최초구매일자, 'yyyymm') AS "최초구매월",
       case when to_char(f.최초구매일자)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 
)

select 구매월,구매횟수, round(avg_discount*100,2) as "평균할인",round(avg_discount*100 / sum(avg_discount) over(),2) as "평균할인율"
from(
  select 구매월,count(distinct customer_id) as "구매횟수", avg(discount) as avg_discount
  from order_record
  where 최초구매월 = 201509
  group by 구매월)  

order by 구매월



롤링 리텐션: 이탈에 초점을 맞춤
                    
--롤링 리텐션
with first_order_date  as
(
select distinct customer_id, min(order_date) as "최초구매일자" --가입기록이나 다른 로그가 없기 때문에 유저가 최초로 물건을 구매한 날짜로 설정 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "구매월",
       to_char(s.order_date,'yyyymmdd') as "구매일자",
       f.최초구매일자 as "최초구매일자",
       to_char(f.최초구매일자, 'yyyymm') AS "최초구매월",
       case when to_char(f.최초구매일자)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select 최초구매월
       ,count(distinct case when 구매월=최초구매월 then customer_id end) "0개월"
       ,count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '1' month) then customer_id end) "1개월"
       ,count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '2' month) then customer_id end) "2개월"
       ,count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '3' month) then customer_id end) "3개월"
       ,count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '4' month) then customer_id end) "4개월"
       ,count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '5' month) then customer_id end) "5개월"
       ,count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '6' month) then customer_id end) "6개월"
       ,count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '7' month) then customer_id end) "7개월"
       ,count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '8' month) then customer_id end) "8개월"
       ,count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '9' month) then customer_id end) "9개월"
       ,count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '10' month) then customer_id end) "10개월"
       ,count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '11' month) then customer_id end) "11개월"
       ,count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '12' month) then customer_id end) "12개월"

from order_record
group by 최초구매월
 




--2015년부터 2017년까지의 롤링리텐션 비율
with first_order_date  as
(
select distinct customer_id, min(order_date) as "최초구매일자" --가입기록이나 다른 로그가 없기 때문에 유저가 최초로 물건을 구매한 날짜로 설정 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "구매월",
       to_char(s.order_date,'yyyymmdd') as "구매일자",
       f.최초구매일자 as "최초구매일자",
       to_char(f.최초구매일자, 'yyyymm') AS "최초구매월",
       case when to_char(f.최초구매일자)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select 최초구매월
       ,count(distinct case when 구매월=최초구매월 then customer_id end) "month0"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '1' month) then customer_id end)/ count(distinct customer_id),2)  "pct_1"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '2' month) then customer_id end)/ count(distinct customer_id),2) "pct_2"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '3' month) then customer_id end)/ count(distinct customer_id),2) "pct_3"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '4' month) then customer_id end)/ count(distinct customer_id),2) "pct_4"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '5' month) then customer_id end)/ count(distinct customer_id),2) "pct_5"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '6' month) then customer_id end)/ count(distinct customer_id),2) "pct_6"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '7' month) then customer_id end)/ count(distinct customer_id),2) "pct_7"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '8' month) then customer_id end)/ count(distinct customer_id),2) "pct_8"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '9' month) then customer_id end)/ count(distinct customer_id),2) "pct_9"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '10' month) then customer_id end)/ count(distinct customer_id),2) "pct_10"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '11' month) then customer_id end)/ count(distinct customer_id),2) "pct_11"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '12' month) then customer_id end)/ count(distinct customer_id),2) "pct_12"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '13' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 1m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '14' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 2m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '15' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 3m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '16' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 4m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '17' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 5m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '18' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 6m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '19' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 7m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '20' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 8m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '21' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 9m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '22' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 10m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '23' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 11m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '24' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 12m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '25' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 1m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '26' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 2m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '27' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 3m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '28' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 4m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '29' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 5m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '30' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 6m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '31' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 7m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '32' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 8m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '33' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 9m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '34' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 10m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '35' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 11m"
       ,round(count(distinct case when to_date(구매월,'yyyymm')>=to_date(최초구매월,'yyyymm') + (interval '36' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 12m"
from order_record
where 최초구매월 like '2015%'
group by 최초구매월
