/*  The examples below are editable and saved on a per-tab basis */



PROCEDURE moveaddresses (in_old_dnr_no   IN donors.dnr_no%TYPE,
                         in_old_dnr_no   IN donors.dnr_no%TYPE,
                         in_old_dnr_no   IN donors.dnr_no%TYPE,
                         in_old_dnr_no   IN donors.dnr_no%TYPE,
                         in_old_dnr_no   IN donors.dnr_no%TYPE,
                         in_new_dnr_no   IN donors.dnr_no%TYPE)
IS
BEGIN
     dummy;
END moveaddresses;

PROCEDURE movephonenumbers (in_old_dnr_no   IN donors.dnr_no%TYPE,
                            in_new_dnr_no   IN donors.dnr_no%TYPE)
IS
BEGIN
     dummy;
END movephonenumbers;

PROCEDURE moveemail (in_old_dnr_no   IN donors.dnr_no%TYPE,
                     in_new_dnr_no   IN donors.dnr_no%TYPE)
IS
BEGIN
     dummy;
END moveemail;

PROCEDURE changemasterdonor (in_old_dnr_no   IN donors.dnr_no%TYPE,
                             in_new_dnr_no   IN donors.dnr_no%TYPE)
IS
BEGIN
     dummy;
END;

PROCEDURE start_program (nm varchar2, msgfffffefe varchar2 := NULL,
                         msgfffffefef varchar2 := NULL)
IS
BEGIN
     g_progname :=   nm;
END;

CREATE FUNCTION asja.dd (cfin IN integer)
     RETURN numeric
IS
     cf  numeric (5, 2);
BEGIN
     NULL;
END;

CREATE FUNCTION asja.dd (cfin IN integer, cfout OUT integer,
                         cfinout IN OUT integer)
     RETURN numeric
IS
     cf  numeric (5, 2);
BEGIN
     NULL;
END;


DECLARE
     PROCEDURE asja1 (rn rnum, rnn rnatn,
                      rp rpos, rpn rpoven)
     IS
     BEGIN
          NULL;
     END asja1;

     PROCEDURE asja2 (rn IN rnum, rnn IN OUT rnatn,
                      rp IN rpos, rpn OUT rpoven)
     IS
     BEGIN
          NULL;
     END asja2;

     PROCEDURE asja3 (rn IN rnum, rnn IN OUT rnatn,
                      rp IN rpos, rpn OUT rpoven,
                      rs IN OUT NOCOPY rsign)
     IS
     BEGIN
          NULL;
     END asja3;
BEGIN
     NULL;
END;