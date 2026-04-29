# Reporte de Optimización: Índices de Base de Datos

## Ejemplo 1: Busqueda por Where

### Codigo:

EXPLAIN ANALYZE  
SELECT *  
FROM content.film_work  
WHERE creation_date = '2020-01-01';

### Sin Indice:

"QUERY PLAN"  
"Seq Scan on film_work  (cost=0.00..60.00 rows=10 width=105) (actual time=0.042..0.253 rows=10.00 loops=1)"  
"  Filter: (creation_date = '2020-01-01'::date)"  
"  Rows Removed by Filter: 1990"  
"  Buffers: shared hit=35"  
"Planning Time: 0.177 ms"  
"Execution Time: 0.290 ms"

### Con Indice:
1. CREATE INDEX film_work_creation_date_idx ON content.film_work(creation_date);

"QUERY PLAN"  
"Bitmap Heap Scan on film_work  (cost=4.36..26.79 rows=10 width=105) (actual time=0.745..0.748 rows=10.00 loops=1)"  
"  Recheck Cond: (creation_date = '2020-01-01'::date)"  
"  Heap Blocks: exact=1"  
"  Buffers: shared hit=1 read=2"  
"  ->  Bitmap Index Scan on film_work_creation_date_idx  (cost=0.00..4.35 rows=10 width=0) (actual time=0.707..0.707 rows=10.00 loops=1)"  
"        Index Cond: (creation_date = '2020-01-01'::date)"  
"        Index Searches: 1"  
"        Buffers: shared read=2"  
"Planning:"  
"  Buffers: shared hit=24 read=1"  
"Planning Time: 1.849 ms"  
"Execution Time: 0.778 ms"

----

## Ejemplo 2: Buscar a traves de INNER JOIN en Genero

### Codigo:

EXPLAIN ANALYZE  
SELECT *  
FROM content.film_work as fw  
INNER JOIN content.genre_film_work as gfw ON gfw.film_work_id =  fw.id  
INNER JOIN content.genre as g ON g.id = gfw.genre_id;


### Sin Indice:
1. CREATE INDEX film_work_creation_date_idx ON content.film_work(creation_date);

"QUERY PLAN"  
"Hash Join  (cost=95.85..147.45 rows=2000 width=435) (actual time=0.955..2.941 rows=2000.00 loops=1)"  
"  Hash Cond: (gfw.genre_id = g.id)"  
"  Buffers: shared hit=57"  
"  ->  Hash Join  (cost=80.00..126.26 rows=2000 width=157) (actual time=0.897..2.096 rows=2000.00 loops=1)"  
"        Hash Cond: (gfw.film_work_id = fw.id)"  
"        Buffers: shared hit=56"  
"        ->  Seq Scan on genre_film_work gfw  (cost=0.00..41.00 rows=2000 width=52) (actual time=0.009..0.200 rows=2000.00 loops=1)"  
"              Buffers: shared hit=21"  
"        ->  Hash  (cost=55.00..55.00 rows=2000 width=105) (actual time=0.869..0.870 rows=2000.00 loops=1)"  
"              Buckets: 2048  Batches: 1  Memory Usage: 298kB"  
"              Buffers: shared hit=35"  
"              ->  Seq Scan on film_work fw  (cost=0.00..55.00 rows=2000 width=105) (actual time=0.011..0.292 rows=2000.00 loops=1)"  
"                    Buffers: shared hit=35"  
"  ->  Hash  (cost=12.60..12.60 rows=260 width=278) (actual time=0.043..0.044 rows=10.00 loops=1)"
"        Buckets: 1024  Batches: 1  Memory Usage: 9kB"  
"        Buffers: shared hit=1"  
"        ->  Seq Scan on genre g  (cost=0.00..12.60 rows=260 width=278) (actual time=0.023..0.024 rows=10.00 loops=1)"  
"              Buffers: shared hit=1"  
"Planning:"  
"  Buffers: shared hit=6"  
"Planning Time: 0.398 ms"  
"Execution Time: 3.188 ms"  


### Con Indice:
1. CREATE INDEX film_work_creation_date_idx ON content.film_work(creation_date);  
2. CREATE INDEX genre_film_work_film_work_id_idx ON content.genre_film_work(film_work_id);

"QUERY PLAN"  
"Hash Join  (cost=95.85..147.45 rows=2000 width=435) (actual time=0.702..2.750 rows=2000.00 loops=1)"  
"  Hash Cond: (gfw.genre_id = g.id)"  
"  Buffers: shared hit=57"  
"  ->  Hash Join  (cost=80.00..126.26 rows=2000 width=157) (actual time=0.664..1.919 rows=2000.00 loops=1)"  
"        Hash Cond: (gfw.film_work_id = fw.id)"  
"        Buffers: shared hit=56"  
"        ->  Seq Scan on genre_film_work gfw  (cost=0.00..41.00 rows=2000 width=52) (actual time=0.009..0.215 rows=2000.00 loops=1)"  
"              Buffers: shared hit=21"  
"        ->  Hash  (cost=55.00..55.00 rows=2000 width=105) (actual time=0.642..0.644 rows=2000.00 loops=1)"  
"              Buckets: 2048  Batches: 1  Memory Usage: 298kB"  
"              Buffers: shared hit=35"  
"              ->  Seq Scan on film_work fw  (cost=0.00..55.00 rows=2000 width=105) (actual time=0.010..0.197 rows=2000.00 loops=1)"  
"                    Buffers: shared hit=35"  
"  ->  Hash  (cost=12.60..12.60 rows=260 width=278) (actual time=0.028..0.029 rows=10.00 loops=1)"  
"        Buckets: 1024  Batches: 1  Memory Usage: 9kB"  
"        Buffers: shared hit=1"  
"        ->  Seq Scan on genre g  (cost=0.00..12.60 rows=260 width=278) (actual time=0.020..0.022 rows=10.00 loops=1)"  
"              Buffers: shared hit=1"  
"Planning:"  
"  Buffers: shared hit=27 read=4"  
"Planning Time: 2.822 ms"  
"Execution Time: 3.195 ms"  

----

## Ejemplo 3: Buscar a traves de INNER JOIN en Person

### Codigo:

EXPLAIN ANALYZE  
SELECT *  
FROM content.film_work as fw  
INNER JOIN content.person_film_work as pfw ON pfw.film_work_id =  fw.id  
INNER JOIN content.person as p ON p.id = pfw.person_id

### Sin Indice:
1. CREATE INDEX film_work_creation_date_idx ON content.film_work(creation_date);

"QUERY PLAN"  
"Hash Join  (cost=96.25..203.36 rows=4000 width=210) (actual time=0.797..4.497 rows=4000.00 loops=1)"  
"  Hash Cond: (pfw.person_id = p.id)"  
"  Buffers: shared hit=86"  
"  ->  Hash Join  (cost=80.00..176.52 rows=4000 width=164) (actual time=0.598..3.073 rows=4000.00 loops=1)"  
"        Hash Cond: (pfw.film_work_id = fw.id)"  
"        Buffers: shared hit=81"  
"        ->  Seq Scan on person_film_work pfw  (cost=0.00..86.00 rows=4000 width=59) (actual time=0.008..0.331 rows=4000.00 loops=1)"  
"              Buffers: shared hit=46"  
"        ->  Hash  (cost=55.00..55.00 rows=2000 width=105) (actual time=0.577..0.579 rows=2000.00 loops=1)"  
"              Buckets: 2048  Batches: 1  Memory Usage: 298kB"  
"              Buffers: shared hit=35"  
"              ->  Seq Scan on film_work fw  (cost=0.00..55.00 rows=2000 width=105) (actual time=0.008..0.171 rows=2000.00 loops=1)"  
"                    Buffers: shared hit=35"  
"  ->  Hash  (cost=10.00..10.00 rows=500 width=46) (actual time=0.178..0.179 rows=500.00 loops=1)"  
"        Buckets: 1024  Batches: 1  Memory Usage: 48kB"  
"        Buffers: shared hit=5"  
"        ->  Seq Scan on person p  (cost=0.00..10.00 rows=500 width=46) (actual time=0.030..0.076 rows=500.00 loops=1)"  
"              Buffers: shared hit=5"  
"Planning:"  
"  Buffers: shared hit=6"  
"Planning Time: 0.548 ms"  
"Execution Time: 4.861 ms"  

### Con Indice:
1. CREATE INDEX film_work_creation_date_idx ON content.film_work(creation_date);  
2. CREATE INDEX genre_film_work_film_work_id_idx ON content.genre_film_work(film_work_id);  
3. CREATE INDEX person_film_work_film_work_id_idx ON content.person_film_work(film_work_id);

"QUERY PLAN"  
"Hash Join  (cost=96.25..203.36 rows=4000 width=210) (actual time=1.048..5.794 rows=4000.00 loops=1)"  
"  Hash Cond: (pfw.person_id = p.id)"  
"  Buffers: shared hit=86"  
"  ->  Hash Join  (cost=80.00..176.52 rows=4000 width=164) (actual time=0.825..3.742 rows=4000.00 loops=1)"  
"        Hash Cond: (pfw.film_work_id = fw.id)"  
"        Buffers: shared hit=81"  
"        ->  Seq Scan on person_film_work pfw  (cost=0.00..86.00 rows=4000 width=59) (actual time=0.014..0.429 rows=4000.00 loops=1)"  
"              Buffers: shared hit=46"  
"        ->  Hash  (cost=55.00..55.00 rows=2000 width=105) (actual time=0.798..0.799 rows=2000.00 loops=1)"  
"              Buckets: 2048  Batches: 1  Memory Usage: 298kB"  
"              Buffers: shared hit=35"  
"              ->  Seq Scan on film_work fw  (cost=0.00..55.00 rows=2000 width=105) (actual time=0.012..0.225 rows=2000.00 loops=1)"  
"                    Buffers: shared hit=35"  
"  ->  Hash  (cost=10.00..10.00 rows=500 width=46) (actual time=0.210..0.211 rows=500.00 loops=1)"  
"        Buckets: 1024  Batches: 1  Memory Usage: 48kB"  
"        Buffers: shared hit=5"  
"        ->  Seq Scan on person p  (cost=0.00..10.00 rows=500 width=46) (actual time=0.030..0.088 rows=500.00 loops=1)"  
"              Buffers: shared hit=5"  
"Planning:"  
"  Buffers: shared hit=27 read=4"  
"Planning Time: 2.959 ms"  
"Execution Time: 6.261 ms"

----

## Ejemplo 4: Traer Todo

### Codigo:

EXPLAIN ANALYZE  
SELECT *  
FROM content.film_work as fw  
INNER JOIN content.person_film_work as pfw ON pfw.film_work_id =  fw.id  
INNER JOIN content.person as p ON p.id = pfw.person_id  
INNER JOIN content.genre_film_work as gfw ON gfw.film_work_id =  fw.id  
INNER JOIN content.genre as g ON g.id = gfw.genre_id;  

### Sin Indice:
1. CREATE INDEX film_work_creation_date_idx ON content.film_work(creation_date);

"QUERY PLAN"  
"Hash Join  (cost=188.70..340.29 rows=4000 width=540) (actual time=4.227..9.502 rows=4000.00 loops=1)"  
"  Hash Cond: (pfw.person_id = p.id)"  
"  Buffers: shared hit=108"  
"  ->  Hash Join  (cost=172.45..313.45 rows=4000 width=494) (actual time=4.026..7.678 rows=4000.00 loops=1)"  
"        Hash Cond: (pfw.film_work_id = fw.id)"  
"        Buffers: shared hit=103"  
"        ->  Seq Scan on person_film_work pfw  (cost=0.00..86.00 rows=4000 width=59) (actual time=0.015..0.414 rows=4000.00 loops=1)"  
"              Buffers: shared hit=46"  
"        ->  Hash  (cost=147.45..147.45 rows=2000 width=435) (actual time=3.999..4.003 rows=2000.00 loops=1)"  
"              Buckets: 2048  Batches: 1  Memory Usage: 516kB"  
"              Buffers: shared hit=57"  
"              ->  Hash Join  (cost=95.85..147.45 rows=2000 width=435) (actual time=0.743..2.796 rows=2000.00 loops=1)"  
"                    Hash Cond: (gfw.genre_id = g.id)"  
"                    Buffers: shared hit=57"  
"                    ->  Hash Join  (cost=80.00..126.26 rows=2000 width=157) (actual time=0.700..1.967 rows=2000.00 loops=1)"  
"                          Hash Cond: (gfw.film_work_id = fw.id)"  
"                          Buffers: shared hit=56"  
"                          ->  Seq Scan on genre_film_work gfw  (cost=0.00..41.00 rows=2000 width=52) (actual time=0.011..0.200 rows=2000.00 loops=1)"  
"                                Buffers: shared hit=21"  
"                          ->  Hash  (cost=55.00..55.00 rows=2000 width=105) (actual time=0.667..0.668 rows=2000.00 loops=1)"  
"                                Buckets: 2048  Batches: 1  Memory Usage: 298kB"  
"                                Buffers: shared hit=35"  
"                                ->  Seq Scan on film_work fw  (cost=0.00..55.00 rows=2000 width=105) (actual time=0.011..0.202 rows=2000.00 loops=1)"  
"                                      Buffers: shared hit=35"  
"                    ->  Hash  (cost=12.60..12.60 rows=260 width=278) (actual time=0.018..0.019 rows=10.00 loops=1)"  
"                          Buckets: 1024  Batches: 1  Memory Usage: 9kB"  
"                          Buffers: shared hit=1"  
"                          ->  Seq Scan on genre g  (cost=0.00..12.60 rows=260 width=278) (actual time=0.012..0.013 rows=10.00 loops=1)"  
"                                Buffers: shared hit=1"  
"  ->  Hash  (cost=10.00..10.00 rows=500 width=46) (actual time=0.184..0.184 rows=500.00 loops=1)"  
"        Buckets: 1024  Batches: 1  Memory Usage: 48kB"  
"        Buffers: shared hit=5"  
"        ->  Seq Scan on person p  (cost=0.00..10.00 rows=500 width=46) (actual time=0.036..0.083 rows=500.00 loops=1)"  
"              Buffers: shared hit=5"  
"Planning:"  
"  Buffers: shared hit=20"  
"Planning Time: 1.133 ms"  
"Execution Time: 10.117 ms"  

### Con Indice:
1. CREATE INDEX film_work_creation_date_idx ON content.film_work(creation_date);  
2. CREATE INDEX genre_film_work_film_work_id_idx ON content.genre_film_work(film_work_id);  
3. CREATE INDEX person_film_work_film_work_id_idx ON content.person_film_work(film_work_id);

"QUERY PLAN"  
"Hash Join  (cost=188.70..340.29 rows=4000 width=540) (actual time=4.538..12.441 rows=4000.00 loops=1)"  
"  Hash Cond: (pfw.person_id = p.id)"  
"  Buffers: shared hit=108"  
"  ->  Hash Join  (cost=172.45..313.45 rows=4000 width=494) (actual time=4.346..10.162 rows=4000.00 loops=1)"  
"        Hash Cond: (pfw.film_work_id = fw.id)"  
"        Buffers: shared hit=103"  
"        ->  Seq Scan on person_film_work pfw  (cost=0.00..86.00 rows=4000 width=59) (actual time=0.016..2.757 rows=4000.00 loops=1)"  
"              Buffers: shared hit=46"  
"        ->  Hash  (cost=147.45..147.45 rows=2000 width=435) (actual time=4.321..4.325 rows=2000.00 loops=1)"  
"              Buckets: 2048  Batches: 1  Memory Usage: 516kB"  
"              Buffers: shared hit=57"  
"              ->  Hash Join  (cost=95.85..147.45 rows=2000 width=435) (actual time=0.754..3.066 rows=2000.00 loops=1)"  
"                    Hash Cond: (gfw.genre_id = g.id)"  
"                    Buffers: shared hit=57"  
"                    ->  Hash Join  (cost=80.00..126.26 rows=2000 width=157) (actual time=0.724..2.194 rows=2000.00 loops=1)"  
"                          Hash Cond: (gfw.film_work_id = fw.id)"  
"                          Buffers: shared hit=56"  
"                          ->  Seq Scan on genre_film_work gfw  (cost=0.00..41.00 rows=2000 width=52) (actual time=0.010..0.208 rows=2000.00 loops=1)"  
"                                Buffers: shared hit=21"  
"                          ->  Hash  (cost=55.00..55.00 rows=2000 width=105) (actual time=0.694..0.695 rows=2000.00 loops=1)"  
"                                Buckets: 2048  Batches: 1  Memory Usage: 298kB"  
"                                Buffers: shared hit=35"  
"                                ->  Seq Scan on film_work fw  (cost=0.00..55.00 rows=2000 width=105) (actual time=0.012..0.200 rows=2000.00 loops=1)"  
"                                      Buffers: shared hit=35"  
"                    ->  Hash  (cost=12.60..12.60 rows=260 width=278) (actual time=0.017..0.018 rows=10.00 loops=1)"  
"                          Buckets: 1024  Batches: 1  Memory Usage: 9kB"  
"                          Buffers: shared hit=1"  
"                          ->  Seq Scan on genre g  (cost=0.00..12.60 rows=260 width=278) (actual time=0.011..0.013 rows=10.00 loops=1)"  
"                                Buffers: shared hit=1"  
"  ->  Hash  (cost=10.00..10.00 rows=500 width=46) (actual time=0.178..0.179 rows=500.00 loops=1)"  
"        Buckets: 1024  Batches: 1  Memory Usage: 48kB"  
"        Buffers: shared hit=5"  
"        ->  Seq Scan on person p  (cost=0.00..10.00 rows=500 width=46) (actual time=0.050..0.098 rows=500.00 loops=1)"  
"              Buffers: shared hit=5"  
"Planning:"  
"  Buffers: shared hit=36"  
"Planning Time: 1.039 ms"  
"Execution Time: 13.082 ms"  