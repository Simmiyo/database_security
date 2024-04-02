--5. privilegii si roluri
--a)privilegii sistem si obiect

GRANT CREATE SESSION TO c##dba_admin;
GRANT CREATE SESSION TO c##theatre_manager;
GRANT CREATE SESSION TO c##troupe_director;
GRANT CREATE SESSION TO c##visitor_1;
GRANT CREATE SESSION TO c##visitor_2;

CREATE ROLE c##dba_admin_role;
CREATE ROLE c##theatre_manager_role;
CREATE ROLE c##troupe_director_role;
CREATE ROLE c##visitor_role;

GRANT SELECT ON c##dba_admin.THEATRE TO c##visitor_role;
GRANT SELECT ON c##dba_admin.LOCATION TO c##visitor_role;
GRANT SELECT ON c##dba_admin.PLAY TO c##visitor_role;
GRANT SELECT ON c##dba_admin.TROUPE TO c##visitor_role;

GRANT SELECT, UPDATE, DELETE, INSERT ON c##dba_admin.TROUPE TO c##troupe_director_role;
GRANT SELECT, UPDATE, DELETE, INSERT ON c##dba_admin.THEATRE TO c##theatre_manager_role;
GRANT SELECT ON c##dba_admin.TROUPE TO c##theatre_manager_role;
GRANT SELECT ON c##dba_admin.THEATRE TO c##troupe_director_role;

GRANT SELECT, UPDATE, DELETE, INSERT ON c##dba_admin.PLAY TO c##troupe_director_role;
GRANT SELECT, UPDATE, DELETE, INSERT ON c##dba_admin.PLAY TO c##theatre_manager_role;

GRANT SELECT, DELETE ON c##dba_admin.TICKET TO c##theatre_manager_role;
GRANT SELECT, UPDATE, DELETE, INSERT ON c##dba_admin.TICKET TO c##dba_admin_role;
GRANT SELECT, UPDATE, DELETE, INSERT ON c##dba_admin.LOCATION TO c##theatre_manager;

GRANT c##dba_admin_role TO c##dba_admin;
GRANT c##theatre_manager_role TO c##theatre_manager;
GRANT c##troupe_director_role TO c##troupe_director;
GRANT c##visitor_role TO c##visitor_1;
GRANT c##visitor_role TO c##visitor_2;


--REVOKE SELECT ON c##dba_admin.LOCATION FROM c##visitor_1;

select * from dba_sys_privs where grantee = 'C##DBA_ADMIN';