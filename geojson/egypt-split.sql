INSTALL spatial;
INSTALL osmium FROM community;

LOAD osmium;
LOAD spatial;
.prompt '> ' '. '

CREATE TABLE osm_egypt as SELECT * FROM st_readosm('/Users/skozyr/Projects/OSM/duckdb/egypt-260420.osm.pbf');


select * From osm_egypt where kind = 'relation' and tags['type']='boundary' and tags['admin_level'] = '4';

select *
  from '/Users/skozyr/Projects/OSM/duckdb/egypt-260420.osm.pbf'
 where id = 3061757;

 select kind, tags['name:en'] as name, tags['type'] as ref_type, tags['admin_level'] as admin_level
   from '/Users/skozyr/Projects/OSM/duckdb/egypt-260420.osm.pbf'
  where id = 3061757;

select kind, tags['name:en'] as name, tags['type'] as ref_type, tags['admin_level'] as admin_level
  from '/Users/skozyr/Projects/OSM/duckdb/egypt-260420.osm.pbf'
 where tags['type'] = 'boundary' and tags['admin_level'] = '4';


select *
  from '/Users/skozyr/Projects/OSM/duckdb/egypt-260420.osm.pbf'
 where type = 'relation' and tags['type']='boundary' and tags['admin_level'] = '4';


COPY (
  select kind, tags['type'] as rel_type, tags['admin_level'] as admin_level, tags['name:en'] as name, geometry
    from '/Users/skozyr/Projects/OSM/duckdb/egypt-260420.osm.pbf'
   where kind = 'area' and tags['type'] = 'boundary' and tags['admin_level']=4
) TO 'buildings.geojson' WITH (FORMAT GDAL, DRIVER GeoJSON);

COPY (
select kind, tags['name:en'] as name, tags['type'] as ref_type, tags['admin_level'] as admin_level, geometry
  from '/Users/skozyr/Projects/OSM/duckdb/egypt-260420.osm.pbf'
 where tags['type'] = 'boundary' and tags['admin_level'] = '4'
) TO 'borders.geojson' WITH (FORMAT GDAL, DRIVER GeoJSON, LAYER_CREATION_OPTIONS 'ID_FIELD=id');

-- Egypt top:

COPY (

WITH top_egypt_relation as (
 select id, unnest(refs) as child_ref, unnest(ref_roles) as role
   from osm_egypt
  where id = 1473947
),
egypt_region_ids as (
 select child_ref as region_id
   from top_egypt_relation
  where role = 'subarea'
),
egypt_regions as (
 select id, kind, tags['name:en'] as label, geometry
   from '/Users/skozyr/Projects/OSM/duckdb/egypt-260420.osm.pbf'
  where id in ( select region_id from egypt_region_ids )
),
objects as (
 select id, geometry
   from '/Users/skozyr/Projects/OSM/duckdb/egypt-260420.osm.pbf'
  where kind in ('line', 'node', 'area')
),
objects_by_region as (
SELECT egypt_regions.id, egypt_regions.label, count(objects.*) as num_objects, egypt_regions.geometry
  FROM egypt_regions
  JOIN objects on ST_Intersects(egypt_regions.geometry, objects.geometry)
 GROUP BY egypt_regions.id, egypt_regions.label, egypt_regions.geometry
)

select id, id as osm_id, label, '#312E81' as fill, (num_objects*0.8/973570) as "fill-opacity",
       num_objects, round(100 * num_objects / 5716441, 0) as percent, geometry
from objects_by_region

) TO 'borders.geojson' WITH (FORMAT GDAL, DRIVER GeoJSON, LAYER_CREATION_OPTIONS 'ID_FIELD=id');


select kind, count(*)
  from '/Users/skozyr/Projects/OSM/duckdb/egypt-260420.osm.pbf'
  where kind in ('line', 'node', 'area')
  group by kind;

-----------------
-- New regions V1

DROP TABLE IF EXISTS region_to_mwm;
CREATE TABLE region_to_mwm AS (
  SELECT *
    FROM VALUES
    ('3060792', 'Zone B'),
    ('3060793', 'Zone B'),
    ('3061757', 'Zone C'),
    ('3061758', 'Zone C'),
    ('3061826', 'Zone A'),
    ('3061827', 'Zone C'),
    ('3061846', 'Zone A'),
    ('3062184', 'Zone B'),
    ('3062185', 'Zone B'),
    ('3584607', 'Zone A'),
    ('3726124', 'Zone D'),
    ('3726170', 'Zone D'),
    ('3726175', 'Zone D'),
    ('3726184', 'Zone C'),
    ('3726186', 'Zone C'),
    ('3726189', 'Zone C'),
    ('3726211', 'Zone C'),
    ('3824206', 'Zone D'),
    ('3824207', 'Zone A'),
    ('3824513', 'Zone A'),
    ('4103336', 'Zone D'),
    ('4103337', 'Zone A'),
    ('4103403', 'Zone A'),
    ('4103404', 'Zone A'),
    ('4103405', 'Zone A'),
    ('4103406', 'Zone B'),
    ('4103407', 'Zone A')
  t(region_id, mwm_group)
);

-- To GeoJson V1

COPY (

WITH top_egypt_relation as (
 select id, unnest(refs) as child_ref, unnest(ref_roles) as role
   from osm_egypt
  where id = 1473947
),
egypt_region_ids as (
 select child_ref as region_id
   from top_egypt_relation
  where role = 'subarea'
),
egypt_regions as (
 select region_to_mwm.mwm_group, ST_MemUnion_Agg(OSM.geometry) as geometry
   from '/Users/skozyr/Projects/OSM/duckdb/egypt-260420.osm.pbf' OSM
   JOIN region_to_mwm ON OSM.id = region_to_mwm.region_id
  GROUP BY region_to_mwm.mwm_group
),
objects as (
 select id, geometry
   from '/Users/skozyr/Projects/OSM/duckdb/egypt-260420.osm.pbf'
  where kind in ('line', 'node', 'area')
),
objects_by_region as (
SELECT egypt_regions.mwm_group, count(objects.*) as num_objects, egypt_regions.geometry
  FROM egypt_regions
  JOIN objects on ST_Intersects(egypt_regions.geometry, objects.geometry)
 GROUP BY egypt_regions.mwm_group, egypt_regions.geometry
)

select mwm_group, mwm_group as osm_id, mwm_group as label, '#0B6623' as fill, (num_objects*0.8/2098463) as "fill-opacity",
       num_objects, round(100 * num_objects / 5716441, 0) as percent, geometry
from objects_by_region

) TO 'borders_split_1.geojson' WITH (FORMAT GDAL, DRIVER GeoJSON, LAYER_CREATION_OPTIONS 'ID_FIELD=id');

-----------------
-- New regions V2

DROP TABLE IF EXISTS region_to_mwm;
CREATE TABLE region_to_mwm AS (
  SELECT *
    FROM VALUES
    ('3060792', 'Zone B'),
    ('3060793', 'Zone B'),
    ('3061757', 'Zone C'),
    ('3061758', 'Zone C'),
    ('3061826', 'Zone A'),
    ('3061827', 'Zone C'),
    ('3061846', 'Zone A'),
    ('3062184', 'Zone B'),
    ('3062185', 'Zone B'),
    ('3584607', 'Zone A'),
    ('3726124', 'Zone D'),
    ('3726170', 'Zone C'),
    ('3726175', 'Zone C'),
    ('3726184', 'Zone C'),
    ('3726186', 'Zone C'),
    ('3726189', 'Zone C'),
    ('3726211', 'Zone C'),
    ('3824206', 'Zone D'),
    ('3824207', 'Zone A'),
    ('3824513', 'Zone A'),
    ('4103336', 'Zone D'),
    ('4103337', 'Zone A'),
    ('4103403', 'Zone B'),
    ('4103404', 'Zone B'),
    ('4103405', 'Zone A'),
    ('4103406', 'Zone B'),
    ('4103407', 'Zone A')
  t(region_id, mwm_group)
);

-- To GeoJson

COPY (

WITH top_egypt_relation as (
 select id, unnest(refs) as child_ref, unnest(ref_roles) as role
   from osm_egypt
  where id = 1473947
),
egypt_region_ids as (
 select child_ref as region_id
   from top_egypt_relation
  where role = 'subarea'
),
egypt_regions as (
 select region_to_mwm.mwm_group, ST_MemUnion_Agg(OSM.geometry) as geometry
   from '/Users/skozyr/Projects/OSM/duckdb/egypt-260420.osm.pbf' OSM
   JOIN region_to_mwm ON OSM.id = region_to_mwm.region_id
  GROUP BY region_to_mwm.mwm_group
),
objects as (
 select id, geometry
   from '/Users/skozyr/Projects/OSM/duckdb/egypt-260420.osm.pbf'
  where kind in ('line', 'node', 'area')
),
objects_by_region as (
SELECT egypt_regions.mwm_group, count(objects.*) as num_objects, egypt_regions.geometry
  FROM egypt_regions
  JOIN objects on ST_Intersects(egypt_regions.geometry, objects.geometry)
 GROUP BY egypt_regions.mwm_group, egypt_regions.geometry
)

select mwm_group, mwm_group as osm_id, mwm_group as label, '#DAA520' as fill, (num_objects*0.8/2471279) as "fill-opacity",
       num_objects, round(100 * num_objects / 5716441, 0) as percent, geometry
from objects_by_region

) TO 'borders_split_2.geojson' WITH (FORMAT GDAL, DRIVER GeoJSON, LAYER_CREATION_OPTIONS 'ID_FIELD=id');
