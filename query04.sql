/*
Using the bus_shapes, bus_routes, and bus_trips tables from 
GTFS bus feed, find the two routes with the longest trips.
*/

with

trip_shapes as (
    select
        shape_id,
        st_makeline(
            st_makepoint(shape_pt_lon, shape_pt_lat)::geography::geometry
            order by shape_pt_sequence
        ) as shape_geom
    from septa.bus_shapes
    group by shape_id
),

trip_lengths as (
    select
        trips.route_id,
        trips.trip_headsign,
        st_length(shapes.shape_geom::geography) as shape_length,
        row_number() over (
            partition by trips.route_id
            order by st_length(shapes.shape_geom::geography) desc
        ) as rn
    from septa.bus_trips as trips
    inner join trip_shapes as shapes using (shape_id)
)

select
    routes.route_short_name,
    lengths.trip_headsign,
    round(lengths.shape_length) as shape_length
from trip_lengths as lengths
inner join septa.bus_routes as routes using (route_id)
where lengths.rn = 1
order by lengths.shape_length desc
limit 2
