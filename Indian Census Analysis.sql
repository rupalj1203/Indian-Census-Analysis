-- Reading data 

select * 
from data1;
select *
from data2;

-- number of rows into our dataset

select count(*) 
from data1;
select count(*) 
from data2;

-- dataset for jharkhand and bihar

select * 
from data1 
where state in ('Jharkhand' ,'Bihar');

-- population of India

select sum(population) as Population 
from data2;

-- average growth 

select state,avg(growth)*100 as avg_growth 
from data1 
group by state;

-- average sex ratio

select state,round(avg(sex_ratio),0) as avg_sex_ratio 
from data1 
group by state 
order by avg_sex_ratio desc;

-- average literacy rate greater than 90 

select state,round(avg(literacy),0)  as avg_literacy_ratio 
from data1 
group by state 
having avg_literacy_ratio > 90 
order by avg_literacy_ratio desc ;

-- top 3 state showing highest growth ratio

select state,avg(growth)*100  as avg_growth 
from data1 
group by state 
order by avg_growth desc 
limit 3;

-- bottom 3 state showing lowest sex ratio

select state,round(avg(Sex_Ratio),0) as avg_sex_ratio 
from data1 
group by state 
order by avg_sex_ratio asc 
limit 3;

-- top and bottom 3 states in literacy state

drop table if exists top_states;
create table top_states(
State varchar(100),
topstates float
);
insert into top_states
select state,round(avg(Literacy),0) as avg_literacy 
from data1 
group by state 
order by avg_literacy desc ;

select * 
from top_states 
limit 3;

drop table if exists bottom_states;
create table bottom_states(
State varchar(100),
bottomstates float
);
insert into bottom_states
select state,round(avg(Literacy),0) as avg_literacy 
from data1 
group by state 
order by avg_literacy asc ;

select * 
from bottom_states 
limit 3;


-- States starting with letter a 

select distinct State 
from data1 
where lower(State) like 'a%' ;

-- Total males and females

With c as 
          (select a.District , a.State , a.Sex_Ratio/1000 as Sex_Ratio , b.Population 
           from data1 as a 
		   inner join data2 as b 
           on a.District = b.District) ,
	 d as 
          (select c.District , c.State , round( c.Population/(c.Sex_Ratio + 1),0) as males , round((c.Population*c.Sex_Ratio)/(c.Sex_Ratio + 1),0) as females 
           from c)
           
select d.State , sum(d.males) Total_males , sum(d.females) Total_females 
from d 
group by d.State;

-- Total Literate & Illiterate

With c as 
          (select a.District , a.State , a.Literacy/100 as Literacy_ratio , b.Population 
		   from data1 as a 
           inner join data2 as b 
           on a.District = b.District) ,
	 d as 
          (select c.District , c.State , round(c.Literacy_ratio*c.Population,0) as Literate_people , round((1-c.Literacy_ratio)*c.Population,0) as Illiterate_people  
           from c)
select d.State , sum(d. Literate_people) as Total_Literate , sum(d. Illiterate_people) as Total_Illiterate 
from d 
group by d.State;

 -- Population in previous census
 
With c as 
          (select a.District , a.State , a.Growth as growth , b.Population 
           from data1 as a 
           inner join data2 as b 
           on a.District = b.District) ,
	 d as 
          (select c.District , c.State , round(c.Population/(1+c.Growth),0) previous_census_population,c.Population current_census_population  
           from c) ,
     e as
          (select d.State , sum(d.previous_census_population) as previous_census_population ,sum(d.current_census_population ) as current_census_population  
           from d
           group by d.State)
           
select sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population 
from e;

-- Population v/s Area

select g.total_area/g.previous_census_population as previous_census_population_vs_area , g.total_area/g.current_census_population as current_census_population_vs_area from
(select q.* , r.total_area from 
(select '1' as keyy ,n.* from
(select sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.State , sum(d.previous_census_population) as previous_census_population ,sum(d.current_census_population ) as current_census_population  from
(select c.District , c.State , round(c.Population/(1+c.Growth),0) previous_census_population,c.Population current_census_population from
(select a.District , a.State , a.Growth as growth , b.Population 
from data1 as a inner join data2 as b 
on a.District = b.District) c) d
group by d.State) e) n ) as q 
inner join
(select '1' as keyy , m.* from
(select sum(Area_km2) as total_area 
from data2) m ) as r 
on q.keyy=r.keyy) as g ;

-- Top 3 district  from each State with highest literacy rate 

select a.* from
      (select District , State , Literacy,
       rank() over(
                   partition by State 
                   order by Literacy desc ) rnk 
	   from data1) a
where rnk in (1,2,3) 
order by State;


 





























