--1. creare

CREATE TABLE c##dba_admin.PLAY (
	"id" INT,
	"title" VARCHAR2(255) NOT NULL,
	"duration" NUMBER NOT NULL,
	"date" TIMESTAMP NOT NULL,
	"troupe_id" NUMBER NOT NULL,
	"theatre_id" NUMBER NOT NULL,
    "price" FLOAT NOT NULL,
	constraint PLAY_PK PRIMARY KEY ("id"));

CREATE sequence c##dba_admin.PLAY_ID_SEQ;

CREATE trigger c##dba_admin.BI_PLAY_ID
  before insert on c##dba_admin.PLAY
  for each row
begin
  select c##dba_admin.PLAY_ID_SEQ.nextval into :NEW."id" from dual;
end;

/
CREATE TABLE c##dba_admin.VISITOR (
	"id" INT,
	"name" VARCHAR2(255) NOT NULL,
	"email" RAW(1896) NOT NULL,
    "phone_number" RAW(128) NOT NULL,
	"user_id" NUMBER UNIQUE NOT NULL,
	constraint VISITOR_PK PRIMARY KEY ("id"));

CREATE sequence c##dba_admin.VISITOR_ID_SEQ;

CREATE trigger c##dba_admin.BI_VISITOR_ID
  before insert on c##dba_admin.VISITOR
  for each row
begin
  select c##dba_admin.VISITOR_ID_SEQ.nextval into :NEW."id" from dual;
end;

/
CREATE TABLE c##dba_admin.THEATRE (
	"id" INT,
	"name" VARCHAR2(255),
	"location_id" NUMBER NOT NULL,
	constraint THEATRE_PK PRIMARY KEY ("id"));

CREATE sequence c##dba_admin.THEATRE_ID_SEQ;

CREATE trigger c##dba_admin.BI_THEATRE_ID
  before insert on c##dba_admin.THEATRE
  for each row
begin
  select c##dba_admin.THEATRE_ID_SEQ.nextval into :NEW."id" from dual;
end;

/
CREATE TABLE c##dba_admin.TROUPE (
	"id" NUMBER NOT NULL,
	"name" VARCHAR2(255) NOT NULL,
	"contact_info" VARCHAR2(255),
	constraint TROUPE_PK PRIMARY KEY ("id"));

CREATE sequence c##dba_admin.TROUPE_ID_SEQ;

CREATE trigger c##dba_admin.BI_TROUPE_ID
  before insert on c##dba_admin.TROUPE
  for each row
begin
  select c##dba_admin.TROUPE_ID_SEQ.nextval into :NEW."id" from dual;
end;

/
CREATE TABLE c##dba_admin.LOCATION (
	"id" NUMBER NOT NULL,
	"city" VARCHAR2(255) NOT NULL,
	"street_name" VARCHAR2(255) NOT NULL,
	"street_number" NUMBER NOT NULL,
	constraint LOCATION_PK PRIMARY KEY ("id"));

CREATE sequence c##dba_admin.LOCATION_ID_SEQ;

CREATE trigger c##dba_admin.BI_LOCATION_ID
  before insert on c##dba_admin.LOCATION
  for each row
begin
  select c##dba_admin.LOCATION_ID_SEQ.nextval into :NEW."id" from dual;
end;

/
CREATE TABLE c##dba_admin.TICKET (
	"visitor_id" NUMBER NOT NULL,
	"play_id" NUMBER NOT NULL,
	"buy_date" TIMESTAMP NOT NULL,
	constraint TICKET_PK PRIMARY KEY ("visitor_id","play_id"));

/
ALTER TABLE c##dba_admin.PLAY ADD CONSTRAINT "PLAY_fk0" FOREIGN KEY ("troupe_id") REFERENCES c##dba_admin.TROUPE("id");
ALTER TABLE c##dba_admin.PLAY ADD CONSTRAINT "PLAY_fk1" FOREIGN KEY ("theatre_id") REFERENCES c##dba_admin.THEATRE("id");


ALTER TABLE c##dba_admin.THEATRE ADD CONSTRAINT "THEATRE_fk0" FOREIGN KEY ("location_id") REFERENCES c##dba_admin.LOCATION("id");


ALTER TABLE c##dba_admin.TICKET ADD CONSTRAINT "TICKET_fk0" FOREIGN KEY ("visitor_id") REFERENCES c##dba_admin.VISITOR("id");
ALTER TABLE c##dba_admin.TICKET ADD CONSTRAINT "TICKET_fk1" FOREIGN KEY ("play_id") REFERENCES c##dba_admin.PLAY("id");


--1. inserare

INSERT INTO c##dba_admin.LOCATION values (-1, 'Berlin', 'Alexandreplatz', 9);
INSERT INTO c##dba_admin.LOCATION values (-1, 'Hamburg', 'Cremon', 12);
INSERT INTO c##dba_admin.LOCATION values (-1, 'Munich', 'Marienplatz', 28);
INSERT INTO c##dba_admin.LOCATION values (-1, 'Frankfurt', 'Berger', 35);

INSERT INTO c##dba_admin.THEATRE values (-1, 'Hamlet Express', 3);
INSERT INTO c##dba_admin.THEATRE values (-1, 'Goethe', 2);
INSERT INTO c##dba_admin.THEATRE values (-1, 'Inferno of Dante', 1);
INSERT INTO c##dba_admin.THEATRE values (-1, 'Gray Masks', 3);
INSERT INTO c##dba_admin.THEATRE values (-1, 'Faust', 4);

INSERT INTO c##dba_admin.TROUPE values (-1, 'Shakespeare Group', 'Phone number: +49001252118');
INSERT INTO c##dba_admin.TROUPE values (-1, 'Cats VS Dogs', 'Email: cats_vs_dogs@gmail.com');
INSERT INTO c##dba_admin.TROUPE values (-1, 'White Tragedy', 'Website: whitetragedy.de');
INSERT INTO c##dba_admin.TROUPE values (-1, 'Berlin Wall', 'Website: berlinwalltroupe.de');

INSERT INTO c##dba_admin.PLAY values (-1, 'Death of a Salesman', 90, to_date('2023/05/03 12:00', 'yyyy/mm/dd hh24:mi'), 2, 1, 82.90);
INSERT INTO c##dba_admin.PLAY values (-1, 'Look Back in Anger', 120, to_date('2023/03/15 14:30', 'yyyy/mm/dd hh24:mi'), 1, 3, 95.40);
INSERT INTO c##dba_admin.PLAY values (-1, 'The Homecoming', 100, to_date('2023/02/22 20:00', 'yyyy/mm/dd hh24:mi'), 4, 5, 60.80);
INSERT INTO c##dba_admin.PLAY values (-1, 'Tartuffe', 130, to_date('2023/03/28 19:30', 'yyyy/mm/dd hh24:mi'), 3, 4, 68.72);
INSERT INTO c##dba_admin.PLAY values (-1, 'Uncommon Women and Others', 150, to_date('2023/04/10 18:00', 'yyyy/mm/dd hh24:mi'), 2, 2, 91.24);

