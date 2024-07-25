CREATE OR REPLACE TYPE BODY %YourObjectName% AS
/******************************************************************************
   NAME:       %YourObjectName%
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        %DATE%      %USERNAME%       1. Created this type body.
******************************************************************************/

  MEMBER FUNCTION MyFunction(Param1 IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN Param1;
  END;

  MEMBER PROCEDURE MyProcedure(Param1 IN NUMBER) IS
    TmpVar NUMBER;
  BEGIN
    TmpVar := Param1;
  END;

END;

