-- Shane Lister Comp 4670 June 2013

-- This script assumes that the listener, oracle instance, and database have been started
-- Creates Customer Sales app
--   Creates tablespace, user schema, 5 tables, profile, 2 roles, 3 users
-- Checks for the existance of objects and removes them before creating them again

-- Instructions
--   Start Listener
--   Mount database
--   Open database
--   Login to SQL plus as SYS (or sufficient privledges)
--   Run this script file

-- Allow script user to see feedback in console
SET ECHO ON;
SET SERVEROUTPUT ON;

-- Search the current tablespaces for CUSTOMERSALES
--   Remove if found
DECLARE 
	v_counter NUMBER :=0;
BEGIN
	/* Check to see if customersales exists */
	select count(*) 
	into v_counter from dba_tablespaces 
	where
	tablespace_name='CUSTOMERSALES';

	/* If exists, delete it */
	IF v_counter=1
	THEN
    		DBMS_OUTPUT.PUT_LINE ('DROPPING CUSTOMERSALES TABLESPACE....');
    		EXECUTE IMMEDIATE ('DROP TABLESPACE CUSTOMERSALES INCLUDING CONTENTS  
     		CASCADE CONSTRAINTS');
	END IF;
END;
/

-- Create the CUSTOMERSALES tablespace
--   We need a tablespace and datafile for the components of our app
CREATE SMALLFILE TABLESPACE "CUSTOMERSALES" DATAFILE '/u01/app/oracle/oradata/orcl/customersales.dbf' 
SIZE 5M REUSE LOGGING EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO DEFAULT NOCOMPRESS;
COMMIT;


-- Search the current users for CUSTOMERSALES
--   Remove if found
DECLARE 
	v_counter NUMBER :=0;
BEGIN
	/* Check to see if customersales user exists */
	select count(*) 
	into v_counter from dba_users 
	where
	username='CUSTOMERSALES';

	/* If exists, delete it */
	IF v_counter=1
	THEN
    		DBMS_OUTPUT.PUT_LINE ('DROPPING CUSTOMERSALES USER....');
    		EXECUTE IMMEDIATE ('DROP USER CUSTOMERSALES CASCADE');
	END IF;
END;
/

-- Our app needs a user so we can interact with it
CREATE USER CUSTOMERSALES identified by verysecure default tablespace CUSTOMERSALES;
grant connect, resource to CUSTOMERSALES;
COMMIT;


-- Searches for all the tables we will be making and removes them if found

-- Search the current tables for LINE
--   Remove if found
DECLARE 
	v_counter NUMBER :=0;
BEGIN
	/* Check to see if table exists */
	select count(*) 
	into v_counter from dba_tables 
	where
	table_name='LINE';

	/* If exists, delete it */
	IF v_counter=1
	THEN
    		DBMS_OUTPUT.PUT_LINE ('DROPPING LINE TABLE....');
    		EXECUTE IMMEDIATE ('DROP TABLE CUSTOMERSALES.LINE');
	END IF;
END;
/

-- Search the current tables for INVOICE
--   Remove if found
DECLARE 
	v_counter NUMBER :=0;
BEGIN
	/* Check to see if table exists */
	select count(*) 
	into v_counter from dba_tables 
	where
	table_name='INVOICE';

	/* If exists, delete it */
	IF v_counter=1
	THEN
    		DBMS_OUTPUT.PUT_LINE ('DROPPING INVOICE TABLE....');
    		EXECUTE IMMEDIATE ('DROP TABLE CUSTOMERSALES.INVOICE');
	END IF;
END;
/

-- Search the current tables for PRODUCT
--   Remove if found
DECLARE 
	v_counter NUMBER :=0;
BEGIN
	/* Check to see if table exists */
	select count(*) 
	into v_counter from dba_tables 
	where
	table_name='PRODUCT';

	/* If exists, delete it */
	IF v_counter=1
	THEN
    		DBMS_OUTPUT.PUT_LINE ('DROPPING PRODUCT TABLE....');
    		EXECUTE IMMEDIATE ('DROP TABLE CUSTOMERSALES.PRODUCT');
	END IF;
END;
/

-- Search the current tables for CUSTOMER
--   Remove if found
DECLARE 
	v_counter NUMBER :=0;
BEGIN
	/* Check to see if table exists */
	select count(*) 
	into v_counter from dba_tables 
	where
	table_name='CUSTOMER';

	/* If exists, delete it */
	IF v_counter=1
	THEN
    		DBMS_OUTPUT.PUT_LINE ('DROPPING CUSTOMER TABLE....');
    		EXECUTE IMMEDIATE ('DROP TABLE CUSTOMERSALES.CUSTOMER');
	END IF;
END;
/

-- Search the current tables for VENDOR
--   Remove if found
DECLARE 
	v_counter NUMBER :=0;
BEGIN
	/* Check to see if table exists */
	select count(*) 
	into v_counter from dba_tables 
	where
	table_name='VENDOR';

	/* If exists, delete it */
	IF v_counter=1
	THEN
    		DBMS_OUTPUT.PUT_LINE ('DROPPING VENDOR TABLE....');
    		EXECUTE IMMEDIATE ('DROP TABLE CUSTOMERSALES.VENDOR');
	END IF;
END;
/

-- Create the tables we will need for our app
--   It is safe to do so because they were removed as above
CREATE TABLE "CUSTOMERSALES"."CUSTOMER" ( 
  "CUS_CODE" NUMBER, 
	"CUS_LNAME" VARCHAR2(15) NOT NULL, 
	"CUS_FNAME" VARCHAR2(15) NOT NULL, 
	"CUS_INITIAL" CHAR(1), 
	"CUS_AREACODE" CHAR(3) DEFAULT 604 NOT NULL, 
	"CUS_PHONE" CHAR(8) NOT NULL, 
	"CUS_BALANCE" NUMBER(10, 2) DEFAULT 0.00, 
	CONSTRAINT "PK_CUS" PRIMARY KEY ("CUS_CODE") VALIDATE ) TABLESPACE "CUSTOMERSALES";

CREATE TABLE "CUSTOMERSALES"."INVOICE" ( 
    "INV_NUMBER" NUMBER, 
    "CUS_CODE" NUMBER NOT NULL, 
    "INV_DATE" DATE DEFAULT SYSDATE NOT NULL, 
    "INV_NET" NUMBER(8,2) NOT NULL, 
    "INV_TAX" NUMBER(7,2) NOT NULL, 
    "INV_TOTAL" NUMBER(9,2) NOT NULL, 
    CONSTRAINT "PK_INV" PRIMARY KEY ("INV_NUMBER") VALIDATE,
    CONSTRAINT "FK_INV" FOREIGN KEY ("CUS_CODE") REFERENCES "CUSTOMERSALES"."CUSTOMER" ("CUS_CODE") VALIDATE ) TABLESPACE "CUSTOMERSALES";

CREATE TABLE "CUSTOMERSALES"."VENDOR" ( 
    "V_CODE" NUMBER,
    "V_NAME" VARCHAR2(35) NOT NULL,
    "V_CONTACT" VARCHAR2(20) NOT NULL,
    "V_AREACODE" CHAR(3) NOT NULL,
    "V_PHONE" CHAR(8) NOT NULL,
	"V_STATE" CHAR(2) NOT NULL,
	"V_ORDER" CHAR(1) DEFAULT 'N' NOT NULL,
    CONSTRAINT "PK_VENDOR" PRIMARY KEY ("V_CODE") VALIDATE ) TABLESPACE "CUSTOMERSALES";
	
CREATE TABLE "CUSTOMERSALES"."PRODUCT" ( 
    "P_CODE" VARCHAR(10), 
    "P_DESCRIPT" VARCHAR(35) NOT NULL, 
    "P_INDATE" DATE NOT NULL, 
    "P_QOH" NUMBER(5,0) NOT NULL, 
    "P_MIN" NUMBER(5,0) NOT NULL, 
    "P_PRICE" NUMBER(8,2) NOT NULL,
	"P_DISCOUNT" NUMBER(5,2) NOT NULL,
	"V_CODE" NUMBER NOT NULL,
    CONSTRAINT "PK_PRODUCT" PRIMARY KEY ("P_CODE") VALIDATE,
    CONSTRAINT "FK_PRODUCT" FOREIGN KEY ("V_CODE") REFERENCES "CUSTOMERSALES"."CUSTOMER" ("CUS_CODE") VALIDATE ) TABLESPACE "CUSTOMERSALES";

CREATE TABLE "CUSTOMERSALES"."LINE" ( 
    "INV_NUMBER" NUMBER,
    "LINE_NUMBER" NUMBER(2,0),
    "P_CODE" VARCHAR2(10) NOT NULL,
    "LINE_UNITS" NUMBER(9,2) DEFAULT 0.00 NOT NULL,
    "LINE_PRICE" NUMBER(9,2) DEFAULT 0.00 NOT NULL,
    CONSTRAINT "PK_LINE" PRIMARY KEY ("INV_NUMBER", "LINE_NUMBER") VALIDATE,
    CONSTRAINT "FK_LINE" FOREIGN KEY ("INV_NUMBER") REFERENCES "CUSTOMERSALES"."INVOICE" ("INV_NUMBER") VALIDATE,
    CONSTRAINT "FK2_LINE" FOREIGN KEY ("P_CODE") REFERENCES "CUSTOMERSALES"."PRODUCT" ("P_CODE") VALIDATE) TABLESPACE "CUSTOMERSALES";
   

-- Add some constraint checks as per business rules
ALTER TABLE "CUSTOMERSALES"."PRODUCT" ADD ( 
	CONSTRAINT "CHK_P_PRICE" CHECK (P_PRICE > 0 AND P_PRICE < 1000) VALIDATE );
	
ALTER TABLE "CUSTOMERSALES"."LINE" ADD ( 
	CONSTRAINT "CHK_LINE_PRICE" CHECK (LINE_PRICE > 0 AND LINE_PRICE < 1200) VALIDATE );
-- Not sure if these commit lines are needed, investigate
COMMIT;


-- Checks the current profiles for CUSTPROFILE
--   Removes if found
DECLARE 
	v_counter NUMBER :=0;
BEGIN
	/* Check to see if profile exists */
	select count(*) 
	into v_counter from dba_profiles 
	where
	profile='CUSTPROFILE';

	/* If exists, delete it */
	IF v_counter=1
	THEN
    		DBMS_OUTPUT.PUT_LINE ('DROPPING CUSTPROFILE PROFILE....');
    		EXECUTE IMMEDIATE ('DROP PROFILE CUSTPROFILE');
	END IF;
END;
/

-- Create the CUSTPROFILE profile with a idle timeout of 10 mins 
CREATE PROFILE "CUSTPROFILE" LIMIT CPU_PER_SESSION DEFAULT
CPU_PER_CALL DEFAULT
CONNECT_TIME DEFAULT
IDLE_TIME 10
SESSIONS_PER_USER DEFAULT
LOGICAL_READS_PER_SESSION DEFAULT
LOGICAL_READS_PER_CALL DEFAULT
PRIVATE_SGA DEFAULT
COMPOSITE_LIMIT DEFAULT
PASSWORD_LIFE_TIME DEFAULT
PASSWORD_GRACE_TIME DEFAULT
PASSWORD_REUSE_MAX DEFAULT
PASSWORD_REUSE_TIME DEFAULT
PASSWORD_LOCK_TIME DEFAULT
FAILED_LOGIN_ATTEMPTS DEFAULT
PASSWORD_VERIFY_FUNCTION DEFAULT;
COMMIT;


-- Check current roles for CUSTCLERK
--   Remove if found
DECLARE 
	v_counter NUMBER :=0;
BEGIN
	/* Check to see if role exists */
	select count(*) 
	into v_counter from dba_roles 
	where
	role='CUSTCLERK';

	/* If exists, delete it */
	IF v_counter=1
	THEN
    		DBMS_OUTPUT.PUT_LINE ('DROPPING CUSTCLERK ROLE....');
    		EXECUTE IMMEDIATE ('DROP ROLE CUSTCLERK');
	END IF;
END;
/

-- Create the CUSTCLERK role
--   A basic role for updating and retrieving information
CREATE ROLE "CUSTCLERK" NOT IDENTIFIED;
GRANT SELECT ON "CUSTOMERSALES"."CUSTOMER" TO "CUSTCLERK";
GRANT UPDATE ON "CUSTOMERSALES"."CUSTOMER" TO "CUSTCLERK";
GRANT SELECT ON "CUSTOMERSALES"."INVOICE" TO "CUSTCLERK";
GRANT UPDATE ON "CUSTOMERSALES"."INVOICE" TO "CUSTCLERK";
GRANT SELECT ON "CUSTOMERSALES"."LINE" TO "CUSTCLERK";
GRANT UPDATE ON "CUSTOMERSALES"."LINE" TO "CUSTCLERK";
GRANT SELECT ON "CUSTOMERSALES"."PRODUCT" TO "CUSTCLERK";
GRANT UPDATE ON "CUSTOMERSALES"."PRODUCT" TO "CUSTCLERK";
GRANT SELECT ON "CUSTOMERSALES"."VENDOR" TO "CUSTCLERK";
GRANT UPDATE ON "CUSTOMERSALES"."VENDOR" TO "CUSTCLERK";


-- Check for the CUSTMANAGER role
--   Remove if found
DECLARE 
	v_counter NUMBER :=0;
BEGIN
	/* Check to see if role exists */
	select count(*) 
	into v_counter from dba_roles 
	where
	role='CUSTMANAGER';

	/* If exists, delete it */
	IF v_counter=1
	THEN
    		DBMS_OUTPUT.PUT_LINE ('DROPPING CUSTMANAGER ROLE....');
    		EXECUTE IMMEDIATE ('DROP ROLE CUSTMANAGER');
	END IF;
END;
/

-- Create the CUSTMANAGER role
--   This is a higher level role allowing for removing and inserting new customers
CREATE ROLE "CUSTMANAGER" NOT IDENTIFIED;
GRANT DELETE ON "CUSTOMERSALES"."CUSTOMER" TO "CUSTMANAGER";
GRANT INSERT ON "CUSTOMERSALES"."CUSTOMER" TO "CUSTMANAGER";
GRANT DELETE ON "CUSTOMERSALES"."INVOICE" TO "CUSTMANAGER";
GRANT INSERT ON "CUSTOMERSALES"."INVOICE" TO "CUSTMANAGER";
GRANT DELETE ON "CUSTOMERSALES"."LINE" TO "CUSTMANAGER";
GRANT INSERT ON "CUSTOMERSALES"."LINE" TO "CUSTMANAGER";
GRANT DELETE ON "CUSTOMERSALES"."PRODUCT" TO "CUSTMANAGER";
GRANT INSERT ON "CUSTOMERSALES"."PRODUCT" TO "CUSTMANAGER";
GRANT DELETE ON "CUSTOMERSALES"."VENDOR" TO "CUSTMANAGER";
GRANT INSERT ON "CUSTOMERSALES"."VENDOR" TO "CUSTMANAGER";
GRANT "CUSTCLERK" TO "CUSTMANAGER";
COMMIT;


-- Check to see if end user already exists in database
--   Remove if found
DECLARE 
	v_counter NUMBER :=0;
BEGIN
	/* Check to see if user exists */
	select count(*) 
	into v_counter from dba_users 
	where
	username='TOM';

	/* If exists, delete it */
	IF v_counter=1
	THEN
    		DBMS_OUTPUT.PUT_LINE ('DROPPING USER TOM....');
    		EXECUTE IMMEDIATE ('DROP USER TOM');
	END IF;
END;
/

-- Create the TOM user of our app
--   Tom is a clerk
CREATE USER "TOM" PROFILE "CUSTPROFILE" IDENTIFIED BY "Tomclerk" PASSWORD EXPIRE DEFAULT TABLESPACE "CUSTOMERSALES" ACCOUNT UNLOCK;
GRANT "CONNECT" TO "TOM";
GRANT "CUSTCLERK" TO "TOM";


-- Check for end user MAYA
--   Remove if found
DECLARE 
	v_counter NUMBER :=0;
BEGIN
	/* Check to see if user exists */
	select count(*) 
	into v_counter from dba_users 
	where
	username='MAYA';

	/* If exists, delete it */
	IF v_counter=1
	THEN
    		DBMS_OUTPUT.PUT_LINE ('DROPPING USER MAYA....');
    		EXECUTE IMMEDIATE ('DROP USER MAYA');
	END IF;
END;
/

-- Create the Maya end user
--   Maya is a clerk for the customers app
CREATE USER "MAYA" PROFILE "CUSTPROFILE" IDENTIFIED BY "Mayaclerk" PASSWORD EXPIRE DEFAULT TABLESPACE "CUSTOMERSALES" ACCOUNT UNLOCK;
GRANT "CONNECT" TO "MAYA";
GRANT "CUSTCLERK" TO "MAYA";


-- Check to see if the end user SALLY exists
--   Remove if found
DECLARE 
	v_counter NUMBER :=0;
BEGIN
	/* Check to see if user exists */
	select count(*) 
	into v_counter from dba_users 
	where
	username='SALLY';

	/* If exists, delete it */
	IF v_counter=1
	THEN
    		DBMS_OUTPUT.PUT_LINE ('DROPPING USER SALLY....');
    		EXECUTE IMMEDIATE ('DROP USER SALLY');
	END IF;
END;
/

-- Create the Sally user
--   Sally is a manager for the customers app, has privledges of clerk as well
CREATE USER "SALLY" PROFILE "CUSTPROFILE" IDENTIFIED BY "Custman" PASSWORD EXPIRE DEFAULT TABLESPACE "CUSTOMERSALES" ACCOUNT UNLOCK;
GRANT "CONNECT" TO "SALLY";
GRANT "CUSTMANAGER" TO "SALLY";

-- Broken trigger attempt, need to make a temp table
/* 
ALTER SYSTEM SET resource_limit = TRUE SCOPE=MEMORY;

CREATE OR REPLACE TRIGGER "CUSTOMERSALES"."TRG_INVOICE_LINE" 
	BEFORE DELETE OR INSERT OR UPDATE ON "CUSTOMERSALES"."LINE" FOR EACH ROW 
DECLARE
	v_net NUMBER
	v_tax NUMBER
	v_total NUMBER
	v_line_total NUMBER;
BEGIN
	v_line_total := LINE_PRICE * LINE_UNITS
	v_net := "INVOICE"."INV_NET" + v_line_total
	v_total := v_net * 1.12 + "INVOICE"."INV_TOTAL"
	IF UPDATING THEN
		UPDATE "CUSTOMERSALES"."INVOICE" SET INV_NET = v_net WHERE INV_NUMBER = 105;
		UPDATE "CUSTOMERSALES"."INVOICE" SET INV_NET = INV_NET +  WHERE employee_id = 105;
	END IF;
	IF INSERTING THEN
		UPDATE "CUSTOMERSALES"."INVOICE" SET INV_NET = INV_NET +  WHERE employee_id = 105;
	END IF;
	IF DELETING THEN
		UPDATE "CUSTOMERSALES"."INVOICE" SET INV_NET = INV_NET +  WHERE employee_id = 105;
END; */
