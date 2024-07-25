target='target /'
rcvcat='nocatalog'
freq=24
time=`date '+%H%M%S'`
cmdfile=/u02/backuprman/backup_db_level_0.rcv
msglog=/u02/backuprman/backuplog/level0/rman_level0_$time.log
cd /u02/backuprman/backupfull/
rm -f *
rman $target $rcvcat cmdfile $cmdfile 
cd /u02/backuprman/backuplevel1/
rm -f *
exit