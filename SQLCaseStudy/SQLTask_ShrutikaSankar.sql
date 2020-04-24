/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

select name
from Facilities 
where membercost != 0 and membercost is not null

/* Q2: How many facilities do not charge a fee to members? */
select count(facid)
from Facilities 
where membercost = 0 

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

select facid, name, membercost, monthlymaintenance
from Facilities 
where membercost <  0.2*monthlymaintenance

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

select *
from Facilities 
where facid in (1,5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
select name, 
	monthlymaintenance,
	case when monthlymaintenance > 100 then 'expensive'
	else 'cheap' end as cheaporexpensive
from Facilities 


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT surname, firstname
FROM Members
WHERE joindate = (
SELECT max( joindate )
FROM Members )

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT distinct f.name as courtname,  concat(firstname, ' ', surname) as membername
from Bookings as b 
inner join Members as m  on
	b.memid = m.memid
inner join Facilities as f on
	b.facid = f.facid
WHERE f.name LIKE 'Tennis C%'
ORDER BY membername

/* note member names are duplicated here and there is a guest name 'Guest Guest' 
we can get rid of guest 
*/
select f.name AS courtname, concat( firstname, ' ', surname ) AS membername
FROM Bookings AS b
INNER JOIN Members AS m ON b.memid = m.memid
INNER JOIN Facilities AS f ON b.facid = f.facid
WHERE f.name LIKE 'Tennis C%'
AND firstname NOT LIKE '%GUEST%'
ORDER BY membername

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

select name as facility_name, member_bookings*membercost  +
(sum_people-member_bookings)*guestcost as revenue
from
(select f.facid,  count(memid) as member_bookings, sum(slots) as sum_people
from Bookings as b 
inner join Facilities as f on
	b.facid = f.facid
group by f.facid) as f_peop
inner join
(select distinct facid, name, guestcost, membercost from Facilities) as f_rev
using(facid)

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT distinct courtname,  concat(firstname, ' ', surname) as membername
from
(select b.memid, b.facid, f.name as courtname, firstname, surname 
from Bookings as b 
inner join Members as m  on
	b.memid = m.memid
inner join Facilities as f on
	b.facid = f.facid
where f.name like 'Tennis C%') as s
where firstname not like '%GUEST%'
order by membername

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
    SELECT distinct m1.surname as member_surname
    , m1.firstname as member_firstname
    , m2.surname as recomemnder_surname
    , m2.firstname as recomemnder_firstname 
    FROM Members as m1
    left join Members as m2
    on m1.recommendedby = m2.memid
    order by member_surname, member_firstname


/* Q12: Find the facilities with their usage by member, but not guests */
        SELECT f.name AS facility_name
        , firstname || ' ' || surname  AS membername, count(bookid) as used_number_of_times
        FROM Bookings AS b
        INNER JOIN Members AS m ON b.memid = m.memid
        INNER JOIN Facilities AS f ON b.facid = f.facid
        where firstname NOT LIKE '%GUEST%'
        GROUP BY facility_name, membername
        ORDER BY facility_name, membername

/* Q13: Find the facilities usage by month, but not guests */
    select f.name AS facility_name
    , strftime('%m', starttime) AS month
    , count(bookid) as used_number_of_times
    FROM Bookings AS b
    INNER JOIN Members AS m ON b.memid = m.memid
    INNER JOIN Facilities AS f ON b.facid = f.facid
    where firstname NOT LIKE '%GUEST%'
    group by facility_name, month
    ORDER BY facility_name, month

