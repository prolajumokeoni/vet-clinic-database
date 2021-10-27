-- Create database
CREATE DATABASE schemadb;
-- Insert data
INSERT INTO animals (name) VALUES ('Agumon'), ('Gabumon'), ('Pikachu'), ('Devimon'), ('Charmander'), ('Plantmon'), ('Squirtle'), ('Angemon'), ('Boarmon'), ('Blossom');
INSERT INTO vets (name) VALUES ('William Tatcher'), ('Maisy Smith'), ('Stephanie Mendez'), ('Jack Harkness');

-- Add an email column to your owners table
ALTER TABLE owners ADD COLUMN email VARCHAR(120);
-- This will add 3.594.280 visits considering you have 10 animals, 4 vets, and it will use around ~87.000 timestamps (~4min approx.)
INSERT INTO visits (animal_id, vet_id, date_of_visit) SELECT * FROM (SELECT id FROM animals) animal_ids, (SELECT id FROM vets) vets_ids, generate_series('1980-01-01'::timestamp, '2021-01-01', '4 hours') visit_timestamp;
-- This will add 2.500.000 owners with full_name = 'Owner <X>' and email = 'owner_<X>@email.com' (~2min approx.)
insert into owners (full_name, email) select 'Owner ' || generate_series(1,2500000), 'owner_' || generate_series(1,2500000) || '@mail.com';

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Optimization
-- Bofore
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
-- "Finalize Aggregate  (cost=39520.46..39520.47 rows=1 width=8) (actual time=437.634..450.820 rows=1 loops=1)"
-- "  ->  Gather  (cost=39520.24..39520.45 rows=2 width=8) (actual time=437.487..450.811 rows=3 loops=1)"
-- "        Workers Planned: 2"
-- "        Workers Launched: 2"
-- "        ->  Partial Aggregate  (cost=38520.24..38520.25 rows=1 width=8) (actual time=365.103..365.103 rows=1 loops=3)"
-- "              ->  Parallel Seq Scan on visits  (cost=0.00..38149.21 rows=148414 width=0) (actual time=4.292..351.915 rows=119809 loops=3)"
-- "                    Filter: (animal_id = 4)"
-- "                    Rows Removed by Filter: 1078284"
-- "Planning Time: 0.331 ms"
-- "Execution Time: 450.948 ms"

