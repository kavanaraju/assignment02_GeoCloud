/*
Rate neighborhoods by their bus stop accessibility for wheelchairs. 
Use OpenDataPhilly's neighborhood dataset along with an appropriate 
dataset from the Septa GTFS bus feed. Use the GTFS documentation for 
help. Use some creativity in the metric you devise in rating neighborhoods.
*/

SET search_path TO public, septa, census, phl;
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
