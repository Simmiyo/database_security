--2. criptare si decriptare

set serveroutput on;

CREATE TABLE c##dba_admin.CRYPTO_KEYS(
     id NUMBER NOT NULL,
     email_key RAW(16),
     phone_key RAW(16),
     user_id NUMBER,
     CONSTRAINT crypto_keys_pk PRIMARY KEY(id)
);
    
CREATE sequence c##dba_admin.CRYPTO_KEYS_SEQ;

CREATE trigger c##dba_admin.bi_CRYPTO_KEYS_ID
  before insert on c##dba_admin.CRYPTO_KEYS
  for each row
begin
  select c##dba_admin.CRYPTO_KEYS_SEQ.nextval into :NEW.id from dual;
end;
/

CREATE OR REPLACE PROCEDURE encrypt_email_phone(email in VARCHAR2, phone_number in VARCHAR2, encrypted_email out RAW, encrypted_phone out RAW)
IS
    cuid VARCHAR2(50) := SYS_CONTEXT('USERENV', 'SESSION_USERID'); --current user id
    email_key RAW(16);
    raw_email RAW(1801);
    phone_key RAW(16);
    raw_phone RAW(100);
    operation_mode BINARY_INTEGER;
    symmetrical_keys c##dba_admin.CRYPTO_KEYS%ROWTYPE; 
BEGIN
    BEGIN
        email_key := SYS_CONTEXT('visitor_context', 'email_key');
        phone_key := SYS_CONTEXT('visitor_context', 'phone_key');
    
        IF(email_key IS NULL OR phone_key IS NULL) THEN  --"if" only for users registered before implementing the visitor_context
            EXECUTE IMMEDIATE 'SELECT * FROM c##dba_admin.CRYPTO_KEYS WHERE user_id = ' || cuid INTO symmetrical_keys;
    
            email_key := symmetrical_keys.email_key;
            phone_key := symmetrical_keys.phone_key;
        END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN 
        email_key := dbms_crypto.randombytes(16);
        phone_key := dbms_crypto.randombytes(16);
        EXECUTE IMMEDIATE 'INSERT INTO c##dba_admin.CRYPTO_KEYS VALUES(-1, :1, :2, :3)' USING email_key, phone_key, cuid;
        COMMIT;
    END;
    operation_mode := DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.ENCRYPT_AES128 + DBMS_CRYPTO.PAD_PKCS5;
    raw_email := UTL_I18N.STRING_TO_RAW(email, 'AL32UTF8');
    encrypted_email := DBMS_CRYPTO.ENCRYPT(raw_email, operation_mode, email_key);
    raw_phone := UTL_I18N.STRING_TO_RAW(phone_number, 'AL32UTF8');
    encrypted_phone := DBMS_CRYPTO.ENCRYPT(raw_phone, operation_mode, phone_key);
END;
/

GRANT EXECUTE ON encrypt_email_phone TO c##visitor_role;
/

CREATE OR REPLACE PROCEDURE decrypt_email_phone(encrypted_email in RAW, encrypted_phone in RAW, decrypted_email out VARCHAR2, 
    decrypted_phone out VARCHAR2)
IS
    cuid VARCHAR2(50) := SYS_CONTEXT('USERENV', 'SESSION_USERID'); --current user id
    email_key RAW(16);
    phone_key RAW(16);
    operation_mode BINARY_INTEGER;
    symmetrical_keys c##dba_admin.CRYPTO_KEYS%ROWTYPE;  
BEGIN
    email_key := SYS_CONTEXT('visitor_context', 'email_key');
    phone_key := SYS_CONTEXT('visitor_context', 'phone_key');
    
    IF(email_key IS NULL OR phone_key IS NULL) THEN --"if" only for users registered before implementing the visitor_context
        EXECUTE IMMEDIATE 'SELECT * FROM c##dba_admin.CRYPTO_KEYS WHERE user_id = ' || cuid INTO symmetrical_keys;
    
        email_key := symmetrical_keys.email_key;
        phone_key := symmetrical_keys.phone_key;
    END IF;
    
    operation_mode := DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.ENCRYPT_AES128 + DBMS_CRYPTO.PAD_PKCS5;
    
    decrypted_email := UTL_I18N.RAW_TO_CHAR(DBMS_CRYPTO.DECRYPT(encrypted_email, operation_mode, email_key), 'AL32UTF8');
    decrypted_phone := UTL_I18N.RAW_TO_CHAR(DBMS_CRYPTO.DECRYPT(encrypted_phone, operation_mode, phone_key), 'AL32UTF8');
EXCEPTION WHEN NO_DATA_FOUND THEN 
    RAISE_APPLICATION_ERROR(-20002, 'Nonexistent visitor.');
END;
/

GRANT EXECUTE ON decrypt_email_phone TO c##visitor_role;
/
