--active logical memory
SELECT entity_name, AVERAGE / o.me, collection_time AS Act_logical_mem_util
  FROM (  SELECT c.entity_name,
                 AVG (TO_NUMBER (SYS_OP_CEG (v.met_values, c.column_index)))
                    AS AVERAGE,
                 TO_CHAR (v.collection_time, 'YYYY-MM-DD HH24:MI')
                    collection_time
            FROM sysman.em_metric_values v,
                 sysman.em_metric_items i,
                 sysman.em_rollup_target_list_tmp t,
                 sysman.em_metric_groups g,
                 sysman.em_metric_keys k,
                 sysman.gc_metric_columns_target c
           WHERE     v.metric_item_id = i.metric_item_id
                 AND i.target_guid = t.target_guid
                 AND i.metric_group_id = g.metric_group_id
                 AND v.collection_time >= SYSDATE - 2
                 AND v.collection_time < SYSDATE
                 AND i.metric_key_id = k.metric_key_id
                 AND k.key_part_1 != 'Idle'
                 AND i.metric_group_id = c.metric_group_id
                 AND i.target_guid = c.entity_guid
                 AND entity_name IN ( :HOST1, :HOST2)
                 AND c.metric_group_name = 'Load'
                 AND c.metric_column_label = 'Active Logical Memory, Kilobytes'
        GROUP BY c.entity_name,
                 TO_CHAR (v.collection_time, 'YYYY-MM-DD HH24:MI')),
       (SELECT t.mem * 1024 AS me
          FROM mgmt$os_hw_summary t
         WHERE t.target_name = :INSTANCE_N1) o

-metric current		 
SELECT target_name, VALUE / o.me
  FROM mgmt$metric_current,
       (SELECT t.mem * 1024 AS me
          FROM mgmt$os_hw_summary t
         WHERE t.target_name = :INSTANCE_N1) o
 WHERE     column_label = 'Active Logical Memory, Kilobytes'
       AND metric_name = 'Load'
       AND target_name = 't24db01'		 
--top activity
SELECT c.entity_name,
       SYS_OP_CEG (v.met_values, c.column_index) ActiveSession,
       k.key_part_1 AS WaitclassName,
       v.collection_time
  FROM sysman.em_metric_values v,
       sysman.em_metric_items i,
       sysman.em_rollup_target_list_tmp t,
       sysman.em_metric_groups g,
       sysman.em_metric_keys k,
       sysman.gc_metric_columns_target c
 WHERE     v.metric_item_id = i.metric_item_id
       AND i.target_guid = t.target_guid
       AND i.metric_group_id = g.metric_group_id
       AND v.collection_time >= SYSDATE - 2
       AND v.collection_time < SYSDATE
       AND i.metric_key_id = k.metric_key_id
       AND k.key_part_1 != 'Idle'
       AND i.metric_group_id = c.metric_group_id
       AND i.target_guid = c.entity_guid
       AND entity_name IN (SELECT DISTINCT o.target_name
                             FROM mgmt$os_hw_summary t,
                                  mgmt$db_dbninstanceinfo o
                            WHERE     o.host_name IN ( :HOST1, :HOST2)
                                  AND o.target_type = 'rac_database'
                                  AND t.host_name = o.host_name)
       AND c.metric_group_label_nlsid = 'wait_cpu_sess'
       AND c.metric_column_name = 'active_sessions'
	   

-- average arctive session
SELECT c.entity_name,
       SYS_OP_CEG (v.met_values, c.column_index) AS AVERAGE,
       TO_CHAR(v.collection_time, 'YYYY-MM-DD HH24') collection_time
  FROM sysman.em_metric_values v,
       sysman.em_metric_items i,
       sysman.em_rollup_target_list_tmp t,
       sysman.em_metric_groups g,
       sysman.em_metric_keys k,
       sysman.gc_metric_columns_target c
 WHERE     v.metric_item_id = i.metric_item_id
       AND i.target_guid = t.target_guid
       AND i.metric_group_id = g.metric_group_id
       AND v.collection_time >= SYSDATE - 2
       AND v.collection_time < SYSDATE
       AND i.metric_key_id = k.metric_key_id
       AND k.key_part_1 != 'Idle'
       AND i.metric_group_id = c.metric_group_id
       AND i.target_guid = c.entity_guid
       AND entity_name IN (SELECT DISTINCT o.target_name
                             FROM mgmt$os_hw_summary t,
                                  mgmt$db_dbninstanceinfo o
                            WHERE     o.host_name IN ( :HOST1, :HOST2)
                                  AND o.target_type = 'oracle_database'
                                  AND t.host_name = o.host_name)                                  
       AND c.metric_group_name = 'instance_throughput'       
       AND c.metric_column_name = 'avg_active_sessions'	   