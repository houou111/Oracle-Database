exec DBMS_SERVICE.CREATE_SERVICE( -
  service_name => 'PC01PROD', -
  network_name => 'PC01PROD', -
  failover_method => 'BASIC', -
  failover_type => 'SELECT', -
  failover_retries => 180, -
  failover_delay => 1);
