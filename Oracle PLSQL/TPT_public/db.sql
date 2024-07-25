select 
    dbid
  , name
  , log_mode
  , open_mode
  , current_scn scn 
  , '0x'||trim(to_char(current_scn,'XXXXXXXXXXXX')) hex_scn 
  , platform_name
from 
    v$database
/

