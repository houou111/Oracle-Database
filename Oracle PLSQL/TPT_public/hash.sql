--------------------------------------------------------------------------------
--
-- File name:   hash.sql
-- Purpose:     Show the hash value, SQL_ID and child number of previously
--              executed SQL in session
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @hash
-- 	        
--	        
-- Other:       Doesn't work on 9i for 2 reasons. There appears to be a bug
--              with v$session.prev_hash_value in 9.2.x and there's no SQL_ID
--              column in 9i.
--
--------------------------------------------------------------------------------

select 
    prev_hash_value                         hash_value
  , prev_sql_id                             sql_id
  , prev_child_number                       child_number
--  , to_char(prev_hash_value, 'XXXXXXXX')    hash_hex
from 
    v$session 
where 
    sid = (select sid from v$mystat where rownum = 1)
/
