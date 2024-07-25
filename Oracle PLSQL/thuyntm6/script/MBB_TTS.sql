Create or replace directory exp_tts_dir as '/backupdata/dump/mbbdb2';
Create or replace directory exp_tts_dir as '/backup200/dump/mobotp2';


--Step 1: Validating Self Containing Property 
exec DBMS_TTS.TRANSPORT_SET_CHECK('USERS', TRUE); 
SELECT * FROM transport_set_violations; 

--Step 2: Put Tablespaces in READ ONLY Mode 
alter tablespace USERS read only;

--Step 3: Export the Metadata 
expdp DUMPFILE=tts_${ORACLE_SID}.dmp LOGFILE=tts_${ORACLE_SID}.log DIRECTORY=exp_tts_dir TRANSPORT_TABLESPACES=USERS TRANSPORT_FULL_CHECK=y

--expdp directory=exp_tts_dir metrics=y dumpfile=mobotp_xttsfulltts%U.dmp filesize=1048576000 logfile=expfulltts.log transportable=always EXCLUDE=STATISTICS
expdp directory=exp_tts_dir dumpfile=${ORACLE_SID}_expmetadata.dmp logfile=${ORACLE_SID}_expmetadata.log EXCLUDE=STATISTICS  full=y content=metadata_only 

--backup
rman target / 
run
{
allocate channel d01 device type disk;          
allocate channel d02 device type disk;
allocate channel d03 device type disk;
allocate channel d04 device type disk;
allocate channel d05 device type disk;
allocate channel d06 device type disk;
allocate channel d07 device type disk;
allocate channel d08 device type disk;
convert tablespace USERS to platform="IBM zSeries Based Linux" FORMAT '/backup200/dump/mobotp2/%U';
}


run
{
allocate channel d01 device type disk;          
allocate channel d02 device type disk;
allocate channel d03 device type disk;
allocate channel d04 device type disk;
allocate channel d05 device type disk;
allocate channel d06 device type disk;
allocate channel d07 device type disk;
allocate channel d08 device type disk;
convert tablespace USERS to platform="IBM zSeries Based Linux" FORMAT '/backupdata/dump/mbbdb2/%U';
}



=======================LOG
[oracle@dr-ora-db01 bin]$ rman target /

Recovery Manager: Release 11.2.0.4.0 - Production on Mon Jan 15 17:29:55 2018

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.

connected to target database: RESMBB (DBID=2169924089)

RMAN> run
2> {
3> allocate channel d01 device type disk;          
4> allocate channel d02 device type disk;
5> allocate channel d03 device type disk;
6> allocate channel d04 device type disk;
7> allocate channel d05 device type disk;
8> allocate channel d06 device type disk;
9> allocate channel d07 device type disk;
10> allocate channel d08 device type disk;
11> convert tablespace USERS to platform="IBM zSeries Based Linux" FORMAT '/stage/backup/%U';
12> )

RMAN-00571: ===========================================================
RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
RMAN-00571: ===========================================================
RMAN-00558: error encountered while parsing input commands
RMAN-01009: syntax error: found ")": expecting one of: "advise, allocate, alter, backup, @, catalog, change, configure, convert, copy, crosscheck, delete, duplicate, execute, flashback, host, mount, open, recover, release, repair, report, restore, resync, send, set, show, shutdown, sql, startup, switch, transport, validate, }"
RMAN-01007: at line 12 column 1 file: standard input

RMAN> run
2> {
3> allocate channel d01 device type disk;          
4> allocate channel d02 device type disk;
5> allocate channel d03 device type disk;
6> allocate channel d04 device type disk;
7> allocate channel d05 device type disk;
8> allocate channel d06 device type disk;
9> allocate channel d07 device type disk;
10> allocate channel d08 device type disk;
11> convert tablespace USERS to platform="IBM zSeries Based Linux" FORMAT '/stage/backup/%U';
12> }

using target database control file instead of recovery catalog
allocated channel: d01
channel d01: SID=6 device type=DISK

allocated channel: d02
channel d02: SID=194 device type=DISK

allocated channel: d03
channel d03: SID=387 device type=DISK

allocated channel: d04
channel d04: SID=574 device type=DISK

allocated channel: d05
channel d05: SID=766 device type=DISK

allocated channel: d06
channel d06: SID=956 device type=DISK

allocated channel: d07
channel d07: SID=1147 device type=DISK

allocated channel: d08
channel d08: SID=1337 device type=DISK

Starting conversion at source at 15-JAN-18
channel d01: starting datafile conversion
input datafile file number=00006 name=+DATA03/resmbb/datafile/users.633.965474217
channel d02: starting datafile conversion
input datafile file number=00007 name=+DATA03/resmbb/datafile/users.630.965474217
channel d03: starting datafile conversion
input datafile file number=00008 name=+DATA03/resmbb/datafile/users.628.965474217
channel d04: starting datafile conversion
input datafile file number=00009 name=+DATA03/resmbb/datafile/users.627.965474217
channel d05: starting datafile conversion
input datafile file number=00010 name=+DATA04/resmbb/datafile/users.361.965474217
channel d06: starting datafile conversion
input datafile file number=00011 name=+DATA04/resmbb/datafile/users.363.965474217
channel d07: starting datafile conversion
input datafile file number=00012 name=+DATA04/resmbb/datafile/users.362.965474217
channel d08: starting datafile conversion
input datafile file number=00013 name=+DATA04/resmbb/datafile/users.375.965474219
   converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-8_03soojq9
channel d03: datafile conversion complete, elapsed time: 00:07:47
channel d03: starting datafile conversion
input datafile file number=00014 name=+DATA04/resmbb/datafile/users.376.965474845
converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-7_02soojq9
channel d02: datafile conversion complete, elapsed time: 00:08:13
channel d02: starting datafile conversion
input datafile file number=00015 name=+DATA04/resmbb/datafile/users.460.965474845
converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-9_04soojqa
channel d04: datafile conversion complete, elapsed time: 00:08:19
channel d04: starting datafile conversion
input datafile file number=00016 name=+DATA04/resmbb/datafile/users.459.965474845
converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-6_01soojq9
channel d01: datafile conversion complete, elapsed time: 00:08:35
channel d01: starting datafile conversion
input datafile file number=00017 name=+DATA04/resmbb/datafile/users.455.965474845
converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-12_07soojqa
channel d07: datafile conversion complete, elapsed time: 00:08:49
channel d07: starting datafile conversion
input datafile file number=00018 name=+DATA04/resmbb/datafile/users.487.965474849
converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-13_08soojqa
channel d08: datafile conversion complete, elapsed time: 00:08:53
channel d08: starting datafile conversion
input datafile file number=00021 name=+DATA04/resmbb/datafile/users.488.965474855
converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-10_05soojqa
channel d05: datafile conversion complete, elapsed time: 00:09:08
channel d05: starting datafile conversion
input datafile file number=00022 name=+DATA04/resmbb/datafile/users.489.965474863
converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-11_06soojqa
channel d06: datafile conversion complete, elapsed time: 00:09:34
channel d06: starting datafile conversion
input datafile file number=00004 name=+DATA03/resmbb/datafile/users.625.965474863
   converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-14_09sook8s
channel d03: datafile conversion complete, elapsed time: 00:09:13
channel d03: starting datafile conversion
input datafile file number=00019 name=+DATA04/resmbb/datafile/users.490.965475199
converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-4_0gsookc8
channel d06: datafile conversion complete, elapsed time: 00:07:29
channel d06: starting datafile conversion
input datafile file number=00020 name=+DATA04/resmbb/datafile/users.491.965475515
converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-15_0asook9m
channel d02: datafile conversion complete, elapsed time: 00:08:54
channel d02: starting datafile conversion
input datafile file number=00026 name=+DATA04/resmbb/datafile/users.492.965475531
 converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-17_0csookac
channel d01: datafile conversion complete, elapsed time: 00:09:18
channel d01: starting datafile conversion
input datafile file number=00027 name=+DATA04/resmbb/datafile/users.493.965475557
converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-16_0bsook9t
channel d04: datafile conversion complete, elapsed time: 00:09:33
channel d04: starting datafile conversion
input datafile file number=00023 name=+DATA04/resmbb/datafile/users.494.965475557
converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-18_0dsookar
channel d07: datafile conversion complete, elapsed time: 00:09:02
channel d07: starting datafile conversion
input datafile file number=00024 name=+DATA04/resmbb/datafile/users.495.965475723
converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-21_0esookav
channel d08: datafile conversion complete, elapsed time: 00:08:59
channel d08: starting datafile conversion
input datafile file number=00025 name=+DATA04/resmbb/datafile/users.496.965475749
converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-22_0fsookbe
channel d05: datafile conversion complete, elapsed time: 00:08:50
converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-24_0msookrq
channel d07: datafile conversion complete, elapsed time: 00:01:25
converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-26_0jsookqc
channel d02: datafile conversion complete, elapsed time: 00:02:20
converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-25_0nsookrq
channel d08: datafile conversion complete, elapsed time: 00:01:35
converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-23_0lsookrq
channel d04: datafile conversion complete, elapsed time: 00:01:55
converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-27_0ksookrq
channel d01: datafile conversion complete, elapsed time: 00:02:05
 converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-19_0hsookq5
channel d03: datafile conversion complete, elapsed time: 00:05:47
 converted datafile=/stage/backup/data_D-RESMBB_I-2169924089_TS-USERS_FNO-20_0isookq9
channel d06: datafile conversion complete, elapsed time: 00:06:14
Finished conversion at source at 15-JAN-18
released channel: d01
released channel: d02
released channel: d03
released channel: d04
released channel: d05
released channel: d06
released channel: d07
released channel: d08

RMAN>                        


