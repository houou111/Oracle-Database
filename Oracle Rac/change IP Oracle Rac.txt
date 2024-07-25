--1.Changing public network interface, subnet or netmask
$CRS_HOME/bin/oifcfg getif
$CRS_HOME/bin/oifcfg iflist -p -n

$CRS_HOME/bin/oifcfg delif -global enccw0.0.0600/10.110.1.0
$CRS_HOME/bin/oifcfg setif -global enccw0.0.0600/192.168.11.0:public

--------LOG
[grid@dr-core-db-01 ~]$ cd $CRS_HOME/bin
[grid@dr-core-db-01 bin]$ oifcfg getif
enccw0.0.0600  10.110.1.0  global  public
enccw0.0.f400  192.168.2.144  global  cluster_interconnect

[grid@dr-core-db-01 bin]$ oifcfg iflist -p -n
enccw0.0.0600  10.110.1.0  PRIVATE  255.255.255.0
enccw0.0.f400  192.168.2.144  PRIVATE  255.255.255.252
enccw0.0.f400  169.254.0.0  UNKNOWN  255.255.0.0

[grid@dr-core-db-01 bin]$ oifcfg delif -global enccw0.0.0600/10.110.1.0

[grid@dr-core-db-01 bin]$ oifcfg getif
enccw0.0.f400  192.168.2.144  global  cluster_interconnect

[grid@dr-core-db-01 bin]$ oifcfg setif -global enccw0.0.0600/192.168.11.0:public

[grid@dr-core-db-01 bin]$ oifcfg getif
enccw0.0.f400  192.168.2.144  global  cluster_interconnect
enccw0.0.0600  192.168.11.0  global  public
--------LOG

--2.Then make the change at OS layer. There is no requirement to restart Oracle clusterware unless OS change requires a node reboot. 
--Also make network changes for SCAN.

--3.Change the /etc/hosts files to reflect new IPs 

192.168.11.191 dr-core-db-01
192.168.11.192 dr-core-db-02
192.168.11.193 dr-core-db-01-vip
192.168.11.194 dr-core-db-02-vip

--4.Changing VIPs associated with public network change

### On node 1
srvctl config nodeapps -a
srvctl stop instance -d t24dr -n dr-core-db-01
srvctl stop vip -n dr-core-db-01 -f

## As a root user 
srvctl modify nodeapps -n dr-core-db-01 -A dr-core-db-01-vip/255.255.255.0/enccw0.0.0600

Verify the change and start the resources:
srvctl config nodeapps -a
srvctl start vip -n dr-core-db-01
srvctl start listener -n dr-core-db-01
srvctl start instance -d t24dr -n dr-core-db-01 

### On node 2
srvctl config nodeapps -a
srvctl stop instance -d t24dr -n dr-core-db-02
srvctl stop vip -n dr-core-db-02 -f

## As a root user 
srvctl modify nodeapps -n dr-core-db-02 -A dr-core-db-02-vip/255.255.255.0/enccw0.0.0600

Verify the change and start the resources:
srvctl config nodeapps -a
srvctl start vip -n dr-core-db-02
srvctl start listener -n dr-core-db-02
srvctl start instance -d t24dr -n dr-core-db-02

--5.Modify listener.ora, tnsnames.ora and LOCAL_LISTENER/REMOTE_LISTENER parameter to reflect the VIP change if necessary.

Modify Scan Listeners : 

$GRID_HOME/bin/srvctl stop scan_listener
$GRID_HOME/bin/srvctl stop scan
$GRID_HOME/bin/srvctl status scan
$GRID_HOME/bin/srvctl status scan_listener

## As a root user 
$GRID_HOME/bin/srvctl config scan
$GRID_HOME/bin/srvctl modify scan -n dr-core-db-scan
$GRID_HOME/bin/srvctl config scan

$GRID_HOME/bin/srvctl start scan
$GRID_HOME/bin/srvctl start scan_listener

