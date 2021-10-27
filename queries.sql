-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Optimization
-- Before
EXPLAIN ANALYZE SELECT COUNT(*) FROM visits;

-- "Finalize Aggregate  (cost=39149.42..39149.43 rows=1 width=8) (actual time=750.313..781.977 rows=1 loops=1)"
-- "  ->  Gather  (cost=39149.21..39149.42 rows=2 width=8) (actual time=750.076..781.964 rows=3 loops=1)"
-- "        Workers Planned: 2"
-- "        Workers Launched: 2"
-- "        ->  Partial Aggregate  (cost=38149.21..38149.22 rows=1 width=8) (actual time=685.524..685.524 rows=1 loops=3)"
-- "              ->  Parallel Seq Scan on visits  (cost=0.00..34405.17 rows=1497617 width=0) (actual time=0.179..470.229 rows=1198093 loops=3)"
-- "Planning Time: 0.436 ms"
-- "Execution Time: 782.369 ms"

-- After
EXPLAIN ANALYZE SELECT COUNT(*) FROM visits where animal_id = 4;
-- "Finalize Aggregate  (cost=6689.20..6689.21 rows=1 width=8) (actual time=224.268..251.655 rows=1 loops=1)"
-- "  ->  Gather  (cost=6688.99..6689.20 rows=2 width=8) (actual time=221.619..251.643 rows=3 loops=1)"
-- "        Workers Planned: 2"
-- "        Workers Launched: 2"
-- "        ->  Partial Aggregate  (cost=5688.99..5689.00 rows=1 width=8) (actual time=87.835..87.836 rows=1 loops=3)"
-- "              ->  Parallel Index Only Scan using visits_animal_id_idx on visits  (cost=0.43..5321.07 rows=147166 width=0) (actual time=0.253..56.690 rows=119809 loops=3)"
-- "                    Index Cond: (animal_id = 4)"
-- "                    Heap Fetches: 0"
-- "Planning Time: 0.348 ms"
-- "Execution Time: 251.906 ms"

--Before 
EXPLAIN ANALYZE SELECT * FROM visits;
-- "Seq Scan on visits  (cost=0.00..55371.80 rows=3594280 width=16) (actual time=0.082..739.834 rows=3594280 loops=1)"
-- "Planning Time: 0.109 ms"
-- "Execution Time: 1083.742 ms"

-- After
EXPLAIN ANALYZE SELECT * FROM visits where vet_id = 2;
-- "Bitmap Heap Scan on visits  (cost=10109.99..40883.44 rows=907556 width=16) (actual time=102.303..860.800 rows=898570 loops=1)"
-- "  Recheck Cond: (vet_id = 2)"
-- "  Heap Blocks: exact=19429"
-- "  ->  Bitmap Index Scan on visits_vet_id_idx  (cost=0.00..9883.10 rows=907556 width=0) (actual time=92.762..92.763 rows=898570 loops=1)"
-- "        Index Cond: (vet_id = 2)"
-- "Planning Time: 0.241 ms"
-- "Execution Time: 934.174 ms"


-- Before
EXPLAIN ANALYZE SELECT * FROM owners;
-- "Seq Scan on owners  (cost=0.00..47352.00 rows=2500000 width=43) (actual time=0.085..598.844 rows=2500000 loops=1)"
-- "Planning Time: 0.094 ms"
-- "Execution Time: 720.713 ms"

-- After
EXPLAIN ANALYZE SELECT * FROM owners where email = 'owner_18327@mail.com';
-- "Seq Scan on owners  (cost=0.00..12.88 rows=1 width=324) (actual time=0.056..0.057 rows=0 loops=1)"
-- "  Filter: ((email)::text = 'owner_18327@mail.com'::text)"
-- "Planning Time: 0.320 ms"
-- "Execution Time: 0.087 ms"
