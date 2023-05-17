--Analyze how much time is spent per ride
--Based on date and time factors such as day of week and time of day
--Analysis conclusion: The longest trips are taken during the weekend.
select d.DayOfWeek, avg(t.TripDurationMinutes) as AvgTimeSpent
from factTrip t
inner join dimDate d on d.DateId = t.StartDateId
group by d.DayOfWeek
order by AvgTimeSpent desc;

--Analysis conclusion: At night and at noon are the times of day when trips are the longest
select case when HourOfDay between 6 and 9 then 'Morning'
            when HourOfDay between 10 and 11 then 'Day'
            when HourOfDay between 12 and 13 then 'Noon'
            when HourOfDay between 14 and 17 then 'Afternoon'
            when HourOfDay between 18 and 20 then 'Evening'
            when HourOfDay between 21 and 23 
                OR HourOfDay between 0 and 5 then 'Night'
            else NULL
        end as TimeOfDay, 
        avg(t.TripDurationMinutes) as AvgTimeSpent
from factTrip t
group by 
    case when HourOfDay between 6 and 9 then 'Morning'
            when HourOfDay between 10 and 11 then 'Day'
            when HourOfDay between 12 and 13 then 'Noon'
            when HourOfDay between 14 and 17 then 'Afternoon'
            when HourOfDay between 18 and 20 then 'Evening'
            when HourOfDay between 21 and 23 
                OR HourOfDay between 0 and 5 then 'Night'
            else NULL
        end
order by AvgTimeSpent desc;

--Based on which station is the starting and / or ending station
--Analysis conclusion: "Throop St & 52nd St" is the top starting station based on avg number of minutes per trip
select top 5 with TIES s.StationName as StartStationName, avg(t.TripDurationMinutes) as AvgTimeSpent
from factTrip t
inner join dimStation s on s.StationId = t.StartStationId
group by s.StationName
order by AvgTimeSpent desc;

--Analysis conclusion: "Base - 2132 W Hubbard Warehouse" is the top ending station based on avg number of minutes per trip
select top 5 with TIES s.StationName as EndStationName, avg(t.TripDurationMinutes) as AvgTimeSpent
from factTrip t
inner join dimStation s on s.StationId = t.EndStationId
group by s.StationName
order by AvgTimeSpent desc;


--Based on age of the rider at time of the ride
--Analysis conclusion: Age Groups share the same average amount of minutes spent per trip = 21 mins.
select 
    case when RiderAgeAtTripTime < 20 then '< 20'
         when RiderAgeAtTripTime between 20 and 29 then '20s'
         when RiderAgeAtTripTime between 30 and 39 then '30s'
         when RiderAgeAtTripTime between 40 and 49 then '40s'
         when RiderAgeAtTripTime between 50 and 59 then '50s'
         when RiderAgeAtTripTime between 60 and 69 then '60s'
         when RiderAgeAtTripTime >= 70 then '>= 70'
         else null 
    end as AgeBucket,
    avg(TripDurationMinutes) as AvgTimeSpent
from factTrip t
group by 
        case when RiderAgeAtTripTime < 20 then '< 20'
                when RiderAgeAtTripTime between 20 and 29 then '20s'
                when RiderAgeAtTripTime between 30 and 39 then '30s'
                when RiderAgeAtTripTime between 40 and 49 then '40s'
                when RiderAgeAtTripTime between 50 and 59 then '50s'
                when RiderAgeAtTripTime between 60 and 69 then '60s'
                when RiderAgeAtTripTime >= 70 then '>= 70'
                else null 
        end
order by AvgTimeSpent desc;

--Based on whether the rider is a member or a casual rider: 
--Analysis conclusion: Members and Casual Riders share the same average amount of minutes spent per trip = 21 mins.
select 
    case when r.IsMember = 1 then 'Member' 
         else 'Casual Rider' 
    end as Membership, 
    avg(t.TripDurationMinutes) as AvgTimeSpent
from factTrip t
inner join dimRider r on r.RiderId = t.RiderId
group by case when r.IsMember = 1 then 'Member' else 'Casual Rider' end
order by Membership desc;

--Analyze how much money is spent
--Per month, quarter, year
--Analysis conclusion: Winter Months are the top selling months
SELECT MonthName, sum(Amount) as TotalAmount, avg(Amount) as AvgAmt
from factPayment p
inner join dimDate d on d.DateId = p.DateId
group by MonthName
order by TotalAmount desc;

--Analysis conclusion: Last Quarter is the top selling quarter
SELECT Quarter, sum(Amount) as TotalAmount, avg(Amount) as AvgAmt
from factPayment p
inner join dimDate d on d.DateId = p.DateId
group by Quarter
order by TotalAmount desc;

--Analysis conclusion: Increase in sales between 2017 and 2021, with 2021 being the top selling year.
SELECT Year, sum(Amount) as TotalAmount, avg(Amount) as AvgAmt
from factPayment p
inner join dimDate d on d.DateId = p.DateId
group by Year
order by TotalAmount desc;

--Per member, based on the age of the rider at account start
--Analysis Conclusion: Young people tend to spend the most.
select
    case when RiderAgeAtAccStart < 20 then '< 20'
         when RiderAgeAtAccStart between 20 and 29 then '20s'
         when RiderAgeAtAccStart between 30 and 39 then '30s'
         when RiderAgeAtAccStart between 40 and 49 then '40s'
         when RiderAgeAtAccStart between 50 and 59 then '50s'
         when RiderAgeAtAccStart between 60 and 69 then '60s'
         when RiderAgeAtAccStart >= 70 then '>= 70'
         else null 
    end as AgeBucket,
    avg(TotalAmt) as AvgAmt
from (
    select 
        p.RiderId,
        r.RiderAgeAtAccStart,
        sum(p.Amount) as TotalAmt
    from factPayment p
    inner join dimRider r on r.RiderId = p.RiderId
    where IsMember = 1
    group by p.RiderId, r.RiderAgeAtAccStart
) a
group by
        case when RiderAgeAtAccStart < 20 then '< 20'
                when RiderAgeAtAccStart between 20 and 29 then '20s'
                when RiderAgeAtAccStart between 30 and 39 then '30s'
                when RiderAgeAtAccStart between 40 and 49 then '40s'
                when RiderAgeAtAccStart between 50 and 59 then '50s'
                when RiderAgeAtAccStart between 60 and 69 then '60s'
                when RiderAgeAtAccStart >= 70 then '>= 70'
                else null 
        end
order by AvgAmt desc; 