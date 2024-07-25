CREATE OR REPLACE TYPE %YourObjectName% AS OBJECT
/******************************************************************************
   NAME:       %YourObjectName%
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        %DATE%      %USERNAME%       1. Created this type.
******************************************************************************/
(
  NewAttribute VARCHAR2(255),
  MEMBER FUNCTION MyFunction(Param1 IN NUMBER) RETURN NUMBER,
  MEMBER PROCEDURE MyProcedure(Param1 IN NUMBER)
);

