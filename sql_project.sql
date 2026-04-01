create database Project;
use  Project;

/* Primary Keys*/
alter table dim_date modify column date date primary key;

alter table dim_hotels modify column property_id int primary key;

alter table dim_rooms modify column room_id varchar(20) primary key;

/* Foreign Keys*/

alter table fact_bookings add foreign key(check_in_date) references dim_date(date);

alter table fact_aggregated_bookings add foreign key(check_in_date) references dim_date(date);

alter table fact_bookings add foreign key(property_id ) references dim_hotels(property_id );
							
alter table fact_aggregated_bookings add foreign key(property_id ) references dim_hotels(property_id );

alter table fact_bookings modify column room_category varchar(20);

alter table fact_aggregated_bookings modify column room_category varchar(20);

alter table fact_bookings add foreign key(room_category) references dim_rooms(room_id );
							
alter table fact_aggregated_bookings add foreign key(room_category) references dim_rooms(room_id );

/*Changing the datatype */

alter table dim_date modify column date date;

alter table fact_aggregated_bookings modify column check_in_date date;

alter table fact_bookings modify column booking_date date,
						  modify column check_in_date date,
                          modify column ratings_given int;

/*Data cleaning*/

UPDATE fact_bookings
SET ratings_given = NULL
WHERE ratings_given = '';



/*Total Revenue , Total Revenue Realized , Total bookings , cancellation_rate , Avg_ratings , Occupancy */
SELECT  
    Concat(round(sum(revenue_generated)/10000000,2),"M") AS Total_Revenue,
    Concat(round(sum(revenue_realized)/10000000,2),"M") AS Total_Revenue_Realized,
    Concat(round(count(booking_id)/1000,2),"K") AS Total_bookings,
    concat(round(count(case 
		when booking_status = 'Cancelled' then booking_id end)/ count(booking_id) *100,2),"%")
	 as cancellation_rate,
     round(sum(ratings_given) / count(ratings_given),2) as Avg_ratings,
    (
        SELECT concat(round(sum(successful_bookings/capacity *100 /10000),2),"%")
        FROM fact_aggregated_bookings
    ) AS Occupancy
FROM fact_bookings;

/* Daytype(weekend and weekday) wise Revenue and Total bookings*/
select dd.day_type, 
Concat(round(sum(revenue_realized)/10000000,2),"M") AS Total_Revenue_Realized,
Concat(round(count(booking_id)/1000,2),"K") AS Total_bookings
from dim_date dd
join fact_bookings fb
on dd.date = fb.check_in_date
group by dd.day_type;

/* City and Property Wise Total_revenue Realized*/
select  city,
		property_name,
		Concat(round(sum(revenue_realized)/10000000,2),"M") AS Total_Revenue_Realized
from dim_hotels dh
join fact_bookings fb
on dh.property_id = fb.property_id
group by dh.city,dh.property_name
order by city ;

/*Room_class wise Total_revenue_Ralized*/
select room_class,
		Concat(round(sum(revenue_realized)/10000000,2),"M") AS Total_Revenue_Realized
from dim_rooms dr
join fact_bookings fb
on dr.room_id = fb.room_category
group by room_class
order by Total_Revenue_Realized desc;

/*Cancelled Percent,Checked out percent and No show percentage from Total Booking Percentage*/
select concat(round(count(booking_status)/count(booking_status)*100,2),"%") as Total_Percent,
  concat(round(count(case
        when booking_status = "Cancelled" then 1 end)/count(*)*100,2),"%") as Cancelled_Percent,
  concat(round(count(case
        when booking_status = "Checked out" then 1 end)/count(*)*100,2),"%") as `Checked out Percent`,
  concat(round(count(case
        when booking_status = "No show" then 1 end)/count(*)*100,2),"%") as `No show percent`
from fact_bookings;

/*Booking Platform ,Room Class wise Booking Percentage*/
select dr.room_class,
    concat(round(sum(case when booking_platform = 'makeyourtrip' then 1 else 0 end) 
          / count(*) * 100, 2),"%") as makeyourtrip_pct,
    concat(round(sum(case when booking_platform = 'tripster' then 1 else 0 end) 
          / count(*) * 100, 2),"%") as tripster_pct,
    concat(round(sum(case when booking_platform = 'logtrip' then 1 else 0 end) 
          / count(*) * 100, 2),"%") as logtrip_pct,
    concat(round(sum(case when booking_platform = 'journey' then 1 else 0 end) 
          / count(*) * 100, 2),"%") as journey_pct,
    concat(round(sum(case when booking_platform = 'direct online' then 1 else 0 end) 
          / count(*) * 100, 2),"%") as direct_online_pct,
    concat(round(sum(case when booking_platform = 'direct offline' then 1 else 0 end) 
          / count(*) * 100, 2),"%") as direct_offline_pct,
    concat(round(sum(case when booking_platform = 'others' then 1 else 0 end) 
          / count(*) * 100, 2),"%") as others_pct
from fact_bookings fb
join dim_rooms dr
  on fb.room_category = dr.room_id
group by dr.room_class;

/* week_no wise Total Revenue,Total Booking and Occupancy Precentage*/
select week_no,
		Concat(round(sum(revenue_realized)/10000000,2),"M") AS Total_Revenue_Realized,
		Concat(round(count(booking_id)/1000,2),"K") AS Total_bookings
from dim_date dd
join fact_bookings fb
on dd.date = fb.check_in_date
group by week_no;

select week_no,
		concat(round(sum(successful_bookings)/sum(capacity) *100 ,2),"%") as occupancy
from dim_date dd
join fact_aggregated_bookings fab
on dd.date = fab.check_in_date
group by week_no;

alter table dim_date change column  `week no` week_no text;
/*Trend analysis (Monthly Revenue and Total Bookings)*/
select monthname(check_in_date) as Month,
	   Concat(round(sum(revenue_realized)/10000000,2),"M") AS Total_Revenue_Realized,
       Concat(round(count(booking_id)/1000,2),"K") AS Total_bookings
from fact_bookings
group by Month
order by Total_Revenue_Realized desc,Total_bookings desc ;





                         