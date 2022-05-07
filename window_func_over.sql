/*
 Window Function with OVer
*/


CREATE TABLE Bank_Transaction (
  account_id INTEGER NOT NULL,
  transaction_date DATE NOT NULL,
  value INTEGER NOT NULL,
  PRIMARY KEY (account_id, transaction_date)
);

INSERT INTO Bank_Transaction (account_id, transaction_date, value) VALUES
  (1, '2000-05-01', 1000),
  (1, '2001-06-02', 5000),
  (1, '2001-07-03', -2500),
  (1, '2003-01-04', 4000),
  (1, '2003-08-05', -1500),
  (1, '2010-09-06', -1000),
  (1, '2011-10-07', 3000)
;

INSERT INTO Bank_Transaction (account_id, transaction_date, value) VALUES
  (2, '2005-11-12', 5000),
  (2, '2006-12-21', -3000),
  (2, '2007-12-28', 4000)
;

/* --- total ----*/
SELECT account_id, SUM(value) 
 FROM Bank_Transaction
 GROUP BY account_id;

/* -- grouping ROLLUP ---*/
/* --- NG for MySQL 8 --
SELECT account_id, SUM(value) 
 FROM Bank_Transaction
 GROUP BY 
  GROUPING SET account_id;
--*/

/* --- ROLL UP ---*/
SELECT account_id, SUM(value) 
 FROM Bank_Transaction
 GROUP BY account_id WITH ROLLUP;


/* --- Moving Total, 累積 ---*/
SELECT account_id, transaction_date, value,
 SUM(value) OVER (
   PARTITION BY account_id
   ORDER BY transaction_date
    ROWS BETWEEN
      UNBOUNDED PRECEDING
     AND
      CURRENT ROW
 )  AS balance
FROM Bank_Transaction;


/* --- moving average --- */


CREATE TABLE Covid19 (
  report_date DATE NOT NULL,
  patients INTEGER NOT NULL,
  deads INTEGER NOT NULL,
  PRIMARY KEY (report_date)
);

-- load data --

LOAD DATA LOCAL
  INFILE '/Users/masashi/project/git_local/sql_study/study_new_sql/data/nhk_news_covid19_daily_pick.csv'
  INTO TABLE Covid19 FIELDS TERMINATED BY ','
  IGNORE 1 LINES;

/*
-- error --
Loading local data is disabled;
 this must be enabled on both the client and server sides
*/


INSERT INTO Covid19 (report_date, patients, deads) VALUES
  ('2022-03-01',65400,238)
  ,('2022-03-02',72623,238)
 ,('2022-03-03',70323,256)
 ,('2022-03-04',63727,233)
 ,('2022-03-05',63658,184)
 ,('2022-03-06',53945,132)
 ,('2022-03-07',37071,121)
 ,('2022-03-08',54003,248)
 ,('2022-03-09',63715,213)
 ,('2022-03-10',61136,188)
 ,('2022-03-11',55860,209)
 ,('2022-03-12',55314,141)
 ,('2022-03-13',50934,90)
 ,('2022-03-14',32459,116)
 ,('2022-03-15',50756,188)
 ,('2022-03-16',57909,163)
 ,('2022-03-17',53558,171)
 ,('2022-03-18',49200,156)
 ,('2022-03-19',44694,104)
 ,('2022-03-20',39649,66)
 ,('2022-03-21',27697,58)
 ,('2022-03-22',20226,71)
 ,('2022-03-23',41023,122)
 ,('2022-03-24',49915,126)
 ,('2022-03-25',47456,115)
 ,('2022-03-26',47328,101)
 ,('2022-03-27',43361,61)
 ,('2022-03-28',29877,65)
 ,('2022-03-29',44459,81)
 ,('2022-03-30',53735,96)
 ,('2022-03-31',51892,102)
 ,('2022-04-01',49260,78)
 ,('2022-04-02',48812,55)
 ,('2022-04-03',47332,34)
 ,('2022-04-04',30147,45)
 ,('2022-04-05',45660,64)
 ,('2022-04-06',54871,66)
 ,('2022-04-07',54970,69)
 ,('2022-04-08',51930,69)
 ,('2022-04-09',52724,49)
 ,('2022-04-10',49165,39)
 ,('2022-04-11',33192,34)
 ,('2022-04-12',49752,47)
 ,('2022-04-13',57745,67)
 ,('2022-04-14',55271,52)
 ,('2022-04-15',49741,62)
 ,('2022-04-16',47585,49)
 ,('2022-04-17',39278,26)
 ,('2022-04-18',24249,27)
 ,('2022-04-19',40887,52)
 ,('2022-04-20',47892,50)
 ,('2022-04-21',47124,51)
 ,('2022-04-22',42995,51)
 ,('2022-04-23',43956,34)
 ,('2022-04-24',38565,15)
 ,('2022-04-25',24830,39)
 ,('2022-04-26',40491,65)
 ,('2022-04-27',46257,60)
 ,('2022-04-28',41750,39)
 ,('2022-04-29',36670,45)
;

INSERT INTO Covid19 (report_date, patients, deads) VALUES
 ('2022-04-30', 25177, 14)
 ,('2022-05-01', 26957, 34)
 ,('2022-05-02', 19349, 30)
 ,('2022-05-03', 30479, 55)
 ,('2022-05-04', 26469, 20)
;


SELECT * FROM Covid19;

-- average --
SELECT AVG(patients) FROM Covid19;

-- moving average --
SELECT report_date, patients, AVG(patients) OVER (
   ORDER BY report_date ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING
 ) moving_avg
 FROM Covid19;

