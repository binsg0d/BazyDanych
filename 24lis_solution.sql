Iloczyn kartezjanski dla tabel user i questions, wynik dla kolumn email, question_type, w celu ograniczenia  wynikow uzyj DISTINCT dla tabeli questions;
SELECT 
    u.email, 
    q.question_type 
FROM 
    c2users u, 
    (SELECT DISTINCT question_type FROM c2questions) q;

Wyswietl pracownikow i ich przelozonych z tabeli c2users;

SELECT 
    u.email,
    u.manager_id
FROM
    c2users u
WHERE u.manager_id IS NOT NULL;

SELECT 
    u.email,
    m.email
FROM
    c2users u
    JOIN c2users m ON u.manager_id = m.id;

Dodanie nowego uzytkowniak, jezeli istnieje to wykonac aktualizacje hasla, jezeli nie istnieje to dodac nowego uzytkownika; Najpierw sprawdzic czy istnieje uzytkownik;



INSERT INTO c2users (email, password, manager_id) VALUES ('test@example.com', 'test', NULL)
    ON CONFLICT (email) DO UPDATE SET password = 'test';


SELECT
    u.email,
    m.email
FROM
    c2users u
    JOIN c2users m ON u.manager_id = m.id;
 




INSERT INTO c2forms (title, owner_id, created_at)

VALUES ('Opinia o nowej funkcji', 1, CURRENT_TIMESTAMP)

ON CONFLICT (title) 

DO UPDATE SET  created_at = CURRENT_TIMESTAMP

;

 

 postgres=# BEGIN;
BEGIN
postgres=*# UPDATE c2users SET password_hash = 'bardzo_nowe_haslo' WHERE id=1;
UPDATE 1
postgres=*# SAVEPOINT password_changed;
SAVEPOINT
postgres=*# DELETE FROM c2questions WHERE question_type = 'multiple-choice';
DELETE 1
postgres=*# SELECT COUNT(*) FROM c2questions WHERE question_type = 'multiple-choice';
 count 
-------
     0
(1 row)

postgres=*# ROLLBACK TO SAVEPOINT password_changed;
ROLLBACK
postgres=*# SELECT COUNT(*) FROM c2questions WHERE question_type = 'multiple-choice';
 count 
-------
     1
(1 row)

postgres=*# COMMIT;
