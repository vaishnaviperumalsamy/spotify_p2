-- Advance sql project-- spotify datasets

-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255), primary key
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- EDA
SELECT COUNT(*) 
FROM SPOTIFY;

SELECT COUNT(DISTINCT artist)
FROM SPOTIFY;

SELECT COUNT(DISTINCT album)
FROM SPOTIFY;

SELECT DISTINCT album_type
FROM SPOTIFY;

SELECT MAX(duration_min) FROM SPOTIFY;
SELECT MIN(duration_min) FROM SPOTIFY;

SELECT * FROM SPOTIFY
WHERE DURATION_MIN = 0

DELETE FROM SPOTIFY
WHERE DURATION_MIN = 0

SELECT DISTINCT CHANNEL FROM SPOTIFY;
SELECT DISTINCT  most_played_on FROM SPOTIFY;

SELECT * FROM SPOTIFY
WHERE most_played_on  = NULL

/*
- -------------------------------
-- Data analysis - Easy category
-- ------------------------------

Retrieve the names of all tracks that have more than 1 billion streams.
List all albums along with their respective artists.
Get the total number of comments for tracks where licensed = TRUE.
Find all tracks that belong to the album type single.
Count the total number of tracks by each artist.
*/

--1.Retrieve the names of all tracks that have more than 1 billion streams.
select 
 track from spotify
where stream > 1000000000;

--2.List all albums along with their respective artists.
select distinct album, artist
from spotify
order by 1;

--select distinct album
--from spotify

--3.Get the total number of comments for tracks where licensed = TRUE.
SELECT SUM(comments) AS total_comments
FROM spotify
WHERE licensed = TRUE;

--4.Find all tracks that belong to the album type single.
select track from spotify
where album_type = 'single';

--5.Count the total number of tracks by each artist.
select artist,
      count(track) as total_no_songs
from spotify
group by artist
order by 2 desc;

/*
- -------------------------------
-- Data analysis - Medium Level
-- ------------------------------
Calculate the average danceability of tracks in each album.
Find the top 5 tracks with the highest energy values.
List all tracks along with their views and likes where official_video = TRUE.
For each album, calculate the total views of all associated tracks.
Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

--6.Calculate the average danceability of tracks in each album.

select 
        album,
       avg(danceability)
from spotify
group by 1
order by 2 desc

--7.Find the top 5 tracks with the highest energy values.
select
     track, 
	 max(energy)
from spotify
group by 1
order by 2 desc
limit 5;

--8.List all tracks along with their views and likes where official_video = TRUE.

SELECT 
      track,
	  sum(views)as total_views,
	  sum(likes)as total_likes
FROM spotify
where official_video = TRUE
group by track
order by 2 desc

--9.For each album, calculate the total views of all associated tracks.
select
    album,
    track,
	sum(views) as total_views
from spotify
group by 1,2
order by 3 DESC;

--10.Retrieve the track names that have been streamed on Spotify more than YouTube.
select * from
(select track,
       coalesce(sum(case when most_played_on ='youtube' then stream end),0) as streamed_on_youtube,
	   coalesce(sum(case when most_played_on ='spotify' then stream end),0) as streamed_on_spotify
from spotify
group by 1
) as t1
where streamed_on_spotify > streamed_on_youtube
and streamed_on_youtube <> 0

/*
- -----------------------------------
-- Data analysis - Advance problems
-- ----------------------------------
Find the top 3 most-viewed tracks for each artist using window functions.
Write a query to find tracks where the liveness score is above the average.
Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
Find tracks where the energy-to-liveness ratio is greater than 1.2.
Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

*/
--11. Find the top 3 most-viewed tracks for each artist using window functions.
--track with highest view for each artist ( we need top)
-- dense rank
-- cte and filter rank <=3

with ranking_artist
as	
	(SELECT 
        artist,
        track,
        sum(views) as total_views,
        dense_RANK() OVER (PARTITION BY artist ORDER BY sum(views) DESC) AS rank
    FROM spotify
group by 1,2
order by 1,3 desc
)
select * from ranking_artist
where rank <=3
--top 3 most-commented albums for each artist using a window function.
With most_commented_album 
AS
(Select
     artist, 
	 Album, 
	 sum(comments) as total_comments,
	 Dense_rank() over(partition by artist ORDER BY sum(comments) desc) as rank 
	 From spotify
	 Group by 1,2 
	 ) 
	 Select * from most_commented_album
	 Where rank <=3
	  Order by 1,3 desc 

--12.Write a query to find tracks where the liveness score is above the average.
-- select avg(liveness) from spotify -- 0.19

select track,
       artist,
	   liveness
from spotify
where liveness > ( select avg(liveness) from spotify )
order by liveness desc

--Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

with cte
as
(select 
       album,
	   max(energy) as highest_energy,
	   min(energy) as lowest_energy
from spotify
group by 1)
select 
       album,
	   highest_energy - lowest_energy as energy_diff
from cte
order by energy_diff desc

--14.Find tracks where the energy-to-liveness ratio is greater than 1.2
select 
     track,
	 energy,
	 liveness,
	 energy/liveness as energy_liveness_ratio
from spotify
where (energy / liveness) > 1.2;

--15.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
select
     artist,
	 track,
	 likes,
	 views,
	 sum(likes) over(partition by artist order by views) as cumulative_likes
from spotify
order by artist, views

--END
	 