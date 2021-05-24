use G2T01;

#Q1
Select a.year, a.Month, ifnull(a.Noofborroweditems,0) as "No.of borrowed items" , 
ifnull(b.NoofPhysicalitemsacquired,0) as "No.of Physical items acquired", 
ifnull(c.NoofElectronicitemsacquired,0) as "No.of Electronic items acquired", 
ifnull(d.Numofitemscommentedupon,0) as "No.of items commented upon"
from
(select Year, Month, count(*) as Noofborroweditems
from
(select extract(year from b.borrowed_datetime) as Year, extract(month from b.borrowed_datetime) as Month, b.ISBN
from borrow b
where extract(year from b.borrowed_datetime)= "2020"
group by Year,Month, b.ISBN
Order by Month desc) as t1
group by Year, Month )as a left join
(select Year, Month, count(*) as NoofPhysicalitemsacquired
from
(select extract(year from c.acquired_date) as Year, extract(month from c.acquired_date) as Month, c.ISBN
from copy c, item i
where c.ISBN =i.ISBN  and i.format_type= "P" and (extract(year from c.acquired_date)) ="2020"
group by Year,Month, c.ISBN
Order by Month desc )as t2
group by Year, Month )as b on (a.Month=b.Month)
Left join
(select Year, Month, count(*) as NoofElectronicitemsacquired
from(
select extract(year from c.acquired_date) as Year, extract(month from c.acquired_date) as Month, c.ISBN
from copy c, item i
where c.ISBN =i.ISBN  and i.format_type= "E" and (extract(year from c.acquired_date)) ="2020"
group by Year,Month, c.ISBN
Order by Month desc)as t3
group by Year, Month) as c on (a.Month=c.Month)
Left Join
(select Year, Month, count(*) as Numofitemscommentedupon
from(
select extract(year from c.Date_time) as Year, extract(month from c.Date_time) as Month, c.electronic_item
from comment c
where (extract(year from c.Date_time)) ="2020"
group by Year,Month, c.electronic_item
Order by Month desc) as t4
group by Year, Month) as d on (a.Month=d.Month)
Union 
Select a.year, a.Month, ifnull(d.Noofborroweditems,0) as Noofborroweditems , ifnull(b.NoofPhysicalitemsacquired,0) as NoofPhysicalitemsacquired,ifnull(c.NoofElectronicitemsacquired,0) as NoofElectronicitemsacquired, ifnull(a.Numofitemscommentedupon,0) as Numofitemscommentedupon
from
(select Year, Month, count(*) as Numofitemscommentedupon
from(
select extract(year from c.Date_time) as Year, extract(month from c.Date_time) as Month, c.electronic_item
from comment c
where (extract(year from c.Date_time)) ="2020"
group by Year,Month, c.electronic_item
Order by Month desc) as t4
group by Year, Month) as a left join
(select Year, Month, count(*) as NoofPhysicalitemsacquired
from
(select extract(year from c.acquired_date) as Year, extract(month from c.acquired_date) as Month, c.ISBN
from copy c, item i
where c.ISBN =i.ISBN  and i.format_type= "P" and (extract(year from c.acquired_date)) ="2020"
group by Year,Month, c.ISBN
Order by Month desc )as t2
group by Year, Month )as b on (a.Month=b.Month)
left join
(select Year, Month, count(*) as NoofElectronicitemsacquired
from(
select extract(year from c.acquired_date) as Year, extract(month from c.acquired_date) as Month, c.ISBN
from copy c, item i
where c.ISBN =i.ISBN  and i.format_type= "E" and (extract(year from c.acquired_date)) ="2020"
group by Year,Month, c.ISBN
Order by Month desc)as t3
group by Year, Month) as c on (a.Month=c.Month)
left Join
(select Year, Month, count(*) as Noofborroweditems
from
(select extract(year from b.borrowed_datetime) as Year, extract(month from b.borrowed_datetime) as Month, b.ISBN
from borrow b
where extract(year from b.borrowed_datetime)= "2020"
group by Year,Month, b.ISBN
Order by Month desc) as t1
group by Year, Month ) as d on (a.Month=d.Month)
order by Month desc;

#Q2 Membership statistics
select usertype as "User Type", uid as 'Total No. of Users', fees as 'Total Annual Fees Collected'
from (
select is_admin, count(user_id) as uid, if(is_admin = 'Y', 'Admin','') as usertype, round(sum(annual_fee*(1-admin_discount/100)),2) as fees
from user u
left outer join
membership m
on u.member_type = m.member_type
where is_admin = 'Y' #get a single row for admin with annual fee computed and no. of admin
group by is_admin
union #"stack" up the rows with the next two for faculty and student
select is_faculty, count(user_id) as uid, if(is_faculty = 'Y', 'Faculty','') as usertype, sum(annual_fee)
from user u
left outer join
membership m
on u.member_type = m.member_type
where is_faculty = 'Y'
group by is_faculty
union
select is_student, count(user_id) as uid, if(is_student = 'Y' and is_admin = 'N', 'Student','') as usertype, sum(annual_fee)
from user u #make sure that student only (non admin)
left outer join
membership m
on u.member_type = m.member_type
where is_student= 'Y' and is_admin = 'N'
group by is_student) as temp4;

#Q3 Publisher Statistics

set @publishername = 'Vintage publishing';

select i.isbn, title,
count(distinct author) as 'No. of authors',
count(distinct temp6.copy_id) as 'No. of copies',
count(distinct borrowed_datetime) as 'No. of times borrowed'
from item i
left outer join
(select * #get no. of authors
from author a) as temp5
on i.isbn = temp5.isbn
left outer join
(select * #get no. of copies
from copy c) as temp6
on i.isbn = temp6.isbn
left outer join
(select * #get no. of times borrowed based on no. of borrowed dates
from borrow b) as temp7
on i.isbn = temp7.isbn
where publisher_name = @publishername
group by i.isbn
order by count(*) desc;

#Q4 Due Items

set @startdate = '2014-03-01';
set @enddate = '2014-03-31';

select temp9.title, copy_id as 'Copy ID',temp8.user_name, temp8.Usertype, date(date_add(borrowed_datetime, #compute due date
interval temp11.loan_period day)) as duedate, temp10.type as "Item type"
from borrow b
left outer join
(select user_id, user_name, if(is_faculty = 'Y','Faculty', if(is_student = 'Y' and is_admin = 'N', 'Student',
if(is_student = 'Y' and is_admin = 'Y','Student Admin','Admin'))) as Usertype
from user) as temp8 #to get type of user
on b.user_id = temp8.user_id
left outer join
(select isbn,title #get title
from item) as temp9
on b.isbn = temp9.isbn
left outer join 
(select isbn,type #get item type
from physical_item) as temp10
on b.isbn = temp10.isbn 
left outer join
(select user_id, u.member_type, loan_period #get loan period based on member type
from user u, membership m
where u.member_type = m.member_type
) as temp11
on b.user_id = temp11.user_id
where date_add(borrowed_datetime, interval temp11.loan_period day) between @startdate and @enddate
order by date_add(borrowed_datetime, interval temp11.loan_period day) asc;

#Q5. Trigger
delimiter $$
CREATE TRIGGER before_borrow_check_valid 
   BEFORE INSERT ON borrow FOR EACH ROW
   BEGIN   	
		if (new.isbn, new.copy_id) in (select isbn, copy_id from borrow
			where returned_datetime is null) then #null means have not been returned - not available for borrowing
            signal sqlstate '45000' set message_text = 'Trigger 
            Error: Copy not available for borrowing';
		end if;
        if new.user_id in (select t1.user_id from
			(select u.user_id, item_limit from user u, membership m
			where u.member_type = m.member_type) as t1,
			(select user_id, count(*) as 'noofborrowitems' from borrow
			where returned_datetime is null
			group by user_id) as t2
			where t1.user_id = t2.user_id and item_limit - noofborrowitems = 0) then #item limit minus currently borrowed no. of items
            signal sqlstate '45000' set message_text = 'Trigger 
            Error: User has reached borrowing limit';
		end if;
        
   END$$
delimiter ;

#Q6 Stored Procedure
delimiter $$
create procedure q6(in x int)
begin
	select * from (with star as (select avg(stars) as average_rating, electronic_item as isbn  from comment_rating group by electronic_item),
	counting as (select count(*) as comment_count, electronic_item as isbn  from comment group by electronic_item),
	info as ( select item.title as title, electronic_item.isbn as isbn from electronic_item left join item on electronic_item.isbn = item.isbn)
	select dense_rank() over (order by a.comment_count desc) as rank_, a.isbn, b.title, c.average_rating, a.comment_count
	from counting a
	join info b on a.isbn = b.isbn
	join star c on a.isbn = c.isbn) as result
    where rank_<x
    order by result.rank_;
end $$

call Q6 (10);