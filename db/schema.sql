CREATE DATABASE crypto_bookmark_db;
\c crypto_bookmark_db;

CREATE TABLE coins(
  id SERIAL PRIMARY KEY,
  coin_code TEXT,
  bought_date DATE,
  unit_amount INT,
  user_number INT
);
-- Year/month/date
INSERT INTO coins(coin_code,bought_date,unit_amount, user_number)
VALUES('BNB', '2018-03-01', 14330, 1);

INSERT INTO coins(coin_code,bought_date,unit_amount, user_number)
VALUES('BTC', '2010-08-05', 13, 1 );

INSERT INTO coins(coin_code,bought_date,unit_amount, user_number)
VALUES('ETH', '2019-04-24', 100, 1 );

INSERT INTO coins(coin_code,bought_date,unit_amount, user_number)
VALUES('USDT', '2020-09-04', 12230, 1 );


CREATE TABLE users(
  id SERIAL PRIMARY KEY,
  first_name TEXT,
  last_name TEXT,
  email TEXT
);

ALTER TABLE users ADD COLUMN password_digest TEXT;
