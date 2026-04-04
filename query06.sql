/*
What are the top five neighborhoods according to your 
accessibility metric?
*/

select
    neighborhoods.listname as neighborhood_name,
    round(
        count(*) filter (where stops.wheelchair_boarding = 1)::numeric
        / nullif(count(*), 0) * 100,
        1
    ) as accessibility_metric,
    count(*) filter (where stops.wheelchair_boarding = 1) as num_bus_stops_accessible,
    count(*) filter (where stops.wheelchair_boarding = 2) as num_bus_stops_inaccessible
from phl.neighborhoods as neighborhoods
inner join septa.bus_stops as stops
    on st_within(stops.geog::geometry, neighborhoods.geog::geometry)
group by neighborhoods.listname
order by accessibility_metric desc
limit 5
