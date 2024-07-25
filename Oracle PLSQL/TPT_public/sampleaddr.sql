col sampleaddr_addrlen new_value _sampleaddr_addrlen

set termout off
select vsize(addr)*2 sampleaddr_addrlen from x$dual;
set termout on

@@sample ksmmmval x$ksmmem "addr=hextoraw(lpad('&1',&_sampleaddr_addrlen,'0'))" &2
