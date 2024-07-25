alter system set cursor_sharing=EXACT scope=both sid='*';
--alter system set db_keep_cache_size=2G scope=spfile sid='*';
alter system set db_lost_write_protect=TYPICAL scope=both sid='*';
--alter system set db_writer_processes=8 scope=spfile sid='*';
alter system set fast_start_mttr_target=1800 scope=both sid='*';
alter system set filesystemio_options=SETALL scope=spfile sid='*';
--alter system set gcs_server_processes=4 scope=spfile sid='*';  -- only for RAC
alter system set open_cursors=5000 scope=both sid='*';
alter system set open_links=10 scope=spfile sid='*';
alter system set optimizer_index_caching=50 scope=both sid='*';
alter system set optimizer_index_cost_adj=1 scope=both sid='*';
alter system set processes=6605 scope=spfile sid='*';
alter system set query_rewrite_integrity=trusted scope=both sid='*';
alter system set session_cached_cursors=1000 scope=spfile sid='*';
alter system set session_max_open_files=500 scope=spfile sid='*';
alter system set undo_retention=54000 scope=both sid='*';
alter system set db_block_checksum=FULL scope=both sid='*';
alter system set db_flashback_retention_target=2880 scope=both sid='*';
alter system set recyclebin=off scope=spfile sid='*';
alter system set standby_file_management=AUTO scope=spfile sid='*';

--alter system set compatible='11.2.0.3.0' scope=spfile sid='*';
show parameter sga
show parameter cursor_sharing
show parameter db_lost_write_protect
show parameter fast_start_mttr_target
show parameter filesystemio_options
show parameter gcs_server_processes
show parameter open_cursors
show parameter open_links
show parameter optimizer_index_caching
show parameter optimizer_index_cost_adj
show parameter processes
show parameter query_rewrite_integrity
show parameter session_cached_cursors
show parameter session_max_open_files
show parameter undo_retention


