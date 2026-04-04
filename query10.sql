/*
You're tasked with giving more contextual information to rail stops 
to fill the stop_desc field in a GTFS feed. Using any of the data 
sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), 
and PostgreSQL string functions, build a description (alias as stop_desc) 
for each stop. Feel free to supplement with other datasets 
(must provide link to data used so it's reproducible), and other 
methods of describing the relationships. SQL's CASE statements may 
be helpful for some operations.
*/

select
    stops.stop_id,
    stops.stop_name,
    concat(
        round(
            st_distance(
                st_makepoint(stops.stop_lon, stops.stop_lat)::geography,
                neighborhoods.geog
            )::numeric
        ),
        ' meters ',
        case
            when degrees(st_azimuth(
                st_setsrid(st_makepoint(stops.stop_lon, stops.stop_lat), 4326),
                st_centroid(st_setsrid(neighborhoods.geog::geometry, 4326))
            )) < 22.5 then 'N'
            when degrees(st_azimuth(
                st_setsrid(st_makepoint(stops.stop_lon, stops.stop_lat), 4326),
                st_centroid(st_setsrid(neighborhoods.geog::geometry, 4326))
            )) < 67.5 then 'NE'
            when degrees(st_azimuth(
                st_setsrid(st_makepoint(stops.stop_lon, stops.stop_lat), 4326),
                st_centroid(st_setsrid(neighborhoods.geog::geometry, 4326))
            )) < 112.5 then 'E'
            when degrees(st_azimuth(
                st_setsrid(st_makepoint(stops.stop_lon, stops.stop_lat), 4326),
                st_centroid(st_setsrid(neighborhoods.geog::geometry, 4326))
            )) < 157.5 then 'SE'
            when degrees(st_azimuth(
                st_setsrid(st_makepoint(stops.stop_lon, stops.stop_lat), 4326),
                st_centroid(st_setsrid(neighborhoods.geog::geometry, 4326))
            )) < 202.5 then 'S'
            when degrees(st_azimuth(
                st_setsrid(st_makepoint(stops.stop_lon, stops.stop_lat), 4326),
                st_centroid(st_setsrid(neighborhoods.geog::geometry, 4326))
            )) < 247.5 then 'SW'
            when degrees(st_azimuth(
                st_setsrid(st_makepoint(stops.stop_lon, stops.stop_lat), 4326),
                st_centroid(st_setsrid(neighborhoods.geog::geometry, 4326))
            )) < 292.5 then 'W'
            when degrees(st_azimuth(
                st_setsrid(st_makepoint(stops.stop_lon, stops.stop_lat), 4326),
                st_centroid(st_setsrid(neighborhoods.geog::geometry, 4326))
            )) < 337.5 then 'NW'
            else 'N'
        end,
        ' of ',
        neighborhoods.listname,
        ' neighborhood'
    ) as stop_desc,
    stops.stop_lon,
    stops.stop_lat
from septa.rail_stops as stops
cross join lateral (
    select
        listname,
        geog
    from phl.neighborhoods
    order by st_makepoint(stops.stop_lon, stops.stop_lat)::geography <-> geog
    limit 1
) as neighborhoods
