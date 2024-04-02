--6. Aplicatii pe baza de date si securitatea datelor

--b) protectie SQL injection && aplicatii pe baza de date

CREATE OR REPLACE PROCEDURE register_visitor(username in VARCHAR2, 
    email in VARCHAR2, phone_number in VARCHAR2)
IS
    cuid VARCHAR2(50) := SYS_CONTEXT('USERENV', 'SESSION_USERID'); --current user id
    already_found VARCHAR2(2);
    params_query  VARCHAR2(200);
    encrypted_email RAW(1896);
    encrypted_phone RAW(128);
BEGIN
    EXECUTE IMMEDIATE 'SELECT DECODE(COUNT(*), 0, :1, :2) FROM c##dba_admin.VISITOR WHERE "user_id" = :3' INTO already_found 
        USING 'N', 'Y', cuid;
    
    IF (already_found = 'N') THEN
        params_query := 'INSERT INTO c##dba_admin.VISITOR VALUES(-1, :1, :2, :3, :4)';
    ELSE
        params_query := 'UPDATE c##dba_admin.VISITOR SET "name" = :1, "email" = :2, "phone_number" = :3 WHERE "user_id" = :4';
    END IF;
    encrypt_email_phone(email, phone_number, encrypted_email, encrypted_phone);
    EXECUTE IMMEDIATE params_query USING username, encrypted_email, encrypted_phone, cuid;
    COMMIT;
END;
/

GRANT EXECUTE ON register_visitor TO c##visitor_role;
/

CREATE OR REPLACE PROCEDURE select_personal_info
IS
    cuid VARCHAR2(50) := SYS_CONTEXT('USERENV', 'SESSION_USERID');
    params_query  VARCHAR2(200);
    user_data c##dba_admin.VISITOR%ROWTYPE;
    email VARCHAR2(1024);
    phone_number VARCHAR2(1024);
BEGIN
    params_query := 'SELECT * FROM c##dba_admin.VISITOR WHERE "user_id" = ' ||  cuid;
    EXECUTE IMMEDIATE params_query INTO user_data;
    decrypt_email_phone(user_data."email", user_data."phone_number", email, phone_number);
    dbms_output.put_line('name: ' || user_data."name" || ', email: ' || email || ', phone number: ' || phone_number);
EXCEPTION WHEN NO_DATA_FOUND THEN 
    RAISE_APPLICATION_ERROR(-20002, 'Nonexistent visitor.');
END;
/

GRANT EXECUTE ON select_personal_info TO c##visitor_role;
/

CREATE OR REPLACE PROCEDURE buy_ticket(play_id in NUMBER)
IS
    cuid VARCHAR2(50) := SYS_CONTEXT('USERENV', 'SESSION_USERID');
    params_query  VARCHAR2(200); 
    user_pk NUMBER;
BEGIN
    EXECUTE IMMEDIATE 'SELECT "id" from c##dba_admin.VISITOR WHERE "user_id" = ' || cuid INTO user_pk;
    params_query := 'INSERT INTO c##dba_admin.TICKET VALUES(:1, :2, :3)';
    EXECUTE IMMEDIATE params_query USING user_pk, play_id, current_timestamp; 
    COMMIT;
END;
/

GRANT EXECUTE ON buy_ticket TO c##visitor_role;
/

CREATE OR REPLACE PROCEDURE cancel_ticket(play_id in NUMBER)
IS
    cuid VARCHAR2(50) := SYS_CONTEXT('USERENV', 'SESSION_USERID');
    params_query  VARCHAR2(200); 
BEGIN
    params_query := 'DELETE FROM c##dba_admin.TICKET WHERE "visitor_id" = (SELECT "id" from c##dba_admin.VISITOR WHERE "user_id" = :1)
        and "play_id" = :2';
    EXECUTE IMMEDIATE params_query USING cuid, play_id; 
    COMMIT;
END;
/

GRANT EXECUTE ON cancel_ticket TO c##visitor_role; 
/

CREATE OR REPLACE PROCEDURE see_my_tickets
IS
    cuid VARCHAR2(50) := SYS_CONTEXT('USERENV', 'SESSION_USERID'); 
BEGIN
    FOR ticket IN (SELECT * FROM c##dba_admin.TICKET WHERE "visitor_id" = (SELECT "id" from c##dba_admin.VISITOR WHERE "user_id" = cuid))
    LOOP
        DBMS_OUTPUT.PUT_LINE('visitor_id: ' || ticket."visitor_id" || ', play_id: ' || ticket."play_id" || ', buy date: ' || 
            to_char(ticket."buy_date"));
    END LOOP;
END;
/

GRANT EXECUTE ON see_my_tickets TO c##visitor_role;
/


--a) contextul aplicatiei 

CREATE CONTEXT visitor_context USING get_crypto_keys;

CREATE OR REPLACE PROCEDURE get_crypto_keys
IS
    cuid VARCHAR2(50) := SYS_CONTEXT('USERENV', 'SESSION_USERID'); --current user id
    symmetrical_keys c##dba_admin.crypto_keys%ROWTYPE;  
BEGIN
    EXECUTE IMMEDIATE 'SELECT * FROM c##dba_admin.crypto_keys WHERE user_id = ' || cuid INTO symmetrical_keys;
    DBMS_SESSION.SET_CONTEXT('visitor_context', 'email_key', symmetrical_keys.email_key);
    DBMS_SESSION.SET_CONTEXT('visitor_context', 'phone_key', symmetrical_keys.phone_key);
EXCEPTION WHEN NO_DATA_FOUND THEN 
    DBMS_SESSION.SET_CONTEXT('visitor_context', 'email_key', NULL);
    DBMS_SESSION.SET_CONTEXT('visitor_context', 'phone_key', NULL);
END;
/

CREATE OR REPLACE TRIGGER set_visitor_context_trigger
AFTER INSERT OR UPDATE ON c##dba_admin.crypto_keys
BEGIN
    get_crypto_keys();
END;
/
