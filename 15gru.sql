--- FUNKCJE TEKSTOWE

postgres=# SELECT LENGTH('Postgres')
postgres-# ;
 length 
--------
      8
(1 row)

postgres=# SELECT lower('Postgres');
  lower   
----------
 postgres
(1 row)

postgres=# SELECT upper('Postgres');
  upper   
----------
 POSTGRES
(1 row)

postgres=# SELECT substring('2025-15-12' from 1 for 4);
 substring 
-----------
 2025
(1 row)

postgres=# select replace ('2025-15-12', '2025', '2026');
  replace   
------------
 2026-15-12
(1 row)

postgres=# select position ('@' in 'asd@gmail.com')
postgres-# ;
 position 
----------
        4
(1 row)

postgres=# select trim('      dasdas       ');
 btrim  
--------
 dasdas
(1 row)

postgres=# select split_part('asdasd@gmail.com','@',2);
 split_part 
------------
 gmail.com
(1 row)


------ CUSTOMOWE FUNKCJE UŻYTKOWNIKA
CREATE OR REPLACE FUNCTION nazwa(user_id_in INT)
RETURNS typ_danych AS
$$
DECLARE
    -- deklaracja zmiennych
    licznik INT;
BEGIN
    RETURN licznik;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION normalize_email(raw_email TEXT)
RETURNS TEXT AS 
BEGIN
    RETURN lower(trim(raw_email));
END;
$$ LANGUAGE plpgsql;

----- LOSOWA WARTOSC OD 1 DO 100
CREATE OR REPLACE FUNCTION random_number()
RETURNS INT AS
$$
BEGIN
    RETURN FLOOR(RANDOM() * 100) + 1;
END;
$$ LANGUAGE plpgsql;


---- NAPISZ FUNKCJE SPRAWDZAJACA CZY DATA JEST WEEKENDEM

CREATE OR REPLACE FUNCTION is_weekend(date_in DATE)
RETURNS BOOLEAN AS
$$
DECLARE
    day_num INT;
BEGIN 
  day_num := EXTRACT(DOW FROM date_in);
  RETURN day_num IN (6,7);
END;
$$ LANGUAGE plpgsql;


---- FUNCKJE AGREGUJACE

sum()
count()
avg()
max()
min()

SELECT COUNT(*) FROM c2forms;

SELECT COUNT(*) FROM c2forms WHERE form_id = 1;

CREATE OR REPLACE FUNCTION get_question_count(form_id_in INT)
RETURNS INT AS
$$
DECLARE
    question_count INT;
BEGIN
    SELECT COUNT(*) INTO question_count FROM c2questions WHERE form_id = form_id_in;
    RETURN question_count;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_user_status(user_id_in INT)
RETURNS TEXT AS 
$$
DECLARE
    form_count INT;
    status_user INT;
BEGIN
    SELECT count(1) INTO form_count FROM c2forms WHERE user_id = user_id_in;
$$
