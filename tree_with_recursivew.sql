/* ====
ツリー構造を WITH RECURSIVE で扱う
==== */


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

-- select all folders --
SELECT * FROM Folders;

-- select root folder --
SELECT * FROM Folders
  WHERE parent_id IS NULL;


/* === 特定のフォルダー以下を取得 ===*/

-- PostgreSQL --


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

-- 数を数える --
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
SELECT count(*) FROM Fld;

-- 子供の数える --
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
SELECT count(*) FROM Fld WHERE name != 'Media';

-- VIEW --
CREATE VIEW media_view (id, name, path, parent_id, lvl) AS
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
 SELECT * FROM Fld
;

SELECT * FROM media_view;



-- 移動する --
-- Mediaのparent_idを変更するだけ

-- 削除する --

/* -- コピーする -- */

-- ID を 100増やす --
SELECT id + 100 AS copy_id, parent_id + 100 AS copy_parent_id FROM media_view;

-- children for copy --
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
SELECT id + 100 AS id,  name, parent_id + 100 AS parent_id FROM Fld WHERE name != 'Media';

-- 特定のフォルダーをコピー --
INSERT INTO Folders
 SELECT id + 100, CONCAT(name, '_copy'), parent_id FROM Folders
  WHERE name = 'Media'  -- or "id = 2"
;

-- 子供のフォルダーのコピー --
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
INSERT INTO Folders
  SELECT id + 100 AS id,  name, parent_id + 100 AS parent_id FROM Fld WHERE name != 'Media';

-- コピー結果 --
WITH RECURSIVE Fld(id, name, path, parent_id, lvl) AS ( 
  -- 最初のクエリー --
  SELECT id, name, name, parent_id, 1 FROM Folders
    WHERE name = 'Media_copy'

  UNION ALL

  -- 再帰的なクエリー --
  SELECT Folders.id, Folders.name, 
     CAST(CONCAT(Fld.path, '/', Folders.name) AS CHARACTER VARYING(50)), 
     Folders.parent_id, Fld.lvl + 1 
    FROM Folders INNER JOIN Fld ON  Folders.parent_id = Fld.id
)
SELECT * FROM Fld;
