CREATE OR REPLACE PACKAGE %YourObjectname% AS
/******************************************************************************
   NAME:       %YourObjectName%
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        %DATE%      %USERNAME%       1. Created this package.
******************************************************************************/

  FUNCTION MyFunction(Param1 IN NUMBER) RETURN NUMBER;
  PROCEDURE MyProcedure(Param1 IN NUMBER);

END %YourObjectName%;

