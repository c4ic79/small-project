
--�����ͼ�
https://www.kaggle.com/datasets/juhi1994/superstore

--�������� �ֹ������� ����
select min(order_date) ,max(order_date)
from super

--� ���ÿ��� �ֹ��� ����������?
select city , count(order_id) as "���ú� �ֹ���"
from super
group by city
order by count(order_id) desc



--���� ���� �ֹ��� ���� ����� �ֹ�������??

select customer_id ,count(customer_id)
from super
group by customer_id
order by count(customer_id) desc


--�ֹ��ϸ� ��������� ���� �ڿ� �߼��ұ�??
select round(avg(ship_date-order_date),2)
from super



--���� ���� �м�
select to_char(order_date,'yyyymm') as order_month ,round(sum(sales) ,2) as sale
from super
group by to_char(order_date,'yyyymm')
order by order_month asc


--�б⺰ ���� �м�
select to_char(order_date,'yyyy') year,
round(sum(case when to_char(order_date,'q')=1 then sales end)) "1�б�",
round(sum(case when to_char(order_date,'q')=1 then sales end) / sum(sales),2) "1�б� ���� ����",
round(sum(case when to_char(order_date,'q')=2 then sales end)) "2�б�",
round(sum(case when to_char(order_date,'q')=2 then sales end) / sum(sales),2) "2�б� ���� ����",
round(sum(case when to_char(order_date,'q')=3 then sales end)) "3�б�",
round(sum(case when to_char(order_date,'q')=3 then sales end) / sum(sales),2) "3�б� ���� ����",
round(sum(case when to_char(order_date,'q')=4 then sales end)) "4�б�",
round(sum(case when to_char(order_date,'q')=4 then sales end) / sum(sales),2) "4�б� ���� ����"
from super
group by to_char(order_date,'yyyy')
order by 1;


--���Ϻ� ���� �м�
select to_char(order_date,'yyyy') year,
round(sum(case when to_char(order_date,'day')='������' then sales end)) "������",
round(sum(case when to_char(order_date,'day')='ȭ����' then sales end)) "ȭ����",
round(sum(case when to_char(order_date,'day')='������' then sales end)) "������",
round(sum(case when to_char(order_date,'day')='�����' then sales end)) "�����",
round(sum(case when to_char(order_date,'day')='�ݿ���' then sales end)) "�ݿ���",
round(sum(case when to_char(order_date,'day')='�����' then sales end)) "�����",
round(sum(case when to_char(order_date,'day')='�Ͽ���' then sales end)) "�Ͽ���"

from super
group by to_char(order_date,'yyyy')
order by 1;

--���Ϻ� ���� ����
select to_char(order_date,'yyyy') year,
round(sum(case when to_char(order_date,'day')='������' then sales end)/ sum(sales),2) "������",
round(sum(case when to_char(order_date,'day')='ȭ����' then sales end)/ sum(sales),2) "ȭ����",
round(sum(case when to_char(order_date,'day')='������' then sales end)/ sum(sales),2) "������",
round(sum(case when to_char(order_date,'day')='�����' then sales end)/ sum(sales),2) "�����",
round(sum(case when to_char(order_date,'day')='�ݿ���' then sales end)/ sum(sales),2) "�ݿ���",
round(sum(case when to_char(order_date,'day')='�����' then sales end)/ sum(sales),2) "�����",
round(sum(case when to_char(order_date,'day')='�Ͽ���' then sales end)/ sum(sales),2) "�Ͽ���"

from super
group by to_char(order_date,'yyyy')
order by 1;


--����ī�װ��� ���� �м�
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

storage�� tables�� ��պ��� ���� ������ ��������� storage�� ���� ������ ����
tables�� ������ ���� �ܰ��� ���� ������ ���� ���� Top 5�� ����ٰ� �Ǵ��Ͽ���.

furnishings�� paper�� ��պ��� ū ������ ����ǰ� ���� �������� �������� �����ܰ��� ���� �ʾƼ� ū ������ �ø��� ���� ������ �Ǵ��Ͽ���.




--ù �������� ���ϱ�

with first_order_date  as
(
select  customer_id,min(order_date) as "ù��������"
from super 
group by customer_id
),
order_record as
(
select s.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "���ſ�",
       to_char(s.order_date,'yyyymmdd') as "��������",
       f.ù��������,
       to_char(f.ù��������, 'yyyymm') AS "ù���ſ�",
       case when to_char(f.ù��������)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
left join first_order_date f on s.customer_id=f.customer_id 
)

select * 
from order_record

--Ŭ���� ���ټ�
with first_order_date  as
(
select distinct customer_id, min(order_date) as "���ʱ�������" --���Ա���̳� �ٸ� �αװ� ���� ������ ������ ���ʷ� ������ ������ ��¥�� ���� 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "���ſ�",
       to_char(s.order_date,'yyyymmdd') as "��������",
       f.���ʱ������� as "���ʱ�������",
       to_char(f.���ʱ�������, 'yyyymm') AS "���ʱ��ſ�",
       case when to_char(f.���ʱ�������)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select ���ʱ��ſ�
       ,count(distinct case when ���ſ�=���ʱ��ſ� then customer_id end) "0����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '1' month) then customer_id end) "1����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '2' month) then customer_id end) "2����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '3' month) then customer_id end) "3����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '4' month) then customer_id end) "4����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '5' month) then customer_id end) "5����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '6' month) then customer_id end) "6����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '7' month) then customer_id end) "7����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '8' month) then customer_id end) "8����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '9' month) then customer_id end) "9����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '10' month) then customer_id end) "10����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '11' month) then customer_id end) "11����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '12' month) then customer_id end) "12����"

from order_record
group by ���ʱ��ſ�
 


--Ŭ���ĸ��ټ� ���� (2014����� 1�Ⱓ)
with first_order_date  as
(
select distinct customer_id, min(order_date) as "���ʱ�������" --���Ա���̳� �ٸ� �αװ� ���� ������ ������ ���ʷ� ������ ������ ��¥�� ���� 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "���ſ�",
       to_char(s.order_date,'yyyymmdd') as "��������",
       f.���ʱ������� as "���ʱ�������",
       to_char(f.���ʱ�������, 'yyyymm') AS "���ʱ��ſ�",
       case when to_char(f.���ʱ�������)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select ���ʱ��ſ�
       ,count(distinct case when ���ſ�=���ʱ��ſ� then customer_id end) "month0"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '1' month) then customer_id end)/ count(distinct customer_id),2) "pct_1"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '2' month) then customer_id end)/ count(distinct customer_id),2) "pct_2"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '3' month) then customer_id end)/ count(distinct customer_id),2) "pct_3"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '4' month) then customer_id end)/ count(distinct customer_id),2) "pct_4"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '5' month) then customer_id end)/ count(distinct customer_id),2) "pct_5"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '6' month) then customer_id end)/ count(distinct customer_id),2) "pct_6"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '7' month) then customer_id end)/ count(distinct customer_id),2) "pct_7"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '8' month) then customer_id end)/ count(distinct customer_id),2) "pct_8"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '9' month) then customer_id end)/ count(distinct customer_id),2) "pct_9"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '10' month) then customer_id end)/ count(distinct customer_id),2) "pct_10"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '11' month) then customer_id end)/ count(distinct customer_id),2) "pct_11"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '12' month) then customer_id end)/ count(distinct customer_id),2) "pct_12"
      
from order_record
where ���ʱ��ſ� like '2014%'
group by ���ʱ��ſ�



--2014�� 1�� ������ ������ (2015)
with first_order_date  as
(
select distinct customer_id, min(order_date) as "���ʱ�������" --���Ա���̳� �ٸ� �αװ� ���� ������ ������ ���ʷ� ������ ������ ��¥�� ���� 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "���ſ�",
       to_char(s.order_date,'yyyymmdd') as "��������",
       f.���ʱ������� as "���ʱ�������",
       to_char(f.���ʱ�������, 'yyyymm') AS "���ʱ��ſ�",
       case when to_char(f.���ʱ�������)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select ���ʱ��ſ�
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '13' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 1m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '14' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 2m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '15' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 3m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '16' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 4m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '17' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 5m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '18' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 6m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '19' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 7m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '20' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 8m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '21' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 9m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '22' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 10m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '23' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 11m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '24' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 12m"
       
from order_record
where ���ʱ��ſ� like '2014%'
group by ���ʱ��ſ�





--2014�� 2�� ������ ������ (2016)
with first_order_date  as
(
select distinct customer_id, min(order_date) as "���ʱ�������" --���Ա���̳� �ٸ� �αװ� ���� ������ ������ ���ʷ� ������ ������ ��¥�� ���� 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "���ſ�",
       to_char(s.order_date,'yyyymmdd') as "��������",
       f.���ʱ������� as "���ʱ�������",
       to_char(f.���ʱ�������, 'yyyymm') AS "���ʱ��ſ�",
       case when to_char(f.���ʱ�������)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select ���ʱ��ſ�
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '25' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 1m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '26' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 2m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '27' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 3m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '28' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 4m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '29' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 5m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '30' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 6m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '31' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 7m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '32' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 8m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '33' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 9m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '34' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 10m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '35' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 11m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '36' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 12m"
       
from order_record
where ���ʱ��ſ� like '2014%'
group by ���ʱ��ſ�



--2014�� 3�� ������ ������ (2017)
with first_order_date  as
(
select distinct customer_id, min(order_date) as "���ʱ�������" --���Ա���̳� �ٸ� �αװ� ���� ������ ������ ���ʷ� ������ ������ ��¥�� ���� 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "���ſ�",
       to_char(s.order_date,'yyyymmdd') as "��������",
       f.���ʱ������� as "���ʱ�������",
       to_char(f.���ʱ�������, 'yyyymm') AS "���ʱ��ſ�",
       case when to_char(f.���ʱ�������)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select ���ʱ��ſ�
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '37' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 1m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '38' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 2m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '39' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 3m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '40' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 4m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '41' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 5m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '42' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 6m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '43' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 7m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '44' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 8m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '45' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 9m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '46' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 10m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '47' month) then customer_id end)/ count(distinct customer_id),2) "pct_3y 11m"
from order_record
where ���ʱ��ſ� like '2014%'
group by ���ʱ��ſ�




--Ŭ���ĸ��ټ� ���� (2015����� 1�Ⱓ)
with first_order_date  as
(
select distinct customer_id, min(order_date) as "���ʱ�������" --���Ա���̳� �ٸ� �αװ� ���� ������ ������ ���ʷ� ������ ������ ��¥�� ���� 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "���ſ�",
       to_char(s.order_date,'yyyymmdd') as "��������",
       f.���ʱ������� as "���ʱ�������",
       to_char(f.���ʱ�������, 'yyyymm') AS "���ʱ��ſ�",
       case when to_char(f.���ʱ�������)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select ���ʱ��ſ�
       ,count(distinct case when ���ſ�=���ʱ��ſ� then customer_id end) "month0"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '1' month) then customer_id end)/ count(distinct customer_id),2) "pct_1"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '2' month) then customer_id end)/ count(distinct customer_id),2) "pct_2"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '3' month) then customer_id end)/ count(distinct customer_id),2) "pct_3"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '4' month) then customer_id end)/ count(distinct customer_id),2) "pct_4"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '5' month) then customer_id end)/ count(distinct customer_id),2) "pct_5"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '6' month) then customer_id end)/ count(distinct customer_id),2) "pct_6"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '7' month) then customer_id end)/ count(distinct customer_id),2) "pct_7"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '8' month) then customer_id end)/ count(distinct customer_id),2) "pct_8"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '9' month) then customer_id end)/ count(distinct customer_id),2) "pct_9"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '10' month) then customer_id end)/ count(distinct customer_id),2) "pct_10"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '11' month) then customer_id end)/ count(distinct customer_id),2) "pct_11"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '12' month) then customer_id end)/ count(distinct customer_id),2) "pct_12"
      
from order_record
where ���ʱ��ſ� like '2015%'
group by ���ʱ��ſ�



--2015�� 1�� ������ ������ (2016)
with first_order_date  as
(
select distinct customer_id, min(order_date) as "���ʱ�������" --���Ա���̳� �ٸ� �αװ� ���� ������ ������ ���ʷ� ������ ������ ��¥�� ���� 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "���ſ�",
       to_char(s.order_date,'yyyymmdd') as "��������",
       f.���ʱ������� as "���ʱ�������",
       to_char(f.���ʱ�������, 'yyyymm') AS "���ʱ��ſ�",
       case when to_char(f.���ʱ�������)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select ���ʱ��ſ�
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '13' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 1m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '14' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 2m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '15' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 3m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '16' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 4m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '17' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 5m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '18' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 6m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '19' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 7m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '20' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 8m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '21' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 9m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '22' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 10m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '23' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 11m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '24' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 12m"
       
from order_record
where ���ʱ��ſ� like '2015%'
group by ���ʱ��ſ�


--2015�� 2�� ������ ������ (2017)
with first_order_date  as
(
select distinct customer_id, min(order_date) as "���ʱ�������" --���Ա���̳� �ٸ� �αװ� ���� ������ ������ ���ʷ� ������ ������ ��¥�� ���� 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "���ſ�",
       to_char(s.order_date,'yyyymmdd') as "��������",
       f.���ʱ������� as "���ʱ�������",
       to_char(f.���ʱ�������, 'yyyymm') AS "���ʱ��ſ�",
       case when to_char(f.���ʱ�������)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select ���ʱ��ſ�
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '25' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 1m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '26' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 2m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '27' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 3m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '28' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 4m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '29' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 5m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '30' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 6m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '31' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 7m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '32' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 8m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '33' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 9m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '34' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 10m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '35' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 11m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '36' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 12m"
       
from order_record
where ���ʱ��ſ� like '2015%'
group by ���ʱ��ſ�


       
       
--Ŭ���ĸ��ټ� ���� (2016����� 1�Ⱓ)
with first_order_date  as
(
select distinct customer_id, min(order_date) as "���ʱ�������" --���Ա���̳� �ٸ� �αװ� ���� ������ ������ ���ʷ� ������ ������ ��¥�� ���� 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "���ſ�",
       to_char(s.order_date,'yyyymmdd') as "��������",
       f.���ʱ������� as "���ʱ�������",
       to_char(f.���ʱ�������, 'yyyymm') AS "���ʱ��ſ�",
       case when to_char(f.���ʱ�������)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select ���ʱ��ſ�
       ,count(distinct case when ���ſ�=���ʱ��ſ� then customer_id end) "month0"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '1' month) then customer_id end)/ count(distinct customer_id),2) "pct_1"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '2' month) then customer_id end)/ count(distinct customer_id),2) "pct_2"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '3' month) then customer_id end)/ count(distinct customer_id),2) "pct_3"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '4' month) then customer_id end)/ count(distinct customer_id),2) "pct_4"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '5' month) then customer_id end)/ count(distinct customer_id),2) "pct_5"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '6' month) then customer_id end)/ count(distinct customer_id),2) "pct_6"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '7' month) then customer_id end)/ count(distinct customer_id),2) "pct_7"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '8' month) then customer_id end)/ count(distinct customer_id),2) "pct_8"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '9' month) then customer_id end)/ count(distinct customer_id),2) "pct_9"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '10' month) then customer_id end)/ count(distinct customer_id),2) "pct_10"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '11' month) then customer_id end)/ count(distinct customer_id),2) "pct_11"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '12' month) then customer_id end)/ count(distinct customer_id),2) "pct_12"
      
from order_record
where ���ʱ��ſ� like '2016%'
group by ���ʱ��ſ�

       
       
--2016�� 1�� ������ ������ (2017)
with first_order_date  as
(
select distinct customer_id, min(order_date) as "���ʱ�������" --���Ա���̳� �ٸ� �αװ� ���� ������ ������ ���ʷ� ������ ������ ��¥�� ���� 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "���ſ�",
       to_char(s.order_date,'yyyymmdd') as "��������",
       f.���ʱ������� as "���ʱ�������",
       to_char(f.���ʱ�������, 'yyyymm') AS "���ʱ��ſ�",
       case when to_char(f.���ʱ�������)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select ���ʱ��ſ�
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '13' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 1m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '14' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 2m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '15' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 3m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '16' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 4m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '17' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 5m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '18' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 6m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '19' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 7m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '20' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 8m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '21' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 9m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '22' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 10m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '23' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 11m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '24' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 12m"
       
from order_record
where ���ʱ��ſ� like '2016%'
group by ���ʱ��ſ�

       


--Ŭ���ĸ��ټ� ���� (2017����� 1�Ⱓ)
with first_order_date  as
(
select distinct customer_id, min(order_date) as "���ʱ�������" --���Ա���̳� �ٸ� �αװ� ���� ������ ������ ���ʷ� ������ ������ ��¥�� ���� 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "���ſ�",
       to_char(s.order_date,'yyyymmdd') as "��������",
       f.���ʱ������� as "���ʱ�������",
       to_char(f.���ʱ�������, 'yyyymm') AS "���ʱ��ſ�",
       case when to_char(f.���ʱ�������)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select ���ʱ��ſ�
       ,count(distinct case when ���ſ�=���ʱ��ſ� then customer_id end) "month0"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '1' month) then customer_id end)/ count(distinct customer_id),2) "pct_1"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '2' month) then customer_id end)/ count(distinct customer_id),2) "pct_2"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '3' month) then customer_id end)/ count(distinct customer_id),2) "pct_3"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '4' month) then customer_id end)/ count(distinct customer_id),2) "pct_4"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '5' month) then customer_id end)/ count(distinct customer_id),2) "pct_5"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '6' month) then customer_id end)/ count(distinct customer_id),2) "pct_6"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '7' month) then customer_id end)/ count(distinct customer_id),2) "pct_7"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '8' month) then customer_id end)/ count(distinct customer_id),2) "pct_8"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '9' month) then customer_id end)/ count(distinct customer_id),2) "pct_9"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '10' month) then customer_id end)/ count(distinct customer_id),2) "pct_10"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '11' month) then customer_id end)/ count(distinct customer_id),2) "pct_11"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')=to_date(���ʱ��ſ�,'yyyymm') + (interval '12' month) then customer_id end)/ count(distinct customer_id),2) "pct_12"
      
from order_record
where ���ʱ��ſ� like '2017%'
group by ���ʱ��ſ�

     


--������ ���

with first_order_date  as
(
select distinct customer_id, min(order_date) as "���ʱ�������" --���Ա���̳� �ٸ� �αװ� ���� ������ ������ ���ʷ� ������ ������ ��¥�� ���� 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       s.discount,
       to_char(s.order_date,'yyyymm') as "���ſ�",
       to_char(s.order_date,'yyyymmdd') as "��������",
       f.���ʱ������� as "���ʱ�������",
       to_char(f.���ʱ�������, 'yyyymm') AS "���ʱ��ſ�",
       case when to_char(f.���ʱ�������)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 
)

select ���ſ�,����Ƚ��, round(avg_discount*100,2) as "�������",round(avg_discount*100 / sum(avg_discount) over(),2) as "���������"
from(
  select ���ſ�,count(distinct customer_id) as "����Ƚ��", avg(discount) as avg_discount
  from order_record
  where ���ʱ��ſ� = 201509
  group by ���ſ�)  

order by ���ſ�



�Ѹ� ���ټ�: ��Ż�� ������ ����
                    
--�Ѹ� ���ټ�
with first_order_date  as
(
select distinct customer_id, min(order_date) as "���ʱ�������" --���Ա���̳� �ٸ� �αװ� ���� ������ ������ ���ʷ� ������ ������ ��¥�� ���� 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "���ſ�",
       to_char(s.order_date,'yyyymmdd') as "��������",
       f.���ʱ������� as "���ʱ�������",
       to_char(f.���ʱ�������, 'yyyymm') AS "���ʱ��ſ�",
       case when to_char(f.���ʱ�������)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select ���ʱ��ſ�
       ,count(distinct case when ���ſ�=���ʱ��ſ� then customer_id end) "0����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '1' month) then customer_id end) "1����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '2' month) then customer_id end) "2����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '3' month) then customer_id end) "3����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '4' month) then customer_id end) "4����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '5' month) then customer_id end) "5����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '6' month) then customer_id end) "6����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '7' month) then customer_id end) "7����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '8' month) then customer_id end) "8����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '9' month) then customer_id end) "9����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '10' month) then customer_id end) "10����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '11' month) then customer_id end) "11����"
       ,count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '12' month) then customer_id end) "12����"

from order_record
group by ���ʱ��ſ�
 




--2015����� 2017������� �Ѹ����ټ� ����
with first_order_date  as
(
select distinct customer_id, min(order_date) as "���ʱ�������" --���Ա���̳� �ٸ� �αװ� ���� ������ ������ ���ʷ� ������ ������ ��¥�� ���� 
from super 
group by customer_id
),
order_record as
(
select f.customer_id,
       s.sub_category,
       round(s.sales) as sales,
       to_char(s.order_date,'yyyymm') as "���ſ�",
       to_char(s.order_date,'yyyymmdd') as "��������",
       f.���ʱ������� as "���ʱ�������",
       to_char(f.���ʱ�������, 'yyyymm') AS "���ʱ��ſ�",
       case when to_char(f.���ʱ�������)!=to_char(s.order_date) then 1 else 0 end as reorder
from super s 
inner join first_order_date f on s.customer_id=f.customer_id 

)

select ���ʱ��ſ�
       ,count(distinct case when ���ſ�=���ʱ��ſ� then customer_id end) "month0"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '1' month) then customer_id end)/ count(distinct customer_id),2)  "pct_1"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '2' month) then customer_id end)/ count(distinct customer_id),2) "pct_2"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '3' month) then customer_id end)/ count(distinct customer_id),2) "pct_3"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '4' month) then customer_id end)/ count(distinct customer_id),2) "pct_4"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '5' month) then customer_id end)/ count(distinct customer_id),2) "pct_5"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '6' month) then customer_id end)/ count(distinct customer_id),2) "pct_6"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '7' month) then customer_id end)/ count(distinct customer_id),2) "pct_7"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '8' month) then customer_id end)/ count(distinct customer_id),2) "pct_8"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '9' month) then customer_id end)/ count(distinct customer_id),2) "pct_9"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '10' month) then customer_id end)/ count(distinct customer_id),2) "pct_10"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '11' month) then customer_id end)/ count(distinct customer_id),2) "pct_11"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '12' month) then customer_id end)/ count(distinct customer_id),2) "pct_12"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '13' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 1m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '14' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 2m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '15' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 3m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '16' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 4m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '17' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 5m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '18' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 6m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '19' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 7m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '20' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 8m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '21' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 9m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '22' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 10m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '23' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 11m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '24' month) then customer_id end)/ count(distinct customer_id),2) "pct_1y 12m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '25' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 1m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '26' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 2m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '27' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 3m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '28' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 4m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '29' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 5m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '30' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 6m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '31' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 7m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '32' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 8m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '33' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 9m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '34' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 10m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '35' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 11m"
       ,round(count(distinct case when to_date(���ſ�,'yyyymm')>=to_date(���ʱ��ſ�,'yyyymm') + (interval '36' month) then customer_id end)/ count(distinct customer_id),2) "pct_2y 12m"
from order_record
where ���ʱ��ſ� like '2015%'
group by ���ʱ��ſ�
