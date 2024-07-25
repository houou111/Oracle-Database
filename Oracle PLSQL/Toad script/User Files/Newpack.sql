CREATE OR REPLACE PACKAGE %YourObjectname% IS
   FUNCTION MyFuncName ( inVal Number ) Return Number;
   PROCEDURE MyProcName ( inVal Number, JobId VARCHAR2 );
/******************************************************************************
   NAME:       %YourObjectName%
   PURPOSE:    To calculate the desired information.

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        %DATE%      %USERNAME%       1. Created this package.

   PARAMETERS:
   INPUT:
   OUTPUT:
   RETURNED VALUE:
   CALLED BY:
   CALLS:
   EXAMPLE USE:     NUMBER := %YourObjectName%.MyFuncName(Number);
                    %YourObjectName%.MyProcName(Number, Varchar2);
   ASSUMPTIONS:
   LIMITATIONS:
   ALGORITHM:
   NOTES:

   Here is the complete list of automatically available Auto Replace Keywords:
      Object Name:     %YourObjectName% or *YourObjectName*
      Sysdate:         %SYSDATE%
      Date/Time:       %DATETIME%
      Date:            %DATE%
      Time:            %TIME%
      Username:        %USERNAME% (set in TOAD Options, Procedure Editor)
      Table Name:      %TableName% (set in the Create New Procedure dialog)

******************************************************************************/
END %YourObjectName%;

/

CREATE OR REPLACE PACKAGE BODY %YourObjectName% AS

FUNCTION MyFuncName ( inVal Number ) Return Number IS
   TmpVar NUMBER;
BEGIN
   tmpVar := 0;
   RETURN tmpVar;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       Null;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END MyFuncName;

PROCEDURE MyProcName ( inVal Number, JobId VARCHAR2 ) IS
   TmpVar NUMBER;
BEGIN
   tmpVar := 0;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       Null;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END MyProcName;

END %YourObjectName%;

/



