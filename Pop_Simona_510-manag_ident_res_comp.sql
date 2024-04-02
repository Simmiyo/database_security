--4. Gestiunea utilizatorilor unei baze de date si a resurselor computationale
--b) Implementarea configuratiei de management a identitatilor în baza de date

CREATE PROFILE c##visitor_profile LIMIT
    SESSIONS_PER_USER 2
    PASSWORD_LIFE_TIME 30
    FAILED_LOGIN_ATTEMPTS 10;
    
CREATE PROFILE c##manager_profile LIMIT
    SESSIONS_PER_USER 5
    PASSWORD_LIFE_TIME 30
    FAILED_LOGIN_ATTEMPTS 10;
    
CREATE PROFILE c##admin_profile LIMIT
    SESSIONS_PER_USER 20
    FAILED_LOGIN_ATTEMPTS 5;



CREATE USER c##dba_admin IDENTIFIED BY dba_admin QUOTA UNLIMITED ON USERS PROFILE c##admin_profile;
CREATE USER c##theatre_manager IDENTIFIED BY theatre_manager QUOTA UNLIMITED ON USERS PROFILE c##manager_profile;
CREATE USER c##troupe_director IDENTIFIED BY troupe_director QUOTA UNLIMITED ON USERS PROFILE c##manager_profile;
CREATE USER c##visitor_1 IDENTIFIED BY visitor_1 QUOTA UNLIMITED ON USERS PROFILE c##visitor_profile;
CREATE USER c##visitor_2 IDENTIFIED BY visitor_2 QUOTA UNLIMITED ON USERS PROFILE c##visitor_profile;
