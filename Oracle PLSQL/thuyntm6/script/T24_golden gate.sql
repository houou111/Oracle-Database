------------------------------------------------------------------
--golden gate
------------------------------------------------------------------
[t24db02@oracle /u01/t24data/gg12>]$
./ggsci
info all
view params <>
----------------
GGSCI (t24db02) 6> view param mgr

port 7800
DYNAMICPORTLIST 7810-7849
PURGEOLDEXTRACTS /export_oracle/gg_folder/dirdat/*, USECHECKPOINTS, MINKEEPFILES 300 
AUTORESTART EXTRACT PDWDC ,RETRIES 20 ,WAITMINUTES 2

-----------------Chuyển từ DR sang DC
0. Verify before DRP:
192.168.11.131
cd /u01/t24data/gg12
./ggsci

/* note lai status */
send extract ET24DC, showstran
stop ET24DC
--12h06
/* wait 10 mins*/
stop PDWDC
stop mgr
info all

1. Move file GG:
192.168.11.40:
cd /u01/t24data/gg12
mv  dirprm dirprm_old
mv  dirpcs dirpcs_old
mv  dirrpt dirrpt_old
mv  dirdat dirdat_old
mv  dirout dirout_old
mv  dirtmp dirtmp_old
mv  dirdef dirdef_old
mv  dirsql dirsql_old
mv  dirchk dirchk_old
mv  dircrd dircrd_old

192.168.11.131:
cd /u01/t24data/gg12/
scp -r dirprm dirrpt dirdat dirout dirtmp dirdef dirsql dirchk dircrd dirpcs  oracle@192.168.11.40:/u01/t24data/gg12
scp -r /export_oracle/gg_folder/dirrpt oracle@192.168.11.40:/export_oracle/gg_folder/

/* copy 20 latest trailfiles*/
scp -r /export_oracle/gg_folder/dirdat/dc21412* oracle@192.168.11.40:/export_oracle/gg_folder/dirdat/
scp -r /export_oracle/gg_folder/dirdat/dc21411* oracle@192.168.11.40:/export_oracle/gg_folder/dirdat/

scp -r /export_oracle/gg_folder/dirdat/dc21468* oracle@192.168.11.40:/export_oracle/gg_folder/dirdat/
scp -r /export_oracle/gg_folder/dirdat/dc21467* oracle@192.168.11.40:/export_oracle/gg_folder/dirdat/
dc21468


/* thay doi lai cau hinh Oracle_home và tnsname database*/
192.168.11.40:
cd dirprm
mv et24dc.prm et24dc.prm.DR
mv et24dc.prm.DC et24dc.prm


/* sau khi DRP xong he thong*/
2. Start Extract T24:
start ET24DC

/*wait 5 mins*/
start PDWDC
info PDWDC detail



