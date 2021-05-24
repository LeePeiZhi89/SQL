create schema G2T01;
use G2T01;

# Part one: Create table

create table Item(
ISBN varchar(25) not null,
 Title varchar(150) ,
 Publisher_name varchar(50) ,
 Classification_Code varchar(10),
 Format_Type char(2),
 constraint item_pk primary key(ISBN));
 
 create table author( 
ISBN varchar(25) not null, 
Author varchar(100)  not null,
constraint author_pk primary key(ISBN, Author),
constraint author_fk foreign key(ISBN) references Item(ISBN));
 
 create table electronic_item(
ISBN varchar(25) not null,
url varchar(100),
constraint electronic_item_pk primary key(ISBN),
constraint electronic_item_fk foreign key(ISBN) references Item(ISBN));

create table copy(
ISBN varchar(25) not null,
copy_id int not null,
acquired_date date ,
constraint copy_pk primary key(ISBN,copy_id),
constraint copy_fk foreign key(ISBN) references Item(ISBN));

create table membership(
member_type varchar(20) not null primary key,
loan_period int,
item_limit int,
annual_fee double,
admin_discount int,
penalty_rate double);

create table user(
user_id varchar(25) not null primary key,
user_name varchar(100),
member_type varchar(20),
total_accured_fine double,
is_faculty char(1),
is_student char(1),
is_admin char(1),
constraint user_fk foreign key(member_type) references membership(member_type));

create table school(
name varchar(100) not null primary key,
address varchar(100) ,
url varchar(100));

create table room(
room_id varchar(10) not null primary key,
floor_number int,
has_space char(1));

create table shelf(
room_id varchar(10) not null,
sid varchar(10),
for_dvd char(1),
capacity int,
constraint shelf_pk primary key (room_id,sid),
constraint shelf_fk foreign key(room_id) references room(room_id));

create table physical_item(
ISBN varchar(25) not null primary key,
room_id varchar(10),
shelf_id varchar(10),
type varchar(10),
constraint physical_item_fk1 foreign key(room_id,shelf_id) references shelf(room_id,sid));

create table borrow(
ISBN varchar(25) not null,
copy_id int not null,
user_id varchar(25) not null,
borrowed_datetime datetime not null,
returned_datetime datetime,
constraint borrow_pk primary key(isbn,copy_id,user_id,borrowed_datetime),
constraint borrow_fk1 foreign key(isbn,copy_id) references copy(isbn,copy_id),
constraint borrow_fk2 foreign key(user_id) references user(user_id));

create table student(
user_id varchar(25) not null primary key,
enrolment_year int,
expected_graduation_year int,
constraint student_fk foreign key(user_id) references user(user_id));

create table comment(
user_id varchar(25) not null,
electronic_item varchar(25) not null,
date_time datetime not null,
text varchar(100),
constraint comment_pk primary key(user_id,electronic_item,date_time),
constraint comment_fk1 foreign key(user_id) references student(user_id),
constraint comment_fk2 foreign key(electronic_item) references electronic_item(isbn)
);

create table comment_rating(
rating_user_id varchar(25) not null,
comment_user_id varchar(25) not null,
electronic_item varchar(25) not null,
date_time datetime not null,
stars int,
constraint comment_rating_pk primary key(rating_user_id,comment_user_id,electronic_item,date_time),
constraint comment_rating_fk1 foreign key(comment_user_id,electronic_item,date_time) references comment(user_id,electronic_item,date_time),
constraint comment_rating_fk2 foreign key(rating_user_id) references student(user_id));

create table faculty(
user_id varchar(25) not null primary key,
office_address varchar(100),
main_research varchar(100),
constraint faculty_fk foreign key(user_id) references user(user_id));

create table admin_staff(
user_id varchar(25) not null primary key,
school varchar(100),
is_chief char(1),
constraint admin_staff_fk1 foreign key(school) references school(name),
constraint admin_staff_fk2 foreign key(user_id) references user(user_id));

create table item_request(
faculty varchar(25) not null,
description varchar(100) not null,
admin_staff varchar(25),
school varchar(100),
isbn varchar(25),
is_procured char(1),
constraint item_request_pk primary key(faculty,description),
constraint item_request_fk1 foreign key(faculty) references faculty(user_id),
constraint item_request_fk2 foreign key(admin_staff) references admin_staff(user_id),
constraint item_request_fk3 foreign key(isbn) references item(isbn),
constraint item_request_fk4 foreign key(school) references school(name));


# Part two: Load Table

#load data for Table Item
LOAD DATA local INFILE '/Volumes/GoogleDrive/My Drive/2. Data Mgmt/Project/Phase 2/G2T01//data/item.txt' INTO TABLE item
FIELDS TERMINATED BY '\t'   LINES TERMINATED BY '\r\n'   IGNORE 1 LINES; 
 
# load data for table author
LOAD DATA local INFILE '/Volumes/GoogleDrive/My Drive/2. Data Mgmt/Project/Phase 2/G2T01//data/author.txt' INTO TABLE author
FIELDS TERMINATED BY '\t'   LINES TERMINATED BY '\r\n'   IGNORE 1 LINES; 

# load data for table electronic item
LOAD DATA local INFILE '/Volumes/GoogleDrive/My Drive/2. Data Mgmt/Project/Phase 2/G2T01//data/electronic_item.txt' INTO TABLE electronic_item
FIELDS TERMINATED BY '\t'   LINES TERMINATED BY '\r\n'   IGNORE 1 LINES; 

# load data for table copy
LOAD DATA local INFILE '/Volumes/GoogleDrive/My Drive/2. Data Mgmt/Project/Phase 2/G2T01//data/copy.txt' INTO TABLE copy
FIELDS TERMINATED BY '\t'   LINES TERMINATED BY '\r\n'   IGNORE 1 LINES; 

# load data for table membership
LOAD DATA local INFILE '/Volumes/GoogleDrive/My Drive/2. Data Mgmt/Project/Phase 2/G2T01//data/membership.txt' INTO TABLE membership
FIELDS TERMINATED BY '\t'   LINES TERMINATED BY '\r\n'   IGNORE 1 LINES; 
 
# load data for table user
LOAD DATA local INFILE '/Volumes/GoogleDrive/My Drive/2. Data Mgmt/Project/Phase 2/G2T01//data/user.txt' INTO TABLE user
FIELDS TERMINATED BY '\t'   LINES TERMINATED BY '\r\n'   IGNORE 1 LINES; 

# load data for table school
LOAD DATA local INFILE '/Volumes/GoogleDrive/My Drive/2. Data Mgmt/Project/Phase 2/G2T01//data/school.txt' INTO TABLE school
FIELDS TERMINATED BY '\t'   LINES TERMINATED BY '\r\n'   IGNORE 1 LINES; 
 
# load data for room
LOAD DATA local INFILE '/Volumes/GoogleDrive/My Drive/2. Data Mgmt/Project/Phase 2/G2T01//data/room.txt' INTO TABLE room
FIELDS TERMINATED BY '\t'   LINES TERMINATED BY '\r\n'   IGNORE 1 LINES; 

# load data for table shelf
LOAD DATA local INFILE '/Volumes/GoogleDrive/My Drive/2. Data Mgmt/Project/Phase 2/G2T01//data/shelf.txt' INTO TABLE shelf
FIELDS TERMINATED BY '\t'   LINES TERMINATED BY '\r\n'   IGNORE 1 LINES; 

# load data for table physical_item
LOAD DATA local INFILE '/Volumes/GoogleDrive/My Drive/2. Data Mgmt/Project/Phase 2/G2T01//data/Physical_item.txt' INTO TABLE physical_item
FIELDS TERMINATED BY '\t'   LINES TERMINATED BY '\r\n'   IGNORE 1 LINES; 

# load data for table borrow
LOAD DATA local INFILE '/Volumes/GoogleDrive/My Drive/2. Data Mgmt/Project/Phase 2/G2T01//data/borrow.txt' INTO TABLE borrow
FIELDS TERMINATED BY '\t'   LINES TERMINATED BY '\r\n'   IGNORE 1 LINES; 

# load data for table student
LOAD DATA local INFILE '/Volumes/GoogleDrive/My Drive/2. Data Mgmt/Project/Phase 2/G2T01//data/student.txt' INTO TABLE student
FIELDS TERMINATED BY '\t'   LINES TERMINATED BY '\r\n'   IGNORE 1 LINES; 

# load data for table comment
LOAD DATA local INFILE '/Volumes/GoogleDrive/My Drive/2. Data Mgmt/Project/Phase 2/G2T01//data/comment.txt' INTO TABLE comment
FIELDS TERMINATED BY '\t'   LINES TERMINATED BY '\r\n'   IGNORE 1 LINES; 

# load data for table comment_rating
LOAD DATA local INFILE '/Volumes/GoogleDrive/My Drive/2. Data Mgmt/Project/Phase 2/G2T01//data/comment_rating.txt' INTO TABLE comment_rating
FIELDS TERMINATED BY '\t'   LINES TERMINATED BY '\r\n'   IGNORE 1 LINES; 

# load data for table faculty
LOAD DATA local INFILE '/Volumes/GoogleDrive/My Drive/2. Data Mgmt/Project/Phase 2/G2T01//data/faculty.txt' INTO TABLE faculty
FIELDS TERMINATED BY '\t'   LINES TERMINATED BY '\r\n'   IGNORE 1 LINES; 

# load data for table admin_staff
LOAD DATA local INFILE '/Volumes/GoogleDrive/My Drive/2. Data Mgmt/Project/Phase 2/G2T01//data/admin_staff.txt' INTO TABLE admin_staff
FIELDS TERMINATED BY '\t'   LINES TERMINATED BY '\r\n'   IGNORE 1 LINES; 
 
# load data for table item_request
LOAD DATA local INFILE '/Volumes/GoogleDrive/My Drive/2. Data Mgmt/Project/Phase 2/G2T01//data/item_request.txt' INTO TABLE item_request
FIELDS TERMINATED BY '\t'   LINES TERMINATED BY '\r\n'   IGNORE 1 LINES; 
