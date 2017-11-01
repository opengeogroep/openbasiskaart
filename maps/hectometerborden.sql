create or replace view hectometerborden as
select 
    h.gid,
    routeltr || routenr as wegnummer,
    replace(trim(to_char(hectomtrng / 10.0, '990.0')),'.',',') as hectometer,
    case pos_tv_wol when 'L' then 'Li' when 'R' then 'Re' else null end as positie,
    dvk_letter as letter,
    h.geom
from nwb_datum.hectopunten h

-- if not exists since PostgreSQL 9.5
create table if not exists hmb_10k (gid serial, wegnummer varchar, hectometer varchar, geom geometry(Point,28992));
create index if not exists idx_hmb_10k on hmb_10k using gist(geom);
create table if not exists hmb_1k (gid serial, wegnummer varchar, hectometer varchar, geom geometry(Point,28992));
create index if not exists idx_hmb_1k on hmb_1k using gist(geom);
create table if not exists hmb_500m (gid serial, wegnummer varchar, hectometer varchar, geom geometry(Point,28992));
create index if not exists idx_hmb_500m on hmb_500m using gist(geom);
create table if not exists hmb_200m (gid serial, wegnummer varchar, hectometer varchar, geom geometry(Point,28992));
create index if not exists idx_hmb_200m on hmb_200m using gist(geom);

truncate hmb_10k;
insert into hmb_10k(wegnummer,hectometer,geom)    
    select wegnummer,hectometer,st_centroid(st_collect(geom)) as geom
    from hectometerborden
    where right(hectometer,3) = '0,0' and letter is null
    group by wegnummer, hectometer;
    
truncate hmb_1k;    
insert into hmb_1k(wegnummer,hectometer,geom)    
    select wegnummer,hectometer,st_centroid(st_collect(geom)) as geom
    from hectometerborden
    where right(hectometer,1) = '0' and letter is null
    group by wegnummer, hectometer;

truncate hmb_500m;
insert into hmb_500m(wegnummer,hectometer,geom)    
    select wegnummer,hectometer,st_centroid(st_collect(geom)) as geom
    from hectometerborden
    where right(hectometer,1) in ('0', '5') and letter is null
    group by wegnummer, hectometer;

truncate hmb_200m;
insert into hmb_200m(wegnummer,hectometer,geom)    
    select wegnummer,hectometer,st_centroid(st_collect(geom)) as geom
    from hectometerborden
    where right(hectometer,1) in ('0', '2', '4', '6', '8') and letter is null
    group by wegnummer, hectometer;
    
   
/* When working on mapfile, use (slow) views instead of table like:

CREATE OR REPLACE VIEW public.v_hmb_10k AS 
 SELECT f.wegnummer,
    f.hectometer,
    f.geom,
    row_number() OVER () AS gid
   FROM ( SELECT hectometerborden.wegnummer,
            hectometerborden.hectometer,
            st_centroid(st_collect(hectometerborden.geom)) AS geom
           FROM hectometerborden
          WHERE "right"(hectometerborden.hectometer, 3) = '0,0'::text AND hectometerborden.letter IS NULL
          GROUP BY hectometerborden.wegnummer, hectometerborden.hectometer) f;
*/

