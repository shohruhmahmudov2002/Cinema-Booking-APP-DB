-- TABLE CREATION
create schema cba;
--Users Table
create type user_role as enum('customer','admin')
create table cba.users(
	user_id int primary key,
	name varchar(100) not null,
	email varchar(100) unique not null,
	password varchar(100) not null,
	role user_role default 'customer',
	phone varchar(100) null,
	created_at timestamp default current_timestamp
);
INSERT INTO cba.users (user_id, name, email, password, role, phone, created_at) VALUES
(1, 'Alice Smith', 'alice@gmail.com', 'hashed_password1', 'customer', '1234567890', '2024-01-01 10:00:00'),
(2, 'Bob Johnson', 'bob@gmail.com', 'hashed_password2', 'admin', '0987654321', '2024-01-02 11:00:00'),
(3, 'Charlie Brown', 'charlie@hotmail.com', 'hashed_password3', 'customer', '1122334455', '2024-01-03 12:00:00');

--Movies Table
create type movie_genre as enum('Action','Drama')
create table cba.movies(
	movie_id int primary key,
	title varchar(100) unique not null,
	description varchar(500) null,
	genre movie_genre not null,
	duration_minutes int not null,
	release_date Date not null,
	rating decimal(3, 2) check(rating >= 0 and rating <= 10),
	poster_url varchar(100) null,
	created_at timestamp default current_timestamp
);
INSERT INTO cba.movies (movie_id, title, description, genre, duration_minutes, release_date, rating, poster_url, created_at) VALUES
(1, 'Inception', 'A mind-bending thriller.', 'Action', 148, '2010-07-16', 8.8, 'inception_poster.jpg', '2024-01-01 10:00:00'),
(2, 'The Matrix', 'A computer hacker learns about the true nature of reality.', 'Action', 136, '1999-03-31', 8.7, 'matrix_poster.jpg', '2024-01-02 11:00:00'),
(3, 'Titanic', 'A romantic drama on the ill-fated ship.', 'Drama', 195, '1997-12-19', 7.9, 'titanic_poster.jpg', '2024-01-03 12:00:00');

--Cinemas Table
create table cba.cinemas(
	cinema_id int primary key,
	name varchar(100) not null,
	location varchar(100) unique not null,
	created_at timestamp default current_timestamp
);
INSERT INTO cba.cinemas (cinema_id, name, location, created_at) VALUES
(1, 'Downtown Cinema', '123 Main Street, City Center', '2024-01-01 10:00:00'),
(2, 'Uptown Theater', '456 Uptown Avenue, Suburbs', '2024-01-02 11:00:00'),
(3, 'Parkside Cineplex', '789 Park Lane, Riverside', '2024-01-03 12:00:00');

--Screens Table
create table cba.screens(
	screen_id int primary key,
	cinema_id int not null references cba.cinemas(cinema_id) on delete cascade,
	name varchar(100) not null,
	capacity int not null
);
INSERT INTO cba.screens (screen_id, cinema_id, name, capacity) VALUES
(1, 1, 'Screen 1', 100),
(2, 1, 'Screen 2', 120),
(3, 2, 'Screen A', 150);

--Seats Table
create type SEAT_TYPE as enum('VIP','Regular')
create table cba.seats(
	seat_id int primary key,
	screen_id int not null references cba.screens(screen_id) on delete cascade,
	seat_number char(2) not null,
	seat_type SEAT_TYPE not null
);
INSERT INTO cba.seats (seat_id, screen_id, seat_number, seat_type) VALUES
(1, 1, 'A1', 'VIP'),
(2, 1, 'A2', 'Regular'),
(3, 2, 'B1', 'Regular');

--Showtimes Table
create table cba.showtimes(
	showtime_id int primary key,
	screen_id int not null references cba.screens(screen_id) on delete cascade,
	movie_id int not null references cba.movies(movie_id) on delete cascade,
	start_time timestamp not null,
	end_time timestamp not null,
	price decimal(10,2) not null
);
INSERT INTO cba.showtimes (showtime_id, screen_id, movie_id, start_time, end_time, price) VALUES
(1, 1, 1, '2024-01-10 14:00:00', '2024-01-10 16:30:00', 10.00),
(2, 2, 2, '2024-01-11 18:00:00', '2024-01-11 20:30:00', 12.50),
(3, 3, 3, '2024-01-12 20:00:00', '2024-01-12 23:15:00', 15.00);

--Bookings Table
create type STATUS as enum('pending','confirmed','canceled')
create table cba.bookings(
	booking_id int primary key,
	user_id int not null references cba.users(user_id) on delete cascade,
	showtime_id int not null references cba.showtimes(showtime_id) on delete cascade,
	booking_date timestamp default current_timestamp,
	total_price decimal(10,2) not null,
	status STATUS default 'pending'
);
INSERT INTO cba.bookings (booking_id, user_id, showtime_id, booking_date, total_price, status) VALUES
(1, 1, 1, '2024-01-05 10:00:00', 10.00, 'confirmed'),
(2, 2, 2, '2024-01-06 11:30:00', 25.00, 'pending'),
(3, 3, 3, '2024-01-07 15:45:00', 15.00, 'canceled');

--Booking Details Table
create table cba.details(
	booking_detail_id int primary key,
	booking_id int not null references cba.bookings(booking_id) on delete cascade,
	seat_id int not null references cba.seats(seat_id) on delete cascade,
	price decimal(10,2) not null,
	Unique(seat_id, booking_id)
);
INSERT INTO cba.details (booking_detail_id, booking_id, seat_id, price) VALUES
(1, 1, 1, 10.00),
(2, 2, 2, 12.50),
(3, 3, 3, 15.00);

--Payments Table
create type PAYMENT_STATUS as enum('pending','completed','failed')
create table cba.payments(
	payment_id int primary key,
	booking_id int not null references cba.bookings(booking_id) on delete cascade,
	payment_date timestamp default current_timestamp,
	amount decimal(10,2) not null,
	payment_method varchar(50) not null,
	status PAYMENT_STATUS default 'pending'
);
INSERT INTO cba.payments (payment_id, booking_id, payment_date, amount, payment_method, status) VALUES
(1, 1, '2024-01-05 10:15:00', 10.00, 'Credit Card', 'completed'),
(2, 2, '2024-01-06 11:45:00', 25.00, 'PayPal', 'completed'),
(3, 3, '2024-01-07 16:00:00', 15.00, 'Cash', 'failed');

-- END OF TABLE CREATION

-- TASKS

-- Task 1: Operators
-- 1
select * from cba.users
where user_id > 1 and (role = 'admin' or role = 'customer')
-- 2
select * from cba.movies
where (rating between 7 and 9) and duration_minutes > 90
--3
select * from cba.bookings
where total_price > 10 and status != 'canceled'
--4
select * from cba.payments
where amount > 100 or payment_method = 'Credit Card'

--Task 2: WHERE
--1
select * from cba.users
where email like '%gmail.com'
--2
select * from cba.movies
where rating >= 8
--3
select * from cba.bookings
where user_id = 3
--4
select * from cba.showtimes
where movie_id = 3 and start_time::time > '18:00:00'

--Task 3: DISTINCT
--1
select distinct genre from cba.movies
--2
select distinct location from cba.cinemas
--3
select distinct status from cba.bookings
--4
select distinct start_time from cba.showtimes

--Task 4: ORDER BY
--1
select * from cba.users
order by created_at desc
--2
select * from cba.movies
order by release_date asc
--3
select * from cba.bookings
order by total_price desc
--4
select * from cba.payments
order by payment_date desc

--Task 5: LIKE
--1
select * from cba.users
where name ilike 'a%'
--2
select * from cba.movies
where title ilike '%matrix%'
--3
select * from cba.bookings
where booking_date::text like '2024-%'
--4
select * from cba.cinemas
where name ilike '%theater'

--Task 6: Aliases
--1
select user_id "User ID", name "Full Name", email "Email Address"
from cba.users
--2
select title "Movie Title", release_date "Release Date", rating "Viewer Rating"
from cba.movies
--3
select booking_date "Booking Date", status "Booking Status", total_price "Amount Paid"
from cba.bookings
--4
select start_time "Show Start Time", price "Ticket Price", screen_id "Screen ID"
from cba.showtimes