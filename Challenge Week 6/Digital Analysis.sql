--1. How many users are there?--
SELECT COUNT(DISTINCT user_id)
FROM clique_bait.users

--2. How many cookies does each user have on average?--
SELECT COUNT(cookie_id)/COUNT(DISTINCT user_id)
FROM clique_bait.users

--3. What is the unique number of visits by all users per month?--
SELECT COUNT(cookie_id) as count_visit,DATE_PART('month',start_date)
FROM clique_bait.users
GROUP BY DATE_PART('month',start_date)
ORDER BY 2

--4. What is the number of events for each event type?--
SELECT event_name,COUNT(event_time)
FROM clique_bait.events
JOIN clique_bait.event_identifier
USING (event_type)
GROUP BY 1
