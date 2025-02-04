column fv_ksmfsnam heading SGAVARNAME for a25 wrap
column fv_ksmfstyp heading DATATYPE for a25 wrap
column fv_ksmmval_dec heading KSMMVAL_DEC for 99999999999999999999

select /*+ ORDERED USE_NL(m) */
    f.addr, f.indx, f.ksmfsnam fv_ksmfsnam, f.ksmfstyp fv_ksmfstyp, 
    f.ksmfsadr, f.ksmfssiz, 
    m.ksmmmval,
    to_number(m.ksmmmval, 'XXXXXXXXXXXXXXXX') fv_ksmmval_dec
from 
    x$ksmfsv f, x$ksmmem m
where 
    f.ksmfsadr = m.addr
and (lower(ksmfsnam) like lower('&1') or lower(ksmfstyp) like lower('&1'))
order by
    ksmfsnam
/



