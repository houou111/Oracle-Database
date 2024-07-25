select name, value from v$sysstat where lower(name) like lower('%&1%');
