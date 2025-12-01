-- Dodanie 10 formularzy z losowym właścicielem (ID 1-7)
-- Odkomentuj poniższe, jeśli chcesz dodać nowe formularze
/*
INSERT INTO c2forms (title, owner_id, created_at)
SELECT 
    'Formularz ' || i, 
    floor(random() * 7 + 1)::int, 
    NOW() - (i || ' days')::interval 
FROM generate_series(1, 10) AS t(i);
*/

-- Dodanie 10 pytań (różne typy) przypisanych do losowych formularzy
INSERT INTO c2questions (question_type, question_text, form_id)
SELECT 
    CASE (i % 3)
        WHEN 0 THEN 'text'
        WHEN 1 THEN 'multiple-choice'
        ELSE 'rating'
    END,
    'Przykładowe pytanie ' || i,
    (SELECT id FROM c2forms ORDER BY RANDOM() LIMIT 1)
FROM generate_series(1, 10) AS t(i);
