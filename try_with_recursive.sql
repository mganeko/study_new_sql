/* ---

TRY WITH Recursive

---- */

CREATE TABLE Folders (
  id INTEGER NOT NULL,
  name VARCHAR(50) NOT NULL,
  parent_id INTEGER,
  PRIMARY KEY (id)
);

INSERT INTO Folders (id, name, parent_id) VALUES
  (0, 'root', NULL),
  (1, 'Documents', 0),
  (2, 'Media', 0),
  (3, 'Music', 2),
  (4, 'Photos', 2),
  (6, 'People', 4),
  (7, 'Travel', 4),
  (8, 'Foods', 4),
  (5, 'Videos', 2)
;


-- select root folder --
SELECT * FROM Folders
  WHERE parent_id IS NULL;

/*
https://qiita.com/Shoyu_N/items/f1786f99545fa5053b75
*/

-- root が何度も出てくる --
WITH RECURSIVE f (id, name, parent_id) AS (
  -- 非再帰
  SELECT Folders.id, Folders.name, Folders.parent_id FROM Folders
  UNION ALL

  -- 再帰
  SELECT Folders.id, Folders.name, Folders.parent_id 
  FROM Folders, f
  WHERE Folders.id = f.parent_id
)
-- メインクエリ
SELECT * FROM Folders
  WHERE parent_id IS NULL;

WITH RECURSIVE f (id, name, parent_id) AS (
  -- 非再帰
  SELECT Folders.id, Folders.name, Folders.parent_id FROM Folders
  UNION ALL

  -- 再帰
  SELECT f.id, f.name, f.parent_id 
  FROM f, Folders
  WHERE  f.parent_id = Folders.id
)
-- メインクエリ
SELECT * FROM f
  WHERE parent_id IS NULL;

--- Recursive query aborted after 1001 iterations
WITH RECURSIVE f (id, name, parent_id) AS (
  -- 非再帰
  SELECT Folders.id, Folders.name, Folders.parent_id FROM Folders
  UNION ALL

  -- 再帰
  SELECT f.id, f.name, f.parent_id 
  FROM f, Folders
  WHERE f.parent_id = Folders.id
)
-- メインクエリ
SELECT * FROM f
  WHERE parent_id IS NULL;


-- 惜しい  
WITH RECURSIVE f (id, name, parent_id, lvl) AS (
  -- 非再帰
  SELECT Folders.id, Folders.name, Folders.parent_id, 0 FROM Folders
  UNION ALL

  -- 再帰
  SELECT f.id, f.name, f.parent_id, f.lvl+1
  FROM f, Folders
  WHERE f.parent_id = Folders.id AND f.lvl <= 3
)
-- メインクエリ
SELECT * FROM f;


/* ---
普通にself join
--*/

SELECT * FROM Folders AS f0 INNER JOIN Folders AS f1 ON f0.id = f1.parent_id;

WITH f12 (id1, name1, parent1, id2, name2, parent2) AS
(
 SELECT * FROM Folders AS f1 INNER JOIN Folders AS f2 ON f1.id = f2.parent_id
)
SELECT * FROM Folders AS f0 OUTER JOIN f12 ON f0.id = f12.parent1;


WITH f12 (id1, name1, parent1, id2, name2, parent2) AS
(
 SELECT * FROM Folders AS f1 LEFT JOIN Folders AS f2 ON f1.id = f2.parent_id
)
SELECT * FROM Folders AS f0 LEFT JOIN f12 ON f0.id = f12.parent1;


/* --- まだできてない ----*/


/*
WITH句の再帰クエリー
 http://db2.blog.jp/archives/74002559.html
*/


WITH RPL(DEPTNO, PARENT_DEPTNO, LEVEL) AS ( 
  SELECT
    DEPTNO
    , PARENT_DEPTNO
    , 1 
  FROM
    DEPARTMENT 
  WHERE
    PARENT_DEPTNO is NULL
  UNION ALL
  SELECT
    DEPARTMENT.DEPTNO
    , DEPARTMENT.PARENT_DEPTNO
    , RPL.LEVEL + 1 
  FROM
    DEPARTMENT ,RPL
  WHERE
    RPL.DEPTNO = DEPARTMENT.PARENT_DEPTNO
    AND RPL.LEVEL < 100 --循環ループ防止
) 
SELECT
  * 
FROM
  RPL


CREATE TABLE Folders (
  id INTEGER NOT NULL,
  name VARCHAR(50) NOT NULL,
  parent_id INTEGER,
  PRIMARY KEY (id)
);


-- NG --
WITH Fld(id, name, parent_id, lvl) AS ( 
  -- 最初のクエリー --
  SELECT id, name, parent_id, 1 FROM Folders
    WHERE  parent_id IS NULL

  UNION ALL

  -- 再帰的なクエリー --
  SELECT Folders.id, Folders.name, Folders.parent_id, Fld.lvl + 1 
    FROM
      Folders, fld
    WHERE
      Fld.id = Folders.parent_id
    AND Fld.lvl < 10 --循環ループ防止
) 
SELECT * FROM Fld;




-- OK --
WITH Fld(id, name, parent_id, lvl) AS ( 
  -- 最初のクエリー --
  SELECT id, name, parent_id, 1 FROM Folders
    WHERE  parent_id IS NULL
) 
SELECT * FROM Fld;

-- ERROR  Table 'defaultdb.Fld' doesn't exist  -- 
WITH Fld(id, name, parent_id, lvl) AS ( 
  -- 最初のクエリー --
  SELECT id, name, parent_id, 1 FROM Folders
    WHERE  parent_id IS NULL

  UNION ALL

  -- 再帰的なクエリー --
  SELECT Folders.id, Folders.name, Folders.parent_id, Fld.lvl + 1 
    FROM Folders LEFT JOIN Fld ON  Folders.parent_id = Fld.id
    WHERE Fld.lvl < 10 -- 循環ループ防止
) 
SELECT * FROM Fld;


-- OK --
WITH Fld(id, name, parent_id, lvl) AS ( 
  -- 最初のクエリー --
  SELECT id, name, parent_id, 1 FROM Folders
    WHERE  parent_id IS NULL
    
  UNION ALL  
    -- 2番目の普通のクエリー 
    SELECT id, name, parent_id, 2 FROM Folders
    WHERE  parent_id = 0
) 
SELECT * FROM Fld;


-- OK --
WITH RECURSIVE Fld(id, name, parent_id, lvl) AS ( 
  -- 最初のクエリー --
  SELECT id, name, parent_id, 1 FROM Folders
    WHERE  parent_id IS NULL

  UNION ALL

  -- 再帰的なクエリー --
  SELECT Folders.id, Folders.name, Folders.parent_id, Fld.lvl + 1 
    FROM Folders LEFT JOIN Fld ON  Folders.parent_id = Fld.id
    WHERE Fld.lvl < 10 -- 循環ループ防止
) 
SELECT * FROM Fld;


-- OK --
WITH RECURSIVE Fld(id, name, path,  parent_id, lvl) AS ( 
  -- 最初のクエリー --
  SELECT id, name, name, parent_id, 1 FROM Folders
    WHERE name = 'Media'

  UNION ALL

  -- 再帰的なクエリー --
  SELECT Folders.id, Folders.name, CONCAT(Fld.path, '/', Folders.name), Folders.parent_id, Fld.lvl + 1 
    FROM Folders LEFT JOIN Fld ON  Folders.parent_id = Fld.id
    WHERE Fld.lvl < 10 -- レベル制限
) 
SELECT * FROM Fld;


-- OK --
WITH RECURSIVE Fld(id, name, path,  parent_id, lvl) AS ( 
  -- 最初のクエリー --
  SELECT id, name, name, parent_id, 1 FROM Folders
    WHERE name = 'Media'

  UNION ALL

  -- 再帰的なクエリー --
  SELECT f.id, f.name, CONCAT(Fld.path, '/', f.name), f.parent_id, Fld.lvl + 1 
    FROM Folders AS f LEFT JOIN Fld ON  f.parent_id = Fld.id
    WHERE Fld.lvl < 10 -- レベル制限
) 
SELECT * FROM Fld;

-- OK --
WITH RECURSIVE Fld(id, name, path,  parent_id, lvl) AS ( 
  -- 最初のクエリー --
  SELECT id, name, name, parent_id, 1 FROM Folders
    WHERE name = 'Media'

  UNION ALL

  -- 再帰的なクエリー --
  SELECT f.id, f.name, CONCAT(Fld.path, '/', f.name), f.parent_id, Fld.lvl + 1 
    FROM Folders AS f, Fld WHERE f.parent_id = Fld.id
    AND Fld.lvl < 10 -- レベル制限
) 
SELECT * FROM Fld;


-- OK レベル制限なし --
WITH RECURSIVE Fld(id, name, path, parent_id, lvl) AS ( 
  -- 最初のクエリー --
  SELECT id, name, name, parent_id, 1 FROM Folders WHERE name = 'Media'

  UNION ALL

  -- 再帰的なクエリー --
  SELECT Folders.id, Folders.name, 
     CONCAT(Fld.path, '/', Folders.name), 
     Folders.parent_id, Fld.lvl + 1 
    FROM Folders INNER JOIN Fld ON  Folders.parent_id = Fld.id
) 
SELECT * FROM Fld;


/* ---- for PostgreSQL ------*/

-- NG on PosgreSQL --
WITH RECURSIVE Fld(id, name, path,  parent_id, lvl) AS ( 
  -- 最初のクエリー --
  SELECT id, name, name, parent_id, 1 FROM Folders
    WHERE name = 'Media'

  UNION ALL

  -- 再帰的なクエリー --
  SELECT Folders.id, Folders.name, CONCAT(Fld.path, '/', Folders.name), Folders.parent_id, Fld.lvl + 1 
    FROM Folders LEFT JOIN Fld ON  Folders.parent_id = Fld.id
    WHERE Fld.lvl < 10 -- レベル制限
) 
SELECT * FROM Fld;
-- ERROR: recursive reference to query "fld" must not appear within an outer join (line: 258)

-- NG on PosgreSQL --
WITH RECURSIVE Fld(id, name, path,  parent_id, lvl) AS ( 
  -- 最初のクエリー --
  SELECT id, name, name, parent_id, 1 FROM Folders
    WHERE name = 'Media'

  UNION ALL

  -- 再帰的なクエリー --
  SELECT Folders.id, Folders.name, CONCAT(Fld.path, '/', Folders.name), Folders.parent_id, Fld.lvl + 1 
    FROM Folders, Fld
     WHERE Folders.parent_id = Fld.id
      AND Fld.lvl < 10 -- レベル制限
) 
SELECT * FROM Fld;
-- ERROR: recursive query "fld" column 3 has type character varying(50) in non-recursive term but type character varying overall (line: 267)



-- OK --
WITH RECURSIVE Fld(id, name, parent_id, lvl) AS ( 
  -- 最初のクエリー --
  SELECT id, name, parent_id, 1 FROM Folders
    WHERE name = 'Media'

  UNION ALL

  -- 再帰的なクエリー --
  SELECT Folders.id, Folders.name, Folders.parent_id, Fld.lvl + 1 
    FROM Folders, Fld
     WHERE Folders.parent_id = Fld.id
      AND Fld.lvl < 10 -- レベル制限
) 
SELECT * FROM Fld;

-- OK --
WITH RECURSIVE Fld(id, name, parent_id, lvl) AS ( 
  -- 最初のクエリー --
  SELECT id, name, parent_id, 1 FROM Folders
    WHERE name = 'Media'

  UNION ALL

  -- 再帰的なクエリー --
  SELECT Folders.id, Folders.name, Folders.parent_id, Fld.lvl + 1 
    FROM Folders INNER JOIN Fld ON  Folders.parent_id = Fld.id
    WHERE Fld.lvl < 10 -- レベル制限
) 
SELECT * FROM Fld;

-- OK --
WITH RECURSIVE Fld(id, name, path, parent_id, lvl) AS ( 
  -- 最初のクエリー --
  SELECT id, name, name, parent_id, 1 FROM Folders
    WHERE name = 'Media'

  UNION ALL

  -- 再帰的なクエリー --
  SELECT Folders.id, Folders.name, 
     CAST(CONCAT(Fld.path, '/', Folders.name) AS CHARACTER VARYING(50)), 
     Folders.parent_id, Fld.lvl + 1 
    FROM Folders INNER JOIN Fld ON  Folders.parent_id = Fld.id
    WHERE Fld.lvl < 10 -- レベル制限
) 
SELECT * FROM Fld;


-- OK レベル制限なし --
WITH RECURSIVE Fld(id, name, path, parent_id, lvl) AS ( 
  -- 最初のクエリー --
  SELECT id, name, name, parent_id, 1 FROM Folders
    WHERE name = 'Media'

  UNION ALL

  -- 再帰的なクエリー --
  SELECT Folders.id, Folders.name, 
     CAST(CONCAT(Fld.path, '/', Folders.name) AS CHARACTER VARYING(50)), 
     Folders.parent_id, Fld.lvl + 1 
    FROM Folders INNER JOIN Fld ON  Folders.parent_id = Fld.id
) 
SELECT * FROM Fld;
