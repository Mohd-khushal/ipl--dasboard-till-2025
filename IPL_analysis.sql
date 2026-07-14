create database ipl_matches_analysis;
use ipl_matches_analysis;

# 1. Verify Row Count and Data Sample
-- Count total records
SELECT COUNT(*) FROM matches;

-- Preview first 10 rows
SELECT * FROM matches LIMIT 10;

# 2. Team Performance Summary
-- Overall win percentage for each team (including all matches where they played)
WITH team_matches AS (
    SELECT team1 AS team, match_winner FROM matches
    UNION ALL
    SELECT team2 AS team, match_winner FROM matches
)
SELECT 
    team,
    COUNT(*) AS matches_played,
    SUM(CASE WHEN team = match_winner THEN 1 ELSE 0 END) AS wins,
    ROUND(100.0 * SUM(CASE WHEN team = match_winner THEN 1 ELSE 0 END) / COUNT(*), 2) AS win_pct
FROM team_matches
WHERE match_winner IS NOT NULL   -- exclude no‑result games
GROUP BY team
ORDER BY win_pct DESC;

# 3. Toss Impact Analysis
-- Overall toss winner win percentage
SELECT 
    ROUND(100.0 * AVG(toss_winner_won), 2) AS overall_toss_win_pct
FROM matches
WHERE toss_winner_won IS NOT NULL;

-- Toss decision preference and success rate
SELECT 
    toss_decision,
    COUNT(*) AS decisions,
    ROUND(100.0 * AVG(toss_winner_won), 2) AS win_pct_when_choosing
FROM matches
WHERE toss_decision IS NOT NULL AND toss_winner_won IS NOT NULL
GROUP BY toss_decision;

# 4. Home Advantage
WITH home_matches AS
(
    SELECT
        CASE
            WHEN team1_is_home = 1 THEN team1
            WHEN team2_is_home = 1 THEN team2
        END AS home_team,
        match_winner
    FROM matches
)

SELECT
    home_team,
    COUNT(*) AS home_matches,
    SUM(CASE WHEN home_team = match_winner THEN 1 ELSE 0 END) AS home_wins,
    ROUND(
        100.0 * SUM(CASE WHEN home_team = match_winner THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS home_win_pct
FROM home_matches
WHERE home_team IS NOT NULL
  AND match_winner IS NOT NULL
GROUP BY home_team
ORDER BY home_win_pct DESC;

# 5. Venue Intelligence
-- Most frequent venues
SELECT venue, COUNT(*) AS matches_played
FROM matches
GROUP BY venue
ORDER BY matches_played DESC
LIMIT 10;

-- Top teams at Wankhede (as an example)
SELECT match_winner, COUNT(*) AS wins
FROM matches
WHERE venue = 'Wankhede Stadium' AND match_winner IS NOT NULL
GROUP BY match_winner
ORDER BY wins DESC;

# 6. Playoff Performance
-- Playoff wins by team
SELECT match_winner, COUNT(*) AS playoff_wins
FROM matches
WHERE is_playoff = 1 AND match_winner IS NOT NULL
GROUP BY match_winner
ORDER BY playoff_wins DESC;

# 7. Seasonal Trends
-- Matches per season
SELECT season_year, COUNT(*) AS total_matches
FROM matches
GROUP BY season_year
ORDER BY season_year;

-- Team that won most matches per season (optional)
SELECT season_year, match_winner, COUNT(*) AS wins
FROM matches
WHERE match_winner IS NOT NULL
GROUP BY season_year, match_winner
ORDER BY season_year, wins DESC;

# 8. Result Type Distribution
SELECT result, COUNT(*) AS count
FROM matches
GROUP BY result;

# 9. Win Margin Patterns
-- Average win margin (runs) for matches won by runs
SELECT round(AVG(win_margin),2) AS avg_runs_win
FROM matches
WHERE win_type = 'by runs' AND win_margin IS NOT NULL;

-- Average win margin (wickets) for matches won by wickets
SELECT AVG(win_margin) AS avg_wickets_win
FROM matches
WHERE win_type = 'by wickets' AND win_margin IS NOT NULL;

# 10 Top Winning Teams
SELECT
    match_winner,
    COUNT(*) AS total_wins
FROM matches
WHERE match_winner IS NOT NULL
GROUP BY match_winner
ORDER BY total_wins DESC;

# 11 Teams Losing Most Matches
WITH team_matches AS
(
SELECT team1 AS team FROM matches
UNION ALL
SELECT team2 FROM matches
)

SELECT
    tm.team,
    COUNT(*) - SUM(CASE WHEN tm.team = m.match_winner THEN 1 ELSE 0 END) AS losses
FROM team_matches tm
JOIN matches m
ON tm.team IN (m.team1,m.team2)
GROUP BY tm.team
ORDER BY losses DESC;

# 12 Toss Decision by Season
SELECT
season_year,
toss_decision,
COUNT(*) AS total
FROM matches
GROUP BY season_year,toss_decision
ORDER BY season_year;

# 13. Team Winning After Losing Toss
SELECT
match_winner,
COUNT(*) AS wins_after_losing_toss
FROM matches
WHERE toss_winner<>match_winner
GROUP BY match_winner
ORDER BY wins_after_losing_toss DESC;

# 14. Team Winning After Winning Toss
SELECT
match_winner,
COUNT(*) AS wins_after_winning_toss
FROM matches
WHERE toss_winner=match_winner
GROUP BY match_winner
ORDER BY wins_after_winning_toss DESC;

# 15. Best Home Team
SELECT
CASE
WHEN team1_is_home=1 THEN team1
WHEN team2_is_home=1 THEN team2
END AS home_team,
COUNT(*) matches,
SUM(
CASE
WHEN match_winner=
CASE
WHEN team1_is_home=1 THEN team1
WHEN team2_is_home=1 THEN team2
END
THEN 1 ELSE 0 END
) wins
FROM matches
GROUP BY home_team
ORDER BY wins DESC;

# 16. Most Successful Venue
SELECT
venue,
COUNT(*) matches
FROM matches
GROUP BY venue
ORDER BY matches DESC;

# 17. Venue Producing Most Close Matches
SELECT
venue,
COUNT(*) close_matches
FROM matches
WHERE win_margin<=10
GROUP BY venue
ORDER BY close_matches DESC;

# 18. Largest Wins by Runs
SELECT
season_year,
team1,
team2,
match_winner,
win_margin
FROM matches
WHERE win_type='by runs'
ORDER BY win_margin DESC
LIMIT 20;

# 19. Largest Wins by Wickets
SELECT
season_year,
team1,
team2,
match_winner,
win_margin
FROM matches
WHERE win_type='by wickets'
ORDER BY win_margin DESC
LIMIT 20;

# 20. Average Winning Margin Per Season
SELECT
season_year,
ROUND(AVG(win_margin),2) avg_margin
FROM matches
GROUP BY season_year
ORDER BY season_year;

# 21. Team Appearing Most in Playoffs
WITH playoff AS
(
SELECT team1 team
FROM matches
WHERE is_playoff=1
UNION ALL
SELECT team2
FROM matches
WHERE is_playoff=1
)

SELECT
team,
COUNT(*) appearances
FROM playoff
GROUP BY team
ORDER BY appearances DESC;

# 22. Finals Played
WITH finals AS
(
SELECT team1 team
FROM matches
WHERE stage='Final'
UNION ALL
SELECT team2
FROM matches
WHERE stage='Final'
)

SELECT
team,
COUNT(*) finals
FROM finals
GROUP BY team
ORDER BY finals DESC;

# 23. IPL Champions
SELECT
season_year,
match_winner champion
FROM matches
WHERE stage='Final'
ORDER BY season_year;




# 24. Team Winning Percentage By Season
SELECT
season_year,
match_winner,
COUNT(*) wins
FROM matches
WHERE match_winner IS NOT NULL
GROUP BY season_year,match_winner
ORDER BY season_year,wins DESC

# 25. Running Total Wins (Window Function)
SELECT
season_year,
match_winner,
COUNT(*) wins,
SUM(COUNT(*)) OVER(
PARTITION BY match_winner
ORDER BY season_year
) cumulative_wins
FROM matches
WHERE match_winner IS NOT NULL
GROUP BY season_year,match_winner;

# 26. Rank Teams Every Season
SELECT *
FROM
(
SELECT
season_year,
match_winner,
COUNT(*) wins,
RANK() OVER(
PARTITION BY season_year
ORDER BY COUNT(*) DESC
) rnk
FROM matches
WHERE match_winner IS NOT NULL
GROUP BY season_year,match_winner
)t
WHERE rnk<=5;

# 27 Best Toss Win Percentage
SELECT
toss_winner,
COUNT(*) tosses,
SUM(toss_winner_won) wins,
ROUND(AVG(toss_winner_won)*100,2) percentage
FROM matches
GROUP BY toss_winner
ORDER BY percentage DESC;

# 31. Most Matches Played
WITH allteams AS
(
SELECT team1 team FROM matches
UNION ALL
SELECT team2 FROM matches
)

SELECT
team,
COUNT(*) matches_played
FROM allteams
GROUP BY team
ORDER BY matches_played DESC;

# 32. Matches Per City
SELECT
city,
COUNT(*) matches
FROM matches
GROUP BY city
ORDER BY matches DESC;

# 33. Day vs Night Matches
SELECT
match_type,
COUNT(*) total_matches
FROM matches
GROUP BY match_type;

# 34. Win Percentage by Batting First
SELECT
ROUND(
100*SUM(CASE WHEN toss_decision='field' THEN 1 ELSE 0 END)
/COUNT(*),2
) batting_first_win_percentage
FROM matches;

# 35. Win Percentage by Chasing
SELECT
ROUND(
100*SUM(CASE WHEN toss_decision='bat' THEN 1 ELSE 0 END)
/COUNT(*),2
) chasing_win_percentage
FROM matches;