
--incident v1
SELECT severity,
         to_char(a.creation_date, 'DD/MM/YYYY HH24:MI:SS') as creation_date,
         CASE
            WHEN EXTRACT (YEAR FROM a.closed_date) = '2099' THEN ''
            ELSE TO_CHAR (a.closed_date, 'DD/MM/YYYY HH24:MI:SS')
         END
            AS closed_date,
         b.target_name,
         CASE
            WHEN severity = 'Clear'
            THEN
               REGEXP_REPLACE (summary_msg, 'CLEARED - ', '')
            ELSE
               summary_msg
         END
            AS MESSAGE
    FROM MGMT$INCIDENTS a, MGMT$target b, MGMT$INCIDENT_CATEGORY c
   WHERE     c.incident_id = a.incident_id
         AND a.target_guid = b.target_guid
         AND a.severity NOT IN ('Advisory')
         AND a.creation_date >
                  SYSDATE
                - (SELECT CASE
                             WHEN TO_CHAR (SYSDATE, 'd') = '2' THEN 44 / 24 
                             ELSE 14 / 24
                          END   AS num
                     FROM DUAL)
         AND target_type IN ('host','rac_database','oracle_database', 'microsoft_sqlserver_database','osm_cluster')
ORDER BY MESSAGE, target_name, creation_date

--incident v2
SELECT severity,
         to_char(a.creation_date+7/24, 'DD/MM/YYYY HH24:MI:SS') as creation_date,
         CASE
            WHEN EXTRACT (YEAR FROM a.closed_date) = '2099' THEN ''
            ELSE TO_CHAR (a.closed_date+7/24, 'DD/MM/YYYY HH24:MI:SS')
         END
            AS closed_date,
         b.target_name,
         CASE
            WHEN severity = 'Clear'
            THEN
               REGEXP_REPLACE (summary_msg, 'CLEARED - ', '')
            ELSE
               summary_msg
         END
            AS MESSAGE
    FROM MGMT$INCIDENTS a, MGMT$target b, MGMT$INCIDENT_CATEGORY c
   WHERE     c.incident_id = a.incident_id
         AND a.target_guid = b.target_guid
         AND a.severity NOT IN ('Advisory')
         AND a.last_updated_date+7/24 >
                  SYSDATE
                - (SELECT CASE
                             WHEN TO_CHAR (SYSDATE, 'd') = '2' THEN 44 / 24 
                             ELSE 14 / 24
                          END   AS num
                     FROM DUAL)
         AND target_type IN ('oracle_listener','oracle_home','oracle_exadata','oracle_exadata_grid','host','rac_database','oracle_database', 'microsoft_sqlserver_database','osm_cluster','osm_instance')
         and summary_msg not like 'CLEARED - Alert for username for SYS_% is cleared'
         and summary_msg not like 'User SYS logged on from %'
         and summary_msg not like 'CPU Utilization is%'
         and summary_msg not like 'Load Percentage for CPU%'
         and summary_msg not like 'CLEARED - Disk Device % busy.' 
         and summary_msg not like '%requires rebalance because at least one disk is low on space.'
         and summary_msg not like '%Memory Utilization is %, %warning%critical%threshold%'        
         and summary_msg not like '%Used Logical Memory, %,%warning%critical%threshold%'         
         and summary_msg not like '%Disk Device%is%busy.'
         and summary_msg not like '%Swap Utilization is % warning%critical%threshold%'
         and summary_msg not like 'CLEARED - Alert for pctUsed for % is cleared'
         and summary_msg not like 'CLEARED - % of archive area +HST_DG is used.'
         and summary_msg not like '%Filesystem % has % available space%warning%critical%threshold%'
         and summary_msg not like '%Tablespace [%] is [%] full'
         and summary_msg not like 'Metric Evaluation Error events on target %are cleared'          
         and summary_msg not like '%Metrics "Current Open Cursors Count" is at %'
         and summary_msg not like '%Metrics "Global Cache Average Current Get Time" is at %'
ORDER BY MESSAGE, target_name, creation_date

--CPU
SELECT target_name, value AS "CPU Utilization (%)"
  FROM 
    (
  SELECT TARGET_NAME,ROUND(md.value, 2) value
  FROM MGMT$metric_current md
where  md.metric_label = 'Load'
   AND md.column_label = 'CPU Utilization (%)'
   AND value > 70
)
ORDER BY target_name

--Mem
SELECT target_name, value AS "Used Logical Memory (%)"
  FROM 
    (
  SELECT TARGET_NAME,ROUND(md.value, 2) value
  FROM MGMT$metric_current md
where  md.metric_label = 'Load'
   AND md.column_label = 'Used Logical Memory (%)'
   AND value > 70
)
ORDER BY target_name

--swap
SELECT target_name, value AS "Swap Utilization (%)"
  FROM 
    (
  SELECT TARGET_NAME,ROUND(md.value, 2) value
  FROM MGMT$metric_current md
where  md.metric_label = 'Load'
   AND md.column_label = 'Swap Utilization (%)'
   AND value > 10
)
ORDER BY target_name

--up/down
SELECT target_name, target_type, AVAILABILITY_STATUS
    FROM mgmt$availability_current b
   WHERE     AVAILABILITY_STATUS != 'Target Up'
         AND target_type IN ('oracle_database', 'rac_database')
ORDER BY target_name

--listener
SELECT target_name,  AVAILABILITY_STATUS
    FROM mgmt$availability_current b
   WHERE     AVAILABILITY_STATUS != 'Target Up'
         AND target_type IN ('oracle_listener')
ORDER BY target_name


--Filesystem
SELECT target_name as "Hostname",key_value as "Mount point", value AS "Used Percent"
  FROM 
    (
  SELECT TARGET_NAME,key_value,ROUND(100-md.value, 2) value
  FROM MGMT$metric_current md
where  md.metric_label = 'Filesystems'
   and metric_column ='pctAvailable'
   and key_value !='/proc'
   AND value <= 30
)
ORDER BY target_name

--diskgroup
SELECT target_name,key_value, value AS "Disk Group Usage"
  FROM 
    (
  SELECT TARGET_NAME,key_value,ROUND(md.value, 2) value
  FROM MGMT$metric_current md
where  md.metric_label = 'Disk Group Usage'
   and metric_column ='percent_used'
   AND value > 70
   and key_value not like 'YEAR%DR'
)
ORDER BY target_name, key_value

--tablespace
SELECT target_name,key_value as TABLESPACE_NAME, value AS "Used Percent"
  FROM 
    (
  SELECT TARGET_NAME,key_value ,ROUND(md.value, 2) as value
  FROM MGMT$metric_current md
where  md.metric_name in ( 'problemTbsp','problemTbspTemp','problemTbspUndo')
and metric_column='pctUsed'
   AND value > 70
)
ORDER BY target_name,key_value


