#                                         boAt Sales & Returns Analysis using MySQL
# Objective:-
/** 1.To design and manage a relational database for an e-commerce company (boAt).
    2.To establish Primary Key and Foreign Key relationships between multiple tables.
    3.To analyze customer purchasing behaviour, product performance, and return patterns.
    4.To practice SQL concepts such as:
Data Cleaning (date formatting using STR_TO_DATE)
Table modification using ALTER TABLE
Applying Primary Key & Foreign Key constraints
Querying data using SELECT
    5.To ensure data consistency and integrity across the database.        **/
    
# First create a database for this project:-
Create database Boat;
use Boat;
# Note:- In MYSQL we can only import a CSV or a JSON files.
# Now let us see each and every tables:-

/**
1. Data cleaning of each tables:-
a)In this firat of all we will check the data type of each column as wether they are appropriate or not.

Table:- Boat_customer   **/

Select * from boat_customer;
# Data type:-
describe boat_customer;
 /** Here the data type of column 'phone' is 'Bingit'. We know that a phone number cannot have characters more 
 than ten. So we will change the data type of 'phone' from 'Bingit' to 'Char(10)' so that nobody could be able to 
 enter more or less than 10 characters. Moreover by converting the data type to a string we can use any character
 to it, like '+' before the number.     **/
Alter Table Boat_customer
modify column phone char(10);

/** Here the data type of 'Postal Code' is integer that has to be converted to a 'Char(6)' beacause the number of character
in the postal code is six only and sometimes the postal code uses special characters too. **/
Alter Table Boat_customer
modify column postal_code char(6);

/** Now the column 'Registration Date' has the data type 'Text' that has to be converted to 'Date and time'.  **/
Alter Table Boat_customer
modify column Registration Date date;
/** But in the above code it is clear that the 'Date' comming with the column name is acting as the data type 'Date'.
So we need to change the name of the column first to 'registration_date'.    **/
# Step1:
/** Now the values in the column 'Registration _date' has some values written in the format 'DD-MM-YYYY' while some values
are following the format 'DD/MM/YYYY'. So we will convert the format of all the values as 'DD-MM-YYYY'.  **/
Set Sql_safe_updates=0;
Update Boat_customer
set Registration_date = replace(Registration_date,'/','-');
# Now let us check whether changes have been done or not:
Select * from boat_customer;
# Step2:-
/** Now we will set the format of the date as 'YYYY-MM-DD' only.           **/
update boat_customer
set Registration_date = str_to_date(Registration_date,'%d-%m-%Y');
# Step 3:-
/** Now we will change the data type of the the values of the column 'Registration_date' into data type Date.   **/
Alter table boat_customer
modify column Registration_date Date;
# Let us see the change in the data type:-
Describe boat_customer;

# Table: Order_boat:-
Select * from order_boat;
describe order_boat;

/** The data type of columns 'Order_date','shipped_date', and 'delivery_date' are in text form that has to be changed into
'Date' form. So let us do it:   **/
# Step 1:- to convert the format of all the values as 'DD-MM-YYYY'
update order_boat
set 
	order_date = replace(order_date,'/','-'),
	shipped_date = replace(shipped_date,'/','-'),
	delivery_date = replace(delivery_date,'/','-');

# Step 2:- Now we will set the format of the date as 'YYYY-MM-DD' only.
update order_boat
set
   order_date = str_to_date(order_date,'%d-%m-%Y'),
   shipped_date = str_to_date(shipped_date,'%d-%m-%Y'),
   delivery_date = str_to_date(delivery_date,'%d-%m-%Y');
   
# Step 3:- Now we will change the data type.
Alter table order_boat
modify column order_date date,
modify column shipped_date date,
modify column delivery_date date;

# Let us see the table again:
select * from order_boat;
describe order_boat;

# Table:- Order_detail:
Select * from order_detail;
describe order_detail;

# Here the data type of column 'discount_percent' should be a float value and not a double.
alter table order_detail
modify column discount_percent float;

# Table:- Products:-

Select * from products;
describe products;

# Here the data type of column 'Rating' should be a float and not a double.
alter table products
modify column rating float;

# Table:- returns:-
Select * From returns;
describe returns;
# Here we will change the data type of column 'Return_date' into date.
update returns
set
   return_date = str_to_date(return_date,'%d-%m-%Y');
   
alter table returns
modify column return_date date;

# b) Fixing of the primary and foreign key for each table:-
Select * from Boat_customer;
Select * from order_boat;
Select * from order_detail;
Select * From products;
Select * from returns;
# * Note:- A table can have more than one foreign keys but only one primary key.
# * Note:- In the table 'Returns' column 'order_detail_id' cannot be a foreign key as this 
# column has some non unique values.