# Zapytanie 1 / Ponumerowac formularze kazdego uzytkownika w kolejnosci od najstarszych do najnowszych
```sql
SELECT
    u.email,
    f.id,
    f.created_at,
ROW_NUMBER() OVER (PARTITION BY u.id ORDER BY f.created_at) AS form_number
FROM c2forms f
JOIN c2users u ON f.owner_id = u.id;
```

# Zapytanie 2 / Dla kazdego uzytkownika chcemy zobaczyc date utworzenia formularza i date jego poprzedniego formularza
-- LAG() LEAD()
-- LAG(kolumna, offset, wartosc domyslna) LEAD()

```sql
WITH user_forms_ranked AS (
    SELECT
        owner_id,
        created_at,
        LAG(created_at, 1) OVER (PARTITION BY owner_id ORDER BY created_at) AS prev_created_at
    FROM c2forms
)
SELECT
    uf.owner_id,
    uf.created_at,
    uf.prev_created_at,
    uf.created_at - uf.prev_created_at AS days_diff
FROM user_forms_ranked uf;
```

# Zapytanie 3 / Policz ilosc kroczaca liczby pytan w miare ich dodawania

```sql
SELECT 
    q.id,
    q.question_type,
    COUNT(q.id) OVER (ORDER BY q.id) AS question_number
FROM c2questions q;
```

```sql
SELECT
    f.title,
    u.email,
    COUNT(1) OVER (PARTITION BY f.owner_id) AS ile
    FROM c2forms f
    JOIN c2users u ON f.owner_id = u.id;
```

# Zapytanie 4 / Pokaz liste formularzy, oraz ilosc wszystkich formularzy jakie ma dany uzytkownik

```sql
SELECT
    u.email,
    f.id AS form_id,
    f.created_at AS form_created_at,
    COUNT(f.id) OVER (PARTITION BY u.id) AS total_forms_for_user
FROM c2users u
LEFT JOIN c2forms f ON u.id = f.owner_id
ORDER BY u.email, f.created_at;
```

# Zapytanie 5 / Znalesc wszystkie formularze nalezace do uzytkownika z domeny @example.com

```sql
SELECT 
    f.id,
    f.title,
    u.email,
    COUNT(f.id) OVER (PARTITION BY u.id) AS total_forms_for_user
FROM c2forms f
JOIN c2users u ON f.owner_id = u.id
WHERE u.email LIKE '%@example.com';
```

```sql
SELECT
    title,
    owner_id
    FROM c2forms                       
    WHERE owner_id IN (SELECT id FROM c2users WHERE email LIKE '%@example.com'); 
```

```sql
SELECT
    title,
    owner_id
    FROM c2forms                       
    WHERE owner_id = (SELECT id FROM c2users WHERE email LIKE '%@example.com' LIMIT 1);
```

```sql
SELECT
    email 
    FROM c2users u
    WHERE EXISTS (SELECT 1 FROM c2forms f WHERE f.owner_id = u.id);
```
Nieoptymalna wersja
```sql
SELECT f.title, u.email, (SELECT count(1) FROM c2forms ff WHERE ff.owner_id = f.owner_id) AS ile FROM c2forms f JOIN c2users u ON f.owner_id=u.id;
```
Optymalna wersja
```sql
SELECT
    f.title,
    u.email,
    owner_counts.ile_formularzy
FROM
    c2forms f
JOIN
    c2users u ON f.owner_id = u.id
JOIN
    -- Wykonujemy agregację TYLKO RAZ w oddzielnym zapytaniu
    (
        SELECT
            owner_id,
            COUNT(1) AS ile_formularzy
        FROM
            c2forms
        GROUP BY
            owner_id
    ) AS owner_counts
    ON f.owner_id = owner_counts.owner_id;]
```

Zapytanie 6 / Znajdz formularze z liczba pytan wieksza niz srednia

```sql
SELECT 
    f.id,
    f.title,
    COUNT(q.id) AS question_count,
    (SELECT AVG(question_count) FROM (SELECT COUNT(q.id) AS question_count FROM c2questions q GROUP BY q.form_id) sub) AS avg_question_count
FROM c2forms f
JOIN c2questions q ON f.id = q.form_id
GROUP BY f.id, f.title
HAVING COUNT(q.id) > (SELECT AVG(question_count) FROM (SELECT COUNT(q.id) AS question_count FROM c2questions q GROUP BY q.form_id) sub);
```

```sql
SELECT AVG(num_questions) FROM (SELECT COUNT(*) as num_questions FROM c2questions GROUP BY form_id);
```

```sql 
SELECT 
    f.title,
    qc.num_questions
    FROM c2forms f
    JOIN (
    SELECT form_id, COUNT(*) as num_questions
    FROM c2questions
    GROUP BY form_id
    ) as qc ON f.id = qc.form_id
    WHERE qc.num_questions > (SELECT AVG(num_questions) FROM (SELECT COUNT(*) as num_questions FROM c2questions GROUP BY form_id) as avg_num_questions);
```

Zapytanie 7 / Raport pokazujacy email,title,ilosc pytan

```sql
WITH form_question_counts AS (
    SELECT form_id, count(id) AS number_question 
    FROM c2questions
    GROUP BY form_id)

SELECT 
    u.email,
    f.title,
    COALESCE(qc.number_question, 0) AS number_question
FROM c2forms f
JOIN c2users u ON f.owner_id = u.id
JOIN form_question_counts qc ON f.id = qc.form_id;
```

```sql
WITH RECURSIVE eh AS (
    SELECT id, email, manager_id, 1 as level
    FROM c2users
    WHERE manager_id = 1
    UNION ALL
    SELECT u.id, u.email, u.manager_id, eh.level + 1
    FROM c2users u
    INNER JOIN eh ON u.manager_id = eh.id
)
SELECT * FROM eh;
