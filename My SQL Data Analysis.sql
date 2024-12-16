 /*	Question Set 1 - Easy */
 
/* Q1: Who is the senior most employee based on job title? */
 
Select * From Employee;

Select * From employee
Order by levels Desc
Limit 1;

/* Q2: Which countries have the most Invoices? */

Select * From Invoice;

Select billing_country,Count(*) As C 
From invoice
group by billing_country
Order by C Desc;

/* Q3: What are top 3 values of total invoice? */

Select * From Invoice;

Select *
From Invoice
Order by Total Desc
Limit 3;



/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

Select *  From Customer;
Select * From Invoice;

Select  Billing_City ,Sum(Total) As Invoice_Total
From Invoice
Group by Billing_City
Order by Invoice_Total Desc
Limit 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

Select * from invoice;
Select * from Customer;

Select  I.Customer_Id, C.First_name, C.Last_name, Round(Sum(I.Total)) AS Money_Spent 
From invoice As I
Join Customer As C
	on I.Customer_id = C.Customer_id
Group by  I.Customer_Id, C.First_name, C.Last_name 
Order by Money_Spent  desc
Limit 1
;

/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

Select * From Genre;
Select * From Track;
Select * From invoice_line;
Select * From Invoice;
Select * From Customer;

Select Distinct Email, First_name, Last_name
From Customer As C
Join Invoice As I
	on C.Customer_id = I.Customer_id
Join invoice_line  As IL
	on IL.invoice_id =  I.invoice_id
Join Track As T
	on T.Track_id =  IL.track_id
Join Genre As G
	on G.Genre_id = T.Genre_Id
Where G.Genre_id = 1
Order by C.Email ;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

Select * From Genre;
Select * From Track;
Select * From Album2;
Select * From Artist;

Select AT.artist_id, AT.name,Count(AT.artist_id) As Num_of_songs From Genre AS G
Join Track As T
	on G.Genre_id = T.Genre_id
Join Album2 As A
	on A.Album_id = T.Album_id
Join Artist As  AT
	on AT.artist_id =  A.artist_id
Where T.Genre_id = 1
Group by AT.name, A.artist_id
Order by Num_of_songs Desc
Limit 10 ;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

Select * From Track;

Select Name, Milliseconds From Track
Where Milliseconds >(Select Round(Avg(Milliseconds))From Track)
Order by Milliseconds Desc;


/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, Round(SUM(invoice_line.unit_price*invoice_line.quantity)) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album2 ON album2.album_id = track.album_id
	JOIN artist ON artist.artist_id = album2.artist_id
	GROUP BY 1,2
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, Round(SUM(il.unit_price*il.quantity)) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album2 alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

With Popular_music_genre AS 
(Select Count(IL.quantity) AS Purchase, C.Country, G.genre_id, g.name AS Genre,
Row_number() Over (partition by C.Country Order by Count(IL.quantity)Desc) As Topped
 From invoice AS I
Join invoice_line AS IL on IL.invoice_id = I.invoice_id
Join Customer AS C on C.customer_id = I.customer_id
Join Track As T on T.Track_id = IL.track_id
Join genre As G on G.genre_id = T.genre_id
Group by 2,3,4
Order by 2 Asc , Purchase Desc
)
Select * from Popular_music_genre
where Topped <=1;

