Shutdown T24 Apps	Year, Month, Postcob
1. Shutdown DB T24 2 nodes	
2. Configure 2 OSA interfaces to RAC on both nodes	"$GRID_HOME/bin/oifcfg setif -global <interface>/<subnet>:cluster_interconnect

For example:
$GRID_HOME/bin/oifcfg setif -global enp0s8/192.168.57.0:cluster_interconnect

192.168.2.173 (HAIP1 interface enccw0.0.a800)
192.168.2.177 (HAIP2 interface enccw0.0.a900)

/u01/app/grid/product/12.1.0/grid/bin/oifcfg setif -global enccw0.0.a800/192.168.2.172:cluster_interconnect
/u01/app/grid/product/12.1.0/grid/bin/oifcfg setif -global enccw0.0.a900/192.168.2.176:cluster_interconnect
 
/u01/app/grid/product/12.1.0/grid/bin/oifcfg delif -global enccw0.0.f400/192.168.2.144

enccw0.0.f400/192.168.2.144  global  cluster_interconnect

/u01/app/grid/product/12.1.0/grid/bin/oifcfg iflist -p -n


/u01/app/grid/product/12.1.0/grid/bin/crsctl stop crs
/u01/app/grid/product/12.1.0/grid/bin/crsctl start crs
crsctl stat res -t -init

3. Delete 2 Hyper sockets interconnect from RAC	"$GRID_HOME/bin/oifcfg delif -global <interface>/<subnet>

For example:
$GRID_HOME/bin/oifcfg delif -global enp0s8/192.168.57.0"
4.Verify the interconnect at Grid and DB level	
$GRID_HOME/bin/oifcfg iflist -p -n
$GRID_HOME/bin/oifcfg iflist
SQL> select name,ip_address from v$cluster_interconnects;"


Get the list of IP Address at Grid level and note the interface, subnet details	$GRID_HOME/bin/oifcfg iflist -p -n
Configure Hypersocket interface to RAC	"$GRID_HOME/bin/oifcfg setif -global <interface>/<subnet>:cluster_interconnect

For example:
$GRID_HOME/bin/oifcfg setif -global enp0s8/192.168.57.0:cluster_interconnect"
Delete all OSA interconnect from RAC	"$GRID_HOME/bin/oifcfg delif -global <interface>/<subnet>

For example:
$GRID_HOME/bin/oifcfg delif -global enp0s8/192.168.57.0"
Restart Cluster on ALL nodes for HAIP to pick up the new interface. It is insufficient to restart CRS in rolling manner. This should be done as root user	"$GRID_HOME/bin/crsctl stop crs -f
$GRID_HOME/bin/crsctl start crs -f"
Verify the interconnect at Grid and DB level	"$GRID_HOME/bin/oifcfg iflist -p -n

SQL> select name,ip_address from v$cluster_interconnects;"
Get the list of IP Address at Grid level and note the interface, subnet details	$GRID_HOME/bin/oifcfg iflist -p -n


  
	   
================================================================
==========================DC====================================
================================================================	   


Shutdown T24 Apps	Year, Month, Postcob
1. Shutdown DB T24 2 nodes	- stop GG
stop GG on node1
cd $GGATE
./ggsci
info all
stop ET24DC
stop PDWDC
stop mgr
info all

srvctl stop database -d cobr14dc
srvctl stop database -d t24r14dc

2. Configure 2 OSA interfaces to RAC on both nodes	
--DR
192.168.2.173 (HAIP1 interface enccw0.0.a800)
192.168.2.177 (HAIP2 interface enccw0.0.a900)
--DC
192.168.2.181 (HAIP1)
192.168.2.185 (HAIP2)
192.168.2.182 (HAIP1) 
192.168.2.186 (HAIP2)


		
		
- stop iptable [optional]
service iptables status
service iptables stop
- restart gpnp in both nodes [optional]
crsctl stop res ora.gpnpd -init
crsctl start res ora.gpnpd -init

/u01/app/grid/product/12.1.0/grid/bin/oifcfg setif -global enccw0.0.a800/192.168.2.180:cluster_interconnect
/u01/app/grid/product/12.1.0/grid/bin/oifcfg setif -global enccw0.0.a900/192.168.2.184:cluster_interconnect
 
3. del Hypersocket interface
/u01/app/grid/product/12.1.0/grid/bin/oifcfg delif -global enccw0.0.f400/192.168.2.0

4. Check
/u01/app/grid/product/12.1.0/grid/bin/oifcfg iflist -p -n
select name,ip_address from v$cluster_interconnects;

5. Restart CRS - start database
/u01/app/grid/product/12.1.0/grid/bin/crsctl stop crs
/u01/app/grid/product/12.1.0/grid/bin/crsctl start crs
crsctl stat res -t -init

srvctl start database -d t24r14dc

--> check DB

cd $GGATE
./ggsci
start mgr
start ET24DC
start PDWDC
info all

srvctl start database -d cobr14dc