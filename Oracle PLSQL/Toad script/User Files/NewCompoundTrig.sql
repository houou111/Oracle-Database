COMPOUND TRIGGER
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

  BEFORE STATEMENT IS
  BEGIN
    begin
      -- we cannot reference :new or :old in the before statement section
      tmpVar := 0;
    EXCEPTION
      WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
      RAISE;
    END;
  END BEFORE STATEMENT;

  BEFORE EACH ROW IS
  BEGIN
    begin
      -- we can read or write to :new or :old in the before each row section
      tmpVar := 0;
    EXCEPTION
      WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
      RAISE;
    END;
  END BEFORE EACH ROW;

  AFTER EACH ROW IS
  BEGIN
    begin
      tmpVar := 0;
      -- we can read, but not write to :new or :old in the after each row section
    EXCEPTION
      WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
      RAISE;
    END;
  END AFTER EACH ROW;

  AFTER STATEMENT IS
  BEGIN
    begin
      -- we cannot reference :new or :old in the after statement section
      tmpVar := 0;
    EXCEPTION
      WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
      RAISE;
    END;
  END AFTER STATEMENT;
END %YourObjectName%;