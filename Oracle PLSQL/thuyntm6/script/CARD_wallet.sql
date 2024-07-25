TWCMS =
  (DESCRIPTION = (LOAD_BALANCE = ON) (FAILOVER = ON)
    (ADDRESS = (PROTOCOL = TCP)(HOST = 10.100.100.96)(PORT = 1521))
	(ADDRESS = (PROTOCOL = TCP)(HOST = 10.100.100.97)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = twcms)
    )
  )

alter tablespace USERS read only;
alter tablespace A4M read only;
alter tablespace TWI read only;
alter tablespace TWI_IDX read only;
alter tablespace TWI_TRAN read only;
alter tablespace TWI_TRAN_IDX read only;
alter tablespace TWI_MESS read only;
alter tablespace TWI_MESS_IDX read only;
alter tablespace TWI_ARC read only;


===================
the steps to create wallet. 
===================

Once the password file is copied to DR server, autologin file needs to be created with password.

####### Node 1

export ORACLE_SID=twr1
export DB_NAME=twr

mkdir -p /u01/app/oracle/product/11.2.0/dbhome_1/admin/${DB_NAME}/wallet
orapki wallet create -wallet /u01/app/oracle/product/11.2.0/dbhome_1/admin/${DB_NAME}/wallet


col WRL_PARAMETER for a80
set lines 300 pages 5000
select * from gv$encryption_wallet;
accept password prompt "Enter New Password:" hide
alter system set encryption wallet open identified by "";
select * from gv$encryption_wallet; 
## Status : OPEN_NO_MASTER_KEY

accept password prompt "Enter New Password:" hide
alter system set encryption key authenticated by "";

select * from gv$encryption_wallet; 
## Status : OPEN

shutdown immediate;

orapki wallet create -wallet /u01/app/oracle/product/11.2.0/dbhome_1/admin/${DB_NAME}/wallet -auto_login_local

startup

col WRL_PARAMETER for a80
set lines 300 pages 5000
select * from gv$encryption_wallet; 

cd /u01/app/oracle/product/11.2.0/dbhome_1/admin/${DB_NAME}/wallet
scp -pr ewallet.p12 dr-card-db-02:/u01/app/oracle/product/11.2.0/dbhome_1/admin/${DB_NAME}/wallet/

####### Node 2
export ORACLE_SID=twr2
export DB_NAME=twr

select name, open_mode from v$database;
shutdown immediate;

cd /u01/app/oracle/product/11.2.0/dbhome_1/admin/${DB_NAME}/wallet
orapki wallet create -wallet /u01/app/oracle/product/11.2.0/dbhome_1/admin/${DB_NAME}/wallet -auto_login_local
startup

set lines 300 pages 5000
col WRL_PARAMETER for a60
select * from gv$encryption_wallet; 
## Status : OPEN

####### On both nodes : 
export DB_NAME=twa
cd /u01/app/oracle/product/11.2.0/dbhome_1/admin/${DB_NAME}/wallet
chmod 700 cwallet.sso ewallet.p12
chattr +i cwallet.sso 
chattr +i ewallet.p12


@xKh[F,#Z~9X
======================
change password


Can I change the wallet password?
Yes, the wallet password can be changed with Oracle Wallet Manager (OWM). 
Create a backup before attempting to change the wallet password. Changing the wallet password does not change the encryption master key — they are independent. 
In Oracle 11gR1 11.1.0.7, orapki has been enhanced to allow wallet password changes from the command line:

 $ orapki wallet change_pwd -wallet <wallet_location>
 
 
 
 
 8.2.2.2 Resetting the Master Encryption Key
Reset/Regenerate the master encryption key only if it has been compromised or as per the security policies of the organization. You should back up the wallet before resetting the master encryption key.

Frequent master encryption key regeneration does not necessarily enhance system security. Security modules can store a large number of keys. However, this number is not unlimited. Frequent master encryption key regeneration can exhaust all available storage space.

To reset the master encryption key, use the SQL syntax as shown in "Setting the Master Encryption Key".

Note:

If you are resetting the master encryption key for a wallet that has auto login enabled, then you must ensure that both the auto login wallet, identified by the .sso file, and the encryption wallet, identified by the .p12 file, are present before issuing the command to reset the master encryption key.
The ALTER SYSTEM SET ENCRYPTION KEY command is a data definition language (DDL) command requiring the ALTER SYSTEM privilege, and it automatically commits any pending transactions. Example 8-1 shows a sample usage of this command.

Example 8-1 Setting or Resetting the Master Encryption Key To Use a PKI-Based Private Key

SQL> ALTER SYSTEM SET ENCRYPTION KEY "j23lm781098dhb345sm" IDENTIFIED BY "password";
Here, j23lm781098dhb345sm is the certificate ID and password is the wallet password.

For PKI-based keys, certificate revocation lists are not enforced as enforcing certificate revocation may lead to losing access to all encrypted information in the database. However, you cannot use the same certificate to create the master key again.