CREATE OR REPLACE PROCEDURE %YourObjectname% IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       %YourObjectName%
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        %SYSDATE%   %USERNAME%       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     %YourObjectName%
      Sysdate:         %SYSDATE%
      Date and Time:   %DATE%, %TIME%, and %DATETIME%
      Username:        %USERNAME% (set in TOAD Options, Procedure Editor)
      Table Name:      %TableName% (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := 0;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END %YourObjectName%;



