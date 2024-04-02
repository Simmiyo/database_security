--3. Audit

set serveroutput on;

--a) standard

ALTER SYSTEM SET audit_trail=db, EXTENDED SCOPE=spfile;

AUDIT SELECT, INSERT, UPDATE, DELETE ON c##dba_admin.VISITOR;
AUDIT SELECT, INSERT, UPDATE, DELETE ON c##dba_admin.LOCATION;
AUDIT SELECT, INSERT, UPDATE, DELETE ON c##dba_admin.THEATRE;
AUDIT SELECT, INSERT, UPDATE, DELETE ON c##dba_admin.TROUPE;
AUDIT SELECT, INSERT, UPDATE, DELETE ON c##dba_admin.TICKET;
AUDIT SELECT, INSERT, UPDATE, DELETE ON c##dba_admin.PLAY;

SELECT NTIMESTAMP#, USERID, OBJ$NAME, SQLTEXT FROM SYS.AUD$;

--b) trigger

CREATE TABLE c##dba_admin.AUDIT_DATA_ON_PLAY(
     id NUMBER NOT NULL,
     user_id NUMBER NOT NULL,
     change_timestamp DATE NOT NULL,
     old_price FLOAT,
     new_price FLOAT,
     CONSTRAINT audit_pk PRIMARY KEY(id)
);
    
CREATE SEQUENCE c##dba_admin.AUDIT_DATA_ON_PLAY_SEQ;

CREATE OR REPLACE TRIGGER c##dba_admin.BI_AUDIT_DATA_ON_PLAY_ID
  before insert on c##dba_admin.AUDIT_DATA_ON_PLAY
  for each row
begin
  select c##dba_admin.AUDIT_DATA_ON_PLAY_SEQ.nextval into :NEW.id from dual;
end;
/

CREATE OR REPLACE TRIGGER monitoring_price_change
AFTER UPDATE OF "price" ON c##dba_admin.PLAY
for each row
when (SYS_CONTEXT('USERENV', 'AUTHENTICATED_IDENTITY') != 'C##DBA_ADMIN')
begin
  insert into c##dba_admin.AUDIT_DATA_ON_PLAY values(-1, SYS_CONTEXT('USERENV', 'SESSION_USERID'), SYSDATE, :old."price", :new."price");
end;
/

--test:
update c##dba_admin.PLAY set "price" = 9008 where "id" = 2;
commit;

select * from c##dba_admin.AUDIT_DATA_ON_PLAY order by change_timestamp desc;

--c) policy

CREATE OR REPLACE PROCEDURE audit_alert (object_schema VARCHAR2, object_name VARCHAR2, policy_name VARCHAR2) 
AS
BEGIN
    dbms_output.put_line('ALERT: Somebody modified ' || object_schema || '.' || object_name || '. 
    The triggered policy was ' || policy_name || '.');
END;
/
CREATE OR REPLACE PROCEDURE audit_policy_on_play AS
BEGIN
    dbms_fga.add_policy (
        object_schema => 'C##DBA_ADMIN',
        object_name => 'PLAY',
        policy_name => 'CHANGED_PLAY_DATE',
        statement_types => 'UPDATE',
        audit_column  => '"date"',
        ENABLE => TRUE,
        handler_module => 'audit_alert');
END;
/

EXECUTE audit_policy_on_play;
/

--test:
update c##dba_admin.PLAY set "date" = sysdate+20 where "id" = 2;
commit;

/

begin
dbms_fga.disable_policy(object_schema => 'C##DBA_ADMIN',
        object_name => 'TICKET',
        policy_name => 'CHANGED_TICKET_BUY_DATE');
end;
/