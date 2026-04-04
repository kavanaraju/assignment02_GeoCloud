/*
With a query, find out how many census block groups Penn's main 
campus fully contains. Discuss which dataset you chose for 
defining Penn's campus.
*/

SET search_path TO public, septa, census, phl;
with penn_campus as (
    select st_convexhull(st_union(geog::geometry)) as geom
    from phl.pwd_parcels
    where owner1 ilike '%univ%penn%'
        or owner1 ilike '%univ of penn%'
)

select
    count(*) as count_block_groups
from census.blockgroups_2020 as bg, penn_campus
where st_contains(penn_campus.geom, bg.geog::geometry)