CREATE OR REPLACE PACKAGE PACK_MASKING IS
    FUNCTION f_masking(str VARCHAR2) RETURN VARCHAR2;
    FUNCTION f_masking(nb NUMBER) RETURN NUMBER;
    FUNCTION f_masking_group(nb NUMBER) RETURN NUMBER;
END;
/

CREATE OR REPLACE PACKAGE BODY PACK_MASKING IS
    TYPE t_tab_ind IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    v_tab_ind t_tab_ind;
    
    FUNCTION f_masking(str VARCHAR2) RETURN VARCHAR2 IS
        v_str VARCHAR2(255);
        v_len NUMBER;
    BEGIN
        v_str := SUBSTR(str,1,1);
        SELECT LENGTH(str) INTO v_len FROM DUAL;
        v_str := RPAD(v_str, v_len, '#');
        RETURN v_str;
    END f_masking;
    
    FUNCTION f_masking(nb NUMBER) RETURN NUMBER IS
        v_len NUMBER;
        v_min NUMBER;
        v_max NUMBER;
        v_seed VARCHAR2(100);
        v_new_nb NUMBER;
    BEGIN
        IF v_tab_ind.EXISTS(nb) THEN
            RETURN v_tab_ind(nb); 
        ELSE
            v_len := LENGTH(to_char(nb));
            v_min := to_number(RPAD(SUBSTR(to_char(nb),1,1),v_len,'0'));
            v_max := to_number(rpad(substr(to_char(nb),1,1),v_len,'9'));
            v_seed := TO_CHAR(SYSTIMESTAMP,'YYYYDDMMHH24MISSFFFF');
            v_new_nb := round(DBMS_RANDOM.VALUE(LOW => v_min, HIGH => v_max),0);
            v_tab_ind(nb):=v_new_nb;
            RETURN v_new_nb;
        END IF;
    END f_masking;
    
    FUNCTION f_masking_group(nb NUMBER) RETURN NUMBER IS
        v_new_nb NUMBER;
        v_len NUMBER;
    BEGIN
        v_len:=LENGTH(to_char(nb)); 
        v_new_nb:=to_number(RPAD(SUBSTR(to_char(nb),1,1),v_len,'0'));
        RETURN v_new_nb;
    END f_masking_group;
END;
/

CREATE OR REPLACE DIRECTORY DIREXP AS 'C:\SECBD';
/

declare
  f utl_file.file_type;
begin
  f := utl_file.fopen ('C:\SECBD', 'test.txt', 'w');
  utl_file.put_line(f, 'test');
  utl_file.fclose(f);
end;
/

GRANT ALL PRIVILEGES TO c##dba_admin;
GRANT READ, WRITE ON DIRECTORY DIREXP TO c##dba_admin;
/
