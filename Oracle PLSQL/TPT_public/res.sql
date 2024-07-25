select keyword, reserved, res_type, res_attr, res_semi, duplicate 
from v$reserved_words where lower(keyword) like '%&1%';
