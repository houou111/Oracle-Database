CREATE OR REPLACE TRIGGER %YourObjectname% 
%TriggerOpts%DECLARE
tmpVar NUMBER;
/******************************************************************************
   NAME:       %YourObjectName%
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        %DATE%      %USERNAME%       1. Created this trigger.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     %YourObjectName%
      Sysdate:         %SYSDATE%
      Date and Time:   %DATE%, %TIME%, and %DATETIME%
      Username:        %USERNAME% (set in TOAD Options, Proc Templates)
      Table Name:      %TableName% (set in the "New PL/SQL Object" dialog)
      Trigger Options: %TriggerOpts% (set in the "New PL/SQL Object" dialog)
******************************************************************************/
BEGIN
   tmpVar := 0;

   SELECT MySeq.NEXTVAL INTO tmpVar FROM dual;
   :NEW.SequenceColumn := tmpVar;
   :NEW.CreatedDate := SYSDATE;
   :NEW.CreatedUser := USER;

   EXCEPTION
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END %YourObjectName%;



