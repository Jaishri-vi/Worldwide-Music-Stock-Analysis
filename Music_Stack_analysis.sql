/*	Question Set 1 - Easy */


/* Q1: Who is the senior most employee based on job title? */
select top 1 * from employee
order by levels desc

/* Q2: Which countries have the most Invoices? */ 
select top 1 billing_country , count(billing_country) as Total_invoice from invoice
group by billing_country
order by Total_invoice desc

/* Q3: What are top 3 values of total invoice? */.
select top 3 billing_country , sum(total) as Total_invoice from invoice
group by billing_country
order by Total_invoice desc

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
select top 3 * from invoice
order by total desc

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
select top 1 billing_city , sum(total) as Total_invoice from invoice
group by billing_city
order by Total_invoice desc

6.
select top 1 c.first_name ,c.last_name ,sum(total) as spend
from customer c inner join invoice i on c.customer_id=i.customer_id
group by c.first_name, c.last_name
order by spend desc

/*	Question Set 2 - Moderate */

/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

 ---1st method---
select distinct cust.first_name, cust.email from (select c.customer_id, c.first_name,c.last_name, c.email ,invo.invoice_id,invo.track_id from customer c inner join 
(select i.invoice_id, i.customer_id ,inv.track_id from invoice i 
inner join invoice_line inv on i.invoice_id=inv.invoice_id 
) invo on
invo.customer_id=c.customer_id) cust inner join 
(select g.genre_id, t.track_id , g.name from genre g inner join track t on 
g.genre_id=t.genre_id 
where g.name='rock') genr
on cust.track_id=genr.track_id
order by email 

---2nd method---
select distinct email as EMAIL, first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer 
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on track.track_id=invoice_line.track_id
join genre on track.genre_id=genre.genre_id
where genre.name='Rock'

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select top 10 artist.name, count(artist.name) as total_rock_song from artist 
inner join album on artist.artist_id=album.artist_id
inner join track on track.album_id=album.album_id
inner join genre on genre.genre_id=track.genre_id
where genre.name='rock'
group by artist.name
order by total_rock_song desc

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest
songs listed first. */


select name, milliseconds from track
where milliseconds > (select avg(milliseconds) from track) 
order by milliseconds desc


/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */


WITH best_selling_artist AS (
	SELECT top 1 artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


/* Q2: We want to find out the most popular music Genre for each country. We determine the most 
popular genre as the genre with the highest amount of purchases. 
Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second 
--need data at country level. */

--using Common Table Expression method--
with c_sale as 
(select c.country, count(il.invoice_line_id) as highest_sale ,gn.name , 
row_number() over(partition by c.country order by sum(i.total) desc) as rn
from customer c
JOIN invoice i ON i.customer_id = c.customer_id
JOIN invoice_line il on il.invoice_id=i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN genre gn ON t.genre_id= gn.genre_id
group by c.country, gn.name )
select * from c_sale
where rn=1

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with amount_spent_by_cust as
(SELECT c.customer_id, c.first_name, c.last_name,c.country,
SUM(i.total) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
group by c.customer_id, c.first_name, c.last_name,c.country
) ,
rnumber as (
select * , 
row_number() over(partition by amount_spent_by_cust.country order by amount_spent desc) as rn
from amount_spent_by_cust
)
select * from rnumber
where rn=1
order by rnumber.country 


