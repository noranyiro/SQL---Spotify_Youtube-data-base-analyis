--Spotify - Youtube Database analysis
--Creating the data table for the Spotify - Youtube data analysis
CREATE TABLE SYT (
ID INTEGER,
Artist TEXT,
Url_spotify	TEXT, 
Track	TEXT, 
Album	TEXT, 
Album_type	TEXT, 
Uri	TEXT, 
Danceability	FLOAT,
Energy	FLOAT,
Key_1	FLOAT,
Loudness	FLOAT,
Speechiness	FLOAT,
Acousticness	FLOAT,
Instrumentalness	FLOAT,
Liveness	FLOAT,
Valence	FLOAT,
Tempo	FLOAT,
Duration_ms	INT,
Url_youtube	TEXT,
Title	TEXT,
Channel	TEXT,
Views	INT,
Likes	INT,
Comments	INT,
Description	TEXT,
Licensed	BOOL,
official_video	BOOL,
Stream	INT);

-- Copying the data into the table

COPY SYT
FROM '/home/nynoresz/Spotify_Youtube.csv'
DELIMITER ',' 
CSV HEADER;

--ERROR: invalid input syntax for integer: "222640.0"
--Where: COPY syt, line 2, column duration_ms: "222640.0"
--Other ERRORs of data type, Datatype update where needed

ALTER TABLE SYT ALTER COLUMN
duration_ms TYPE FLOAT;

ALTER TABLE SYT ALTER COLUMN
views TYPE FLOAT;

ALTER TABLE SYT ALTER COLUMN
likes TYPE FLOAT;

ALTER TABLE SYT ALTER COLUMN
comments TYPE FLOAT;

ALTER TABLE SYT ALTER COLUMN
stream TYPE BIGINT;

--20718 rows affected
--COPY executed successfully

--Renaming TABLE for better identificatin
ALTER TABLE SYT 
RENAME TO Spotify_YT;

--Dropping unnecessary Columns
ALTER TABLE Spotify_YT 
DROP COLUMN description;

--Basic statistics and summary:

--total number of songs:
SELECT COUNT(*) AS total_songs FROM Spotify_YT;

--average, minimum, and maximum values of numerical columns like danceability, energy, loudness, etc.:
SELECT 
   AVG(Danceability) AS avg_danceability, 
   MIN(Energy) AS min_energy, 
   MAX(Loudness) AS max_loudness 
FROM 
  Spotify_YT;

-- finding the most viewed song and its associated details:
SELECT 
  Title, 
  Views
FROM 
  Spotify_YT
ORDER BY 
  Views DESC
LIMIT 10;

--Grouping and aggregation:

--Counting the number of songs for each artist:
SELECT 
  Artist, 
    COUNT(*) AS song_count
FROM 
  Spotify_YT
GROUP BY 
  Artist
ORDER BY 
  song_count DESC;

--Calculating the average duration and number of songs for each album type:
SELECT 
  Album_type, 
  AVG(Duration_ms) AS avg_duration, 
  COUNT(*) AS song_count
FROM 
  Spotify_YT
GROUP BY 
  Album_type;

--Determining the total views, likes, and comments for each artist:
SELECT Artist, 
        SUM(Views) AS total_views, 
        SUM(Likes) AS total_likes, 
        SUM(Comments) AS total_comments
FROM 
  Spotify_YT
GROUP BY 
  Artist
ORDER BY
  Artist ASC;

--Filtering and sorting:
--Finding songs with a danceability score greater than 0.8 and order them by energy in descending order:
SELECT 
  Artist, 
  Danceability, 
  Energy
FROM 
  Spotify_YT
WHERE 
  Danceability > 0.8
ORDER BY 
  Energy DESC;

--Retrieving licensed songs with more than 1 million views and sort them by the number of likes:
SELECT 
  Artist, 
   Title, 
   Views, 
   Likes
FROM 
  Spotify_YT
WHERE 
  Licensed = TRUE AND Views > 1000000
ORDER BY 
  Likes DESC;

--Getting the top 5 songs with the highest valence (positivity) and order them by tempo:
SELECT Track, Valence, Tempo
FROM Spotify_YT
ORDER BY Valence DESC, Tempo ASC
LIMIT 5;

--Creating groups: based on the energy of the song and counting the songs in the category
SELECT
  Track,
  Energy,
  CASE
    WHEN Energy <= 0.3 THEN 'Low Energy'
    WHEN Energy > 0.3 AND Energy <= 0.6 THEN 'Medium Energy'
    WHEN Energy > 0.6 THEN 'High Energy'
    ELSE 'Unknown'
  END AS Energy_Category
FROM
  Spotify_YT;
  
SELECT
  CASE
    WHEN Energy <= 0.3 THEN 'Low Energy'
    WHEN Energy > 0.3 AND Energy <= 0.6 THEN 'Medium Energy'
    WHEN Energy > 0.6 THEN 'High Energy'
    ELSE 'Unknown'
  END AS Energy_Category,
  COUNT(*) AS Song_Count
FROM
  Spotify_YT
GROUP BY
  Energy_Category
ORDER BY 
  Song_Count DESC;


--Creating groups: based on the danceability of the song and counting the songs in the category  
SELECT
  CASE
    WHEN Danceability <= 0.4 THEN 'Low Danceability'
    WHEN Danceability > 0.4 AND Danceability <= 0.65 THEN 'Medium Danceability'
    WHEN Danceability > 0.65 THEN 'High Danceability'
    ELSE 'Unknown'
  END AS Danceability_Category,
  COUNT(*) AS Song_Count,
  AVG (Views) AS Average_Views,
  AVG (Likes) AS Average_Likes,
  AVG (Comments) AS Average_Comments
FROM
  Spotify_YT
GROUP BY
  Danceability_Category
ORDER BY
  Song_Count DESC;
  

--counting the number of songs for each artist who have more than 5 songs in the database
SELECT 
  Artist,
  COUNT(*) AS Song_Count
FROM
  Spotify_YT
GROUP BY
  Artist
HAVING
  COUNT(*) > 5;
  
--finding artists who have more than 2 songs with an energy level greater than 0.8.
SELECT Artist, Energy,
  COUNT(*) AS Song_Count
FROM
  Spotify_YT
WHERE
  Artist IN (
    SELECT 
          Artist
    FROM 
         Spotify_YT
    WHERE 
         Energy > 0.8)
GROUP BY
  Artist,
  Energy
HAVING
  COUNT(*) > 2;


