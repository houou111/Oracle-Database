COL sqlopt_hash_value HEAD HASH_VALUE
COL sqlopt_sqlid HEAD SQL_ID
COL sqlopt_child# HEAD CHILD#

BREAK ON sqlopt_hash_value SKIP 1 ON sqlopt_sqlid SKIP 1 ON sqlopt_child# SKIP 1


SELECT 
--    inst_id
--  , kqlfsqce_phad
    kqlfsqce_hash           sqlopt_hash_value
  , kqlfsqce_sqlid          sqlopt_sqlid
  , kqlfsqce_chno           sqlopt_child#
--  , kqlfsqce_hadd
--  , kqlfsqce_pnum
  , kqlfsqce_pname          parameter
  , DECODE(BITAND(kqlfsqce_flags, 2), 0, 'NO', 'YES') "DFLT"
  , UPPER(kqlfsqce_pvalue)  value                                         
FROM
    x$kqlfsqce 
WHERE 
    kqlfsqce_hash  = '&1' 
AND kqlfsqce_chno  LIKE ('&2')
AND LOWER(kqlfsqce_pname) LIKE LOWER('%&3%')
ORDER BY
    kqlfsqce_hash
  , kqlfsqce_sqlid
  , kqlfsqce_chno
/
