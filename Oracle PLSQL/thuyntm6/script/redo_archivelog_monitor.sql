---Redo logs switching frequency
set linesize 300
set pagesize 5000
set trimspool on
column 00 format 99 heading "00:00"
column 01 format 99 heading "1am"
column 02 format 99 heading "2am"
column 03 format 99 heading "3am"
column 04 format 99 heading "4am"
column 05 format 99 heading "5am"
column 06 format 99 heading "6am"
column 07 format 99 heading "7am"
column 08 format 99 heading "8am"
column 09 format 99 heading "9am"
column 10 format 99 heading "10am"
column 11 format 99 heading "11am"
column 12 format 99 heading "12:00"
column 13 format 99 heading "1pm"
column 14 format 99 heading "2pm"
column 15 format 99 heading "3pm"
column 16 format 99 heading "4pm"
column 17 format 99 heading "5pm"
column 18 format 99 heading "6pm"
column 19 format 99 heading "7pm"
column 20 format 99 heading "8pm"
column 21 format 99 heading "9pm"
column 22 format 99 heading "10pm"
column 23 format 99 heading "11pm"
column 24 format 99 heading "12pm"
column "Day" format a3

prompt
prompt Redo Log Switches
prompt

SELECT trunc (first_time) "Date",
to_char (trunc (first_time),'Dy') "Day",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 0, 1)) "00",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 1, 1)) "01",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 2, 1)) "02",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 3, 1)) "03",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 4, 1)) "04",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 5, 1)) "05",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 6, 1)) "06",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 7, 1)) "07",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 8, 1)) "08",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 9, 1)) "09",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 10, 1)) "10",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 11, 1)) "11",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 12, 1)) "12",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 13, 1)) "13",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 14, 1)) "14",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 15, 1)) "15",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 16, 1)) "16",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 17, 1)) "17",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 18, 1)) "18",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 19, 1)) "19",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 20, 1)) "20",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 21, 1)) "21",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 22, 1)) "22",
sum (decode (to_number (to_char (FIRST_TIME, 'HH24')), 23, 1)) "23"
from v$log_history
where trunc (first_time) >= (trunc(sysdate) - 14) -- last X days. 0 = today only. 1 = today and yesterday
group by trunc (first_time)
order by trunc (first_time) DESC
/



---Average Log Switch Times (Min)
COLUMN avg_log_switch_min format 9,999.99 heading "Average Log Switch Times (Min)"

SET lines 132 pages 60 feedback off verify off echo off
TTITLE 'Average Log Switch Time Report'
PROMPT 'Note that high rates of Redo Log switching can cause performance problems'
PROMPT 'If this report indicates average switch times of less than 10 minutes'
PROMPT 'you should consider increasing the size of your redo logs.'
WITH redo_log_switch_times AS
(SELECT sequence#, first_time,
LAG (first_time, 1) OVER (ORDER BY first_time) AS LAG,
first_time
- LAG (first_time, 1) OVER (ORDER BY first_time) lag_time,
1440
* (first_time - LAG (first_time, 1) OVER (ORDER BY first_time)
) lag_time_pct_mins
FROM v$log_history
ORDER BY sequence#)
SELECT AVG (lag_time_pct_mins) avg_log_switch_min
FROM redo_log_switch_times;

--Monitor Redo latch statistics

COLUMN name FORMAT a30 HEADING Name
COLUMN percent FORMAT 999.999 HEADING Percent
COLUMN total HEADING Total
rem
SELECT
l2.name,
immediate_gets+gets Total,
immediate_gets "Immediates",
misses+immediate_misses "Total Misses",
DECODE (100.*(GREATEST(misses+immediate_misses,1)/
GREATEST(immediate_gets+gets,1)),100,0) Percent
FROM
v$latch l1,
v$latchname l2
WHERE
l2.name like '%redo%'
and l1.latch#=l2.latch# ;
