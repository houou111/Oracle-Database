==========ON DC

node 1

alter diskgroup CRS add disk  '/dev/rhdisk3'  drop disk CRS_0000 REBALANCE power 10;

alter diskgroup DATA01 add disk '/dev/rhdisk20','/dev/rhdisk21'
  drop disk DATA01_0004, DATA01_0005, DATA01_0006, DATA01_0007, DATA01_0008, DATA01_0009,
 DATA01_0000, DATA01_0001, DATA01_0002, DATA01_0003 REBALANCE power 10;
 
alter diskgroup FRA01 add disk '/dev/rhdisk22','/dev/rhdisk23'   drop disk FRA01_0001,FRA01_0000  REBALANCE power 10;

[root@dc-esb-db01]#
rhdisk3  2.00 GB                  ESB-Volting
rhdisk20 400.00 GB            ESB-DB
rhdisk21 400.00 GB            ESB-DB
rhdisk22 200.00 GB            ESB-ArchiveLog-02
rhdisk23 200.00 GB            ESB-ArchiveLog-02


[root@dc-esb-db02:/]
hdisk27  2.00 GB                               ESB-Volting
hdisk28  400.00 GB                           ESB-DB
hdisk29  400.00 GB                           ESB-DB
hdisk30  200.00 GB                           ESB-ArchiveLog-02
hdisk31  200.00 GB                           ESB-ArchiveLog-02

   
-------
10.99.1.49
CRS
/dev/rhdisk4
DATA
/dev/rhdisk10
/dev/rhdisk11
/dev/rhdisk12
/dev/rhdisk13
/dev/rhdisk14
/dev/rhdisk15
/dev/rhdisk6
/dev/rhdisk7
/dev/rhdisk8
/dev/rhdisk9
FRA
/dev/rhdisk19
/dev/rhdisk5
		   
		   
10.99.1.50
CRS
/dev/rhdisk4
DATA
/dev/rhdisk16
/dev/rhdisk17
/dev/rhdisk18
/dev/rhdisk19
/dev/rhdisk20
/dev/rhdisk21
/dev/rhdisk22
/dev/rhdisk23
/dev/rhdisk24
/dev/rhdisk25
FRA
/dev/rhdisk1
/dev/rhdisk15		   
==========ON DR
DR-ESB-DB01
/dev/rhdisk18  SIZE: 2.00 GB                                                     volting disk
/dev/rhdisk19  SIZE: 400.00 GB                                                Database
/dev/rhdisk22  SIZE: 200.00 GB                                                Archive log
/dev/rhdisk21  SIZE: 200.00 GB                                                Archive log
/dev/rhdisk20  SIZE: 400.00 GB                                                Database

CRS
DATA01_DR
FRA01_DR
RESTORE15

alter diskgroup CRS add disk '/dev/rhdisk18'     drop disk CRS_0000 REBALANCE power 10;

alter diskgroup DATA01_DR add disk '/dev/rhdisk19' ,'/dev/rhdisk20'    
drop disk DATA01_DR_0008, DATA01_DR_0009, DATA01_DR_0000, DATA01_DR_0005, DATA01_DR_0004, DATA01_DR_0006, DATA01_DR_0007, DATA01_DR_0001, DATA01_DR_0002, DATA01_DR_0003
 REBALANCE power 10;

alter diskgroup FRA01_DR add disk '/dev/rhdisk22','/dev/rhdisk21'     drop disk FRA_0001,FRA01_DR_0000 REBALANCE power 10;

DR-ESB-DB02
hdisk17  SIZE: 2.00 GB                                                     volting disk
hdisk21  SIZE: 200.00 GB                                                Archive log
hdisk18  SIZE: 400.00 GB                                                Database
hdisk20  SIZE: 200.00 GB                                                Archive log
hdisk19  SIZE: 400.00 GB                                                Database

---OLD
10.99.1.149
           1 CRS_0000                       /dev/rhdisk14
           2 DATA01_DR_0008                 /dev/rhdisk11
           2 DATA01_DR_0009                 /dev/rhdisk12
           2 DATA01_DR_0000                 /dev/rhdisk3
           2 DATA01_DR_0005                 /dev/rhdisk8
           2 DATA01_DR_0004                 /dev/rhdisk7
           2 DATA01_DR_0006                 /dev/rhdisk9
           2 DATA01_DR_0007                 /dev/rhdisk10
           2 DATA01_DR_0001                 /dev/rhdisk4
           2 DATA01_DR_0002                 /dev/rhdisk5
           2 DATA01_DR_0003                 /dev/rhdisk6
           3 FRA_0001                       /dev/rhdisk17
           3 FRA01_DR_0000                  /dev/rhdisk13
           4 RESTORE15_0000                 /dev/rhdisk15

		   
10.99.1.150
           1 CRS_0000                       /dev/rhdisk14
           2 DATA01_DR_0008                 /dev/rhdisk11
           2 DATA01_DR_0009                 /dev/rhdisk12
           2 DATA01_DR_0000                 /dev/rhdisk3
           2 DATA01_DR_0005                 /dev/rhdisk8
           2 DATA01_DR_0004                 /dev/rhdisk7
           2 DATA01_DR_0006                 /dev/rhdisk9
           2 DATA01_DR_0007                 /dev/rhdisk10
           2 DATA01_DR_0001                 /dev/rhdisk4
           2 DATA01_DR_0002                 /dev/rhdisk5
           2 DATA01_DR_0003                 /dev/rhdisk6
           3 FRA_0001                       /dev/rhdisk16
           3 FRA01_DR_0000                  /dev/rhdisk13
           4 RESTORE15_0000                 /dev/rhdisk15
========================================