/*---------------------------------*/
/*---------------------------------*/
/* Tables */
/*---------------------------------*/

SELECT * FROM finalyearproject.checkins;
SELECT * FROM finalyearproject.users;
SELECT * FROM finalyearproject.venues;
SELECT * FROM finalyearproject.categories;
SELECT * FROM finalyearproject.venuecategories;
SELECT * FROM finalyearproject.with;
SELECT * FROM finalyearproject.checkinphotos;
SELECT * FROM finalyearproject.photos;



/*---------------------------------*/
/*---------------------------------*/
/* General */
/*---------------------------------*/

/* Overview */
SELECT * FROM Overview;

SELECT User_Country_Gender.Country AS 'Country',
	General_Info.Checkins AS 'Checkins',
    General_Info.Users AS 'Users1',						/*Counts number of distinct users in each country*/
	COUNT(User_Country_Gender.id) AS 'Users2',			/*Each users, registered to first country */
	SUM(CASE WHEN User_Country_Gender.Gender = 'male' THEN 1 ELSE 0 END) AS 'Male',
	SUM(CASE WHEN User_Country_Gender.Gender = 'female' THEN 1 ELSE 0 END) AS 'Female',
    SUM(CASE WHEN User_Country_Gender.Gender = 'none' THEN 1 ELSE 0 END) AS 'No Gender',
    General_Info.Venues AS 'Venues'
FROM finalyearproject.User_Country_Gender as User_Country_Gender,
	finalyearproject.General_Info as General_Info
WHERE User_Country_Gender.Country = General_Info.Country
GROUP BY Country;


/* Category Info */
SELECT * FROM Category_Info;

SELECT categories.name AS 'Category',
	venues.location_cc AS 'Country',
	COUNT(DISTINCT(venuecategories.venue)) AS 'Venue_Count',
    COUNT(DISTINCT(checkins.id)) AS 'Checkin_Count',
    COUNT(DISTINCT(checkins.userid)) AS 'Unique_Users'
FROM finalyearproject.categories as categories,
	finalyearproject.venuecategories as venuecategories,
    finalyearproject.venues as venues,
    finalyearproject.checkins as checkins 
WHERE venuecategories.category = categories.id AND venuecategories.venue = venues.id AND venues.id = checkins.venueid
GROUP BY Category, Country;

/* User Info */
SELECT * FROM User_Info;

SELECT users.id AS 'User',
	venues.location_cc AS 'Country',
    COUNT(checkins.id) as 'Checkins',
    COUNT(DISTINCT(venues.id)) as 'Distinct_Venues',
    COUNT(DISTINCT(venuecategories.category)) as 'Categories'
FROM finalyearproject.venues as venues 
LEFT JOIN finalyearproject.venuecategories ON  venuecategories.venue = venues.id
INNER JOIN finalyearproject.checkins ON checkins.venueid = venues.id 
INNER JOIN finalyearproject.users ON checkins.userid = users.id
GROUP BY User, Country;

/* Venue Info */
SELECT * FROM Venue_Info;

SELECT venues.id AS 'Venue',
	venues.location_cc AS 'Country',
    COUNT(checkins.id) as 'Checkins',
    COUNT(DISTINCT(users.id)) as 'Distinct_Users',
    COUNT(DISTINCT(venuecategories.category)) as 'Categories'
FROM finalyearproject.venues as venues 
LEFT JOIN finalyearproject.venuecategories ON  venuecategories.venue = venues.id
INNER JOIN finalyearproject.checkins ON checkins.venueid = venues.id 
INNER JOIN finalyearproject.users ON checkins.userid = users.id
GROUP BY Venue, Country;

/*---------------------------------*/
/*---------------------------------*/
/* For Algo */
/*---------------------------------*/

 SET GLOBAL group_concat_max_len = 102400;

SELECT * FROM Venue_Detailed;

SELECT * FROM finalyearproject.Venue_Detailed where location_cc='GB';

SELECT venues.*,
    COUNT(checkins.id) as 'Checkins',
    venuecategories.category as 'Category',
    Hours.Hours as 'DayHour_Checkin_Count',
    VenueUsers.VenueUsers as 'Venue_Users'
FROM finalyearproject.venues as venues 
LEFT JOIN finalyearproject.venuecategories ON  venuecategories.venue = venues.id
INNER JOIN finalyearproject.checkins ON checkins.venueid = venues.id
LEFT JOIN (
	SELECT VenueId as 'id', 
	  group_concat(CONCAT(Venue_Hours, ':',Venue_Hours_Count ) separator ',') as 'Hours'
	FROM Venue_Hours
	GROUP BY VenueId
) as Hours ON venues.id = Hours.id
LEFT JOIN (
	SELECT VenueId as 'id', 
	  group_concat(UserId separator ',') as 'VenueUsers'
	FROM Venue_Users
	GROUP BY VenueId
) as VenueUsers ON venues.id = VenueUsers.id
GROUP BY Venue, Category;

SELECT venues.*,
    COUNT(checkins.id) as 'Checkins',
    venuecategories.category as 'Category',
    Hours.Hours as 'DayHour_Checkin_Count',
    VenueUsers.VenueUsers as 'Venue_Users'
FROM finalyearproject.venues as venues 
LEFT JOIN finalyearproject.venuecategories ON  venuecategories.venue = venues.id
INNER JOIN finalyearproject.checkins ON checkins.venueid = venues.id
LEFT JOIN Venue_Hours_Joined as Hours ON venues.id = Hours.id
LEFT JOIN Venue_Users_Joined as VenueUsers ON venues.id = VenueUsers.id
GROUP BY Venue, Category;

/* Venue_Hours */
SELECT * FROM Venue_Hours;

SELECT venues.id AS VenueId,
	DATE_FORMAT(FROM_UNIXTIME((checkins.createdat + (60 * checkins.timezoneoffset))), '%w%H') AS Venue_Hours,
	COUNT(checkins.id) AS Venue_Hours_Count
FROM venues, checkins
WHERE checkins.venueid = venues.id
GROUP BY checkins.venueid , Venue_Hours;

/* Venue Users */
SELECT * FROM Venue_Users;

SELECT venues.id AS VenueId,
	checkins.userid AS UserId
FROM venues, checkins
WHERE checkins.venueid = venues.id
GROUP BY VenueId, UserId;

    
SELECT * FROM User_Detailed;

SELECT users.id AS 'User',
	users.*,
	venues.location_cc AS 'Country',
    COUNT(checkins.id) as 'Checkins',
    COUNT(DISTINCT(venues.id)) as 'Distinct_Venues',
    COUNT(DISTINCT(venuecategories.category)) as 'Categories'
FROM finalyearproject.venues as venues 
LEFT JOIN finalyearproject.venuecategories ON  venuecategories.venue = venues.id
INNER JOIN finalyearproject.checkins ON checkins.venueid = venues.id 
INNER JOIN finalyearproject.users ON checkins.userid = users.id
GROUP BY User, Country;

/*---------------------------------*/
/*---------------------------------*/
/* Time */
/*---------------------------------*/

/* Checkins per day*/
EXPLAIN SELECT * FROM Checkins_Per_Day;

SELECT  DATE_FORMAT(FROM_UNIXTIME(checkin.createdat+(60*checkin.timezoneoffset)), "%Y-%m-%d") AS 'Date',
        SUM(CASE WHEN venue.location_cc = 'GB' THEN 1 ELSE 0 END) AS 'GB',
        SUM(CASE WHEN venue.location_cc = 'US' THEN 1 ELSE 0 END) AS 'US'
FROM finalyearproject.checkins AS checkin, finalyearproject.venues AS venue
WHERE checkin.venueid = venue.id AND (checkin.createdat+(60*checkin.timezoneoffset)) > 1488672000
GROUP BY Date;


/* Checkins per DayHour*/
SELECT * FROM Checkins_Per_DayHour;

SELECT  DATE_FORMAT(FROM_UNIXTIME(checkin.createdat+(60*checkin.timezoneoffset)), "%Y-%m-%d") AS 'Date',
        SUM(CASE WHEN venue.location_cc = 'GB' THEN 1 ELSE 0 END) AS 'GB',
        SUM(CASE WHEN venue.location_cc = 'US' THEN 1 ELSE 0 END) AS 'US'
FROM finalyearproject.checkins AS checkin, finalyearproject.venues AS venue
WHERE checkin.venueid = venue.id AND (checkin.createdat+(60*checkin.timezoneoffset)) > 1488672000
GROUP BY Date;


/* Checkins per WeekDay*/
SELECT * FROM Checkins_Per_WeekDay;

SELECT  DATE_FORMAT(FROM_UNIXTIME(checkin.createdat+(60*checkin.timezoneoffset)), "%w") AS 'DayNum',
		DATE_FORMAT(FROM_UNIXTIME(checkin.createdat+(60*checkin.timezoneoffset)), "%W") AS 'Week Day',
        SUM(CASE WHEN venue.location_cc = 'GB' THEN 1 ELSE 0 END) AS 'GB',
        SUM(CASE WHEN venue.location_cc = 'US' THEN 1 ELSE 0 END) AS 'US'
FROM finalyearproject.checkins AS checkin, finalyearproject.venues AS venue
WHERE checkin.venueid = venue.id
GROUP BY DateNum
ORDER BY DateNum;


/* Checkins per Hour*/
SELECT * FROM Checkins_Per_Hour;

SELECT  DATE_FORMAT(FROM_UNIXTIME(checkin.createdat+(60*checkin.timezoneoffset)), "%H") AS 'Hour',
        SUM(CASE WHEN venue.location_cc = 'GB' THEN 1 ELSE 0 END) AS 'GB',
        SUM(CASE WHEN venue.location_cc = 'US' THEN 1 ELSE 0 END) AS 'US'
FROM finalyearproject.checkins AS checkin, finalyearproject.venues AS venue
WHERE checkin.venueid = venue.id
GROUP BY Hour;


/* Checkins per WeekDayHour*/
SELECT * FROM Checkins_Per_WeekDayHour;

SELECT  DATE_FORMAT(FROM_UNIXTIME(checkin.createdat+(60*checkin.timezoneoffset)), "%w-%H") AS 'WeekdayHourNum',
		DATE_FORMAT(FROM_UNIXTIME(checkin.createdat+(60*checkin.timezoneoffset)), "%W - %H") AS 'Weekday_Hour',
        SUM(CASE WHEN venue.location_cc = 'GB' THEN 1 ELSE 0 END) AS 'GB',
        SUM(CASE WHEN venue.location_cc = 'US' THEN 1 ELSE 0 END) AS 'US'
FROM finalyearproject.checkins AS checkin, finalyearproject.venues AS venue
WHERE checkin.venueid = venue.id
GROUP BY Weekday_Hour
ORDER BY WeekdayHourNum;

/*---------------------------------*/
/*---------------------------------*/
/* Histograms */
/*---------------------------------*/

/* Number of checkins vs User Count */
SELECT * FROM Histogram_Checkins_vs_UserCount;

SELECT  User_Info.Checkins AS 'Num_of_Checkins',
		SUM(CASE WHEN User_Info.Country = 'GB' THEN 1 ELSE 0 END) AS 'GB_User_Count',
        SUM(CASE WHEN User_Info.Country = 'US' THEN 1 ELSE 0 END) AS 'US_User_Count'
FROM finalyearproject.User_Info AS User_Info
GROUP BY User_Info.Checkins;


/* Number of unique venues vs User Count */
SELECT * FROM Histogram_UniqueVenues_vs_UserCount;

SELECT  User_Info.Distinct_Venues AS 'Num_of_Unique_Venues',
		SUM(CASE WHEN User_Info.Country = 'GB' THEN 1 ELSE 0 END) AS 'GB_User_Count',
        SUM(CASE WHEN User_Info.Country = 'US' THEN 1 ELSE 0 END) AS 'US_User_Count'
FROM finalyearproject.User_Info AS User_Info
GROUP BY User_Info.Distinct_Venues;


/* Number of categories vs User Count */
SELECT * FROM Histogram_Categories_vs_UserCount;

SELECT  User_Info.Categories AS 'Num_of_Categories',
		SUM(CASE WHEN User_Info.Country = 'GB' THEN 1 ELSE 0 END) AS 'GB_User_Count',
        SUM(CASE WHEN User_Info.Country = 'US' THEN 1 ELSE 0 END) AS 'US_User_Count'
FROM finalyearproject.User_Info AS User_Info
GROUP BY User_Info.Categories;


/* Number of Checkins vs Venue Count */
SELECT * FROM Histogram_Checkins_vs_VenueCount;

SELECT  Venue_Info.Checkins AS 'Num_of_Checkins',
		SUM(CASE WHEN Venue_Info.Country = 'GB' THEN 1 ELSE 0 END) AS 'GB_Venue_Count',
        SUM(CASE WHEN Venue_Info.Country = 'US' THEN 1 ELSE 0 END) AS 'US_Venue_Count'
FROM finalyearproject.Venue_Info AS Venue_Info
GROUP BY Venue_Info.Checkins;


/* Number of Unique Users vs Venue Count */
SELECT * FROM Histogram_UniqueUsers_vs_VenueCount;

SELECT  Venue_Info.Distinct_Users AS 'Num_of_Unique_Users',
		SUM(CASE WHEN Venue_Info.Country = 'GB' THEN 1 ELSE 0 END) AS 'GB_Venue_Count',
        SUM(CASE WHEN Venue_Info.Country = 'US' THEN 1 ELSE 0 END) AS 'US_Venue_Count'
FROM finalyearproject.Venue_Info AS Venue_Info
GROUP BY Venue_Info.Distinct_Users;


/* Number of Categories vs Venue Count */
SELECT * FROM Histogram_Categories_vs_VenueCount;

SELECT  Venue_Info.Categories AS 'Num_of_Categories',
		SUM(CASE WHEN Venue_Info.Country = 'GB' THEN 1 ELSE 0 END) AS 'GB_Venue_Count',
        SUM(CASE WHEN Venue_Info.Country = 'US' THEN 1 ELSE 0 END) AS 'US_Venue_Count'
FROM finalyearproject.Venue_Info AS Venue_Info
GROUP BY Venue_Info.Categories;


/* Number of Checkins vs Category Count */
SELECT * FROM Histogram_Checkins_vs_CategoryCount;

SELECT  Category_Info.Checkin_Count AS 'Num_of_Checkins',
		SUM(CASE WHEN Category_Info.Country = 'GB' THEN 1 ELSE 0 END) AS 'GB_Category_Count',
        SUM(CASE WHEN Category_Info.Country = 'US' THEN 1 ELSE 0 END) AS 'US_Category_Count'
FROM finalyearproject.Category_Info AS Category_Info
GROUP BY Category_Info.Checkin_Count;


/* Number of Unique Users vs Category Count */
SELECT * FROM Histogram_UniqueUsers_vs_CategoryCount;

SELECT  Category_Info.Unique_Users AS 'Num_of_Unique_Users',
		SUM(CASE WHEN Category_Info.Country = 'GB' THEN 1 ELSE 0 END) AS 'GB_Category_Count',
        SUM(CASE WHEN Category_Info.Country = 'US' THEN 1 ELSE 0 END) AS 'US_Category_Count'
FROM finalyearproject.Category_Info AS Category_Info
GROUP BY Category_Info.Unique_Users;


/* Number of Venues vs Category Count */
SELECT * FROM Histogram_Categories_vs_CategoryCount;

SELECT  Category_Info.Venue_Count AS 'Num_of_Venues',
		SUM(CASE WHEN Category_Info.Country = 'GB' THEN 1 ELSE 0 END) AS 'GB_Category_Count',
        SUM(CASE WHEN Category_Info.Country = 'US' THEN 1 ELSE 0 END) AS 'US_Category_Count'
FROM finalyearproject.Category_Info AS Category_Info
GROUP BY Category_Info.Venue_Count;



/*---------------------------------*/
/*---------------------------------*/
/* Helpers */
/*---------------------------------*/

/* General Info */
SELECT * FROM General_Info;

SELECT venue.location_cc AS 'Country',
	COUNT(checkin.id) AS 'Checkins',
    COUNT(DISTINCT(user.id)) AS 'Users',
    COUNT(DISTINCT(venue.id)) AS 'Venues'
FROM finalyearproject.checkins as checkin, finalyearproject.users as user, finalyearproject.venues as venue
WHERE checkin.venueid = venues.id AND checkin.userid = user.id
GROUP BY venue.location_cc;


/* User Country Gender Table */
SELECT * FROM User_Country_Gender;

SELECT user.id AS 'id',
	venue.location_cc AS 'Country',
    user.gender AS 'Gender'
FROM finalyearproject.checkins as checkin, finalyearproject.users as user, finalyearproject.venues as venue
WHERE checkin.venueid = venue.id AND checkin.userid = user.id
GROUP BY user.id;


/* Venue Category Issue */

SELECT COUNT(*) as repetitions, venuecategories.venue, venuecategories.category
FROM finalyearproject.venuecategories
GROUP BY venuecategories.venue, venuecategories.category
HAVING repetitions > 1;

CREATE TABLE finalyearproject.tmp SELECT venuecategories.venue, venuecategories.category, venuecategories.primary
FROM finalyearproject.venuecategories
GROUP BY venuecategories.venue, venuecategories.category;

DROP TABLE finalyearproject.venuecategories;

ALTER TABLE finalyearproject.tmp RENAME TO finalyearproject.venuecategories;

/* Improve performance speed of Venue_Info */
ALTER TABLE finalyearproject.venuecategories ADD INDEX (venue);

SELECT table_schema                                        "DB Name", 
   Round(Sum(data_length + index_length) / 1024 / 1024, 1) "DB Size in MB" 
FROM   information_schema.tables 
GROUP  BY table_schema; 
