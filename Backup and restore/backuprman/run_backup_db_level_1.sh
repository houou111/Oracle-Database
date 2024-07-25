target='target /'
rcvcat='nocatalog'
freq=24
time=`date '+%H%M%S'`
cmdfile=/u02/backuprman/backup_db_level_1.rcv
msglog=/u02/backuprman/backuplog/level1/rman_level1_$time.log
#rman $target $rcvcat cmdfile $cmdfile msglog $msglog
rman $target $rcvcat cmdfile $cmdfile 
exit
