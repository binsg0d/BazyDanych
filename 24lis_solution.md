# Rozwiązania SQL - 24 Listopada

## 1. Iloczyn kartezjański
Iloczyn kartezjański dla tabel `user` i `questions`, wynik dla kolumn `email`, `question_type`. W celu ograniczenia wyników użyto `DISTINCT` dla tabeli `questions`.

```sql
SELECT 
    u.email, 
    q.question_type 
FROM 
    c2users u, 
    (SELECT DISTINCT question_type FROM c2questions) q;
```

## 2. Pracownicy i przełożeni
Wyświetl pracowników i ich przełożonych z tabeli `c2users`.

```sql
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
```

## 3. Upsert Użytkownika
Dodanie nowego użytkownika: jeżeli istnieje to wykonać aktualizację hasła, jeżeli nie istnieje to dodać nowego użytkownika.

```sql
INSERT INTO c2users (email, password, manager_id) VALUES ('test@example.com', 'test', NULL)
    ON CONFLICT (email) DO UPDATE SET password = 'test';

SELECT
    u.email,
    m.email
FROM
    c2users u
    JOIN c2users m ON u.manager_id = m.id;
```

## 4. Upsert Formularza

```sql
INSERT INTO c2forms (title, owner_id, created_at)
VALUES ('Opinia o nowej funkcji', 1, CURRENT_TIMESTAMP)
ON CONFLICT (title) 
DO UPDATE SET created_at = CURRENT_TIMESTAMP;
```

## 5. Przykład Transakcji i Savepoint
Demonstracja działania `ROLLBACK TO SAVEPOINT`.

```sql
BEGIN;
UPDATE c2users SET password_hash = 'bardzo_nowe_haslo' WHERE id=1;
SAVEPOINT password_changed;
DELETE FROM c2questions WHERE question_type = 'multiple-choice';
-- Sprawdzenie usunięcia: SELECT COUNT(*) FROM c2questions WHERE question_type = 'multiple-choice'; (Wynik: 0)
ROLLBACK TO SAVEPOINT password_changed;
-- Sprawdzenie przywrócenia: SELECT COUNT(*) FROM c2questions WHERE question_type = 'multiple-choice'; (Wynik: 1)
COMMIT;
```

## 6. Archiwizacja Użytkownika
Transakcja archiwizująca użytkownika `anna.nowak@example.com`.

```sql
BEGIN;

-- Aktualizacja emaila użytkownika
UPDATE c2users 
SET email = email || '.archived' 
WHERE email = 'anna.nowak@example.com';

-- Usunięcie formularzy i zwrócenie ich ID
DELETE FROM c2forms 
WHERE owner_id = (SELECT id FROM c2users WHERE email = 'anna.nowak@example.com.archived') 
RETURNING id;

COMMIT;
```
