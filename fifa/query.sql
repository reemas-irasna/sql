select * from matches

/*q1-top team goal scorer */

/* create temp table to get sum of home goals*/
create TEMPORARY table H as
select h_team, sum(h_team_goals) as sum_h from matches
group by h_team
order by sum_h desc

select * from h
order by sum_h desc

/* create temp table to get sum of away goals*/
create TEMPORARY table A as
select a_team, sum(a_team_goals) as sum_a from matches
group by a_team
order by sum_a desc

select * from a

/* join both home and away goals to get total goals*/
select h.h_team as team, (h.sum_h + a.sum_a) as total_goals from h
Inner join a
ON h.h_team = a.a_team
order by total_goals desc
limit 5

/*q2- percent of team wins in its home */

/* extracrt get number of home goals only */

create temporary table h_g as
select m.match_id, m.h_team, m.h_team_goals, m.a_team_goals,
(case
	when(m.h_team_goals > m.a_team_goals) then 1 else 0
end) as num from matches m

select * from h_g

/* Calculate for percentage */
select h_team, sum(num) *100 / count(num) as prcnt from h_g
group by h_team
order by prcnt desc 
limit 10

/*q3- highest crowd for a team */

/* get max crowd number for every year */
create temporary table max_attnd as
select years, max(attendance) as max_att from matches
group by years
order by max_att

select * from max_attnd

/* join to get respective data */
select a.years,a.attendance, a.stadium, a.city,a.stage,
a.h_team as home_team, a.a_team as away_team
from matches as a
inner join max_attnd as b
on a.attendance = b.max_att
order by attendance desc
limit 10

/*q4- goals inreased year by year*/

/* calculate home goals for every year */

create TEMPORARY table x1 as
select years, sum(h_team_goals) as sum_h from matches
group by years
order by sum_h desc

select * from x1

/* calculate away goals for every year */

create TEMPORARY table x2 as
select years, sum(a_team_goals) as sum_a from matches
group by years
order by sum_a desc

select * from x2

/* join to  get total goals for every year*/

select x1.years as years, x1.sum_h, x2.sum_a, (x1.sum_h + x2.sum_a) as total_goals from x1
Inner join x2
ON x1.years= x2.years
order by years 

/*q5-under which captain team has win the most matches */

/* check whether match is win, lost or draw */

create temporary table t1 as
select m.match_id, m.h_team, m.h_team_goals, m.a_team_goals,
(case
	when(m.h_team_goals > m.a_team_goals) then m.h_team 
 	when(m.h_team_goals < m.a_team_goals) then m.a_team
	else 'draw'	
end) as num from matches m

select * from t1

/*import data fro players and display*/

select * from players

/*join to get winning captains*/

create temporary table cap as
select t1.num, players.team_initials, t1.match_id, players.player_name, players.position from t1
inner join players
on t1.match_id = players.match_id
where position='C' 

select * from cap

/* extract the winning teams, captains name, and its count */

create temporary table aa as
select q1.match_id, q1.h_team, q1.a_team,
(case
	when(q1.h_team = t1.num) then q1.h_team_initials
 	when(q1.a_team = t1.num) then q1.a_team_initials
end) as team from matches q1
inner join t1
on q1.match_id = t1.match_id

select * from aa

create temporary table win_capt as
select cap.match_id, aa.h_team, aa.a_team, aa.team as winner, cap.player_name as captain_name from cap
inner join aa
on cap.match_id=aa.match_id
where aa.team = cap.team_initials
order by match_id

select * from win_capt

create temporary table captain as
select wc.match_id, matches.years, wc.h_team, wc.a_team,wc.winner, wc.captain_name as capt from win_capt wc
inner join matches
on wc.match_id = matches.match_id
order by matches.years

select * from captain

select captain.capt as captain, captain.winner as team, count(captain.winner) as matches_win from captain
group by captain.capt, captain.winner
order by matches_win desc
limit 10




