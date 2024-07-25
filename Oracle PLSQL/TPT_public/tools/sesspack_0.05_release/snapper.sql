--------------------------------------------------------------------------------
--
-- File name:   snapper.sql
-- Purpose:     An easy to use Oracle session-level performance snapshot utility
--
--              NB! This script does NOT require creation of any database objects!
--
--              This is very useful for ad-hoc performance diagnosis in environments
--              with restrictive change management processes, where creating
--              even temporary tables and PL/SQL packages is not allowed or would
--              take too much time to get approved.
--
--              All processing is done by few sqlplus commands and an anonymous
--              PL/SQL block, all that's needed is SQLPLUS access (and if you want
--              to output data to tracefile then execute rights on DBMS_SYSTEM).
--
--              The output is formatted the way it could be easily post-processed
--              by either Unix string manipulation tools or loaded to spreadsheet.
--
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--
--------------------------------------------------------------------------------
--
--   The Session Snapper v1.03
--   (c) Tanel Poder ( http://www.tanelpoder.com )
--
-- 
--    +-----=====O=== Welcome to The Session Snapper! (Yes, you are looking at a cheap ASCII 
--   /                                                 imitation of a fish and a fishing rod. 
--   |                                                 Nevertheless the PL/SQL code below the
--   |                                                 fish itself should be helpful for quick
--   |                                                 catching of relevant Oracle performance 
--   |                                                 information.
--   |                                                 So I wish you happy... um... snapping?
--   |                                                )
--   |                       ......                                                  
--   |                       iittii,,....                                            
--   ¿                    iiffffjjjjtttt,,                                          
--                ..;;ttffLLLLffLLLLLLffjjtt;;..                                    
--            ..ttLLGGGGGGLLffLLLLLLLLLLLLLLffjjii,,                        ..ii,,  
--            ffGGffLLLLLLjjttjjjjjjjjffLLLLLLLLLLjjii..                ..iijj;;....
--          ffGGLLiittjjttttttiittttttttttffLLLLLLGGffii..            ;;LLLLii;;;;..
--        ffEEGGffiittiittttttttttiiiiiiiittjjjjffLLGGLLii..      iiLLLLLLttiiii,,  
--      ;;ffDDLLiiiitt,,ttttttttttttiiiiiiiijjjjjjffLLLLffttiiiiffLLGGLLjjtttt;;..  
--    ..ttttjjiitt,,iiiiiittttttttjjjjttttttttjjjjttttjjttttjjjjffLLDDGGLLttii..    
--    iittiitttt,   ;;iittttttttjjjjjjjjjjttjjjjjjffffffjjjjjjjjjjLLDDGGLLtt;;..    
--    jjjjttttii:. ..iiiiffLLGGLLLLLLLLffffffLLLLLLLLLLLLLLLLffffffLLLLLLfftt,,     
--    iittttii,,;;,,ttiiiiLLLLffffffjjffffLLLLLLLLffLLffjjttttttttttjjjjffjjii..    
--    ,,iiiiiiiiiittttttiiiiiiiiiijjffffLLLLLLLLffLLffttttttii;;;;iiiitttttttt;;..  
--    ..iittttttffffttttiiiiiiiiiittttffjjjjffffffffttiittii::    ....,,;;iittii;;  
--      ..;;iittttttttttttttttiiiiiittttttttttjjjjjjtttttt;;              ..;;ii;;..
--          ..;;;;iittttttjjttiittttttttttttttjjttttttttii..                  ....  
--                ....;;;;ttjjttttiiiiii;;;;;;iittttiiii..                          
--                      ..;;ttttii;;....      ..;;;;....                            
--                        ..iiii;;..                                                
--                          ..;;,,                                                  
--                            ....                                                  
--  
--  
--  Usage:
--
--      snapper.sql <out|trace[,pagesize=X][,gather=[s][t][w]]> <seconds_in_snap> <snapshot_count> <sid(s)_to_snap>
--
--          out      - use dbms_output.put_line() for output
--          trace    - write output to server process tracefile 
--                     (you must have execute permission on sys.dbms_system.ksdwrt() for that,
--                      you can use both out and trace parameters together if you like )
--          pagesize - display header lines after X snapshots. if pagesize=0 don't display
--                     any headers
--          gather   - if omitted, gathers all statistics
--                   - if specified, then gather following:
--                          s - Statistics from v$sesstat
--                          t - Time model info from v$sess_time_model
--                          w - Wait statistics from v$session_event and v$session_wait
--                              
--
--          you can combine above parameters in any order, separate them by commas
--          (and don't use spaces as otherwise they are treated as following parameters)
--
--		<seconds_in_snap> - the number of seconds between taking snapshots
--      <snapshot_count>  - the number of snapshots to take ( maximum value is power(2,31)-1 )
--
--      <sids_to_snap> can be either one sessionid, multiple sessionids separated by 
--      commas or a SQL statement which returns a list of SIDs (if you need spaces
--      in that parameter text, enclose it in double quotes).
--
--      if you want to snap ALL sids, use "select sid from v$session" as value for 
--      <sids_to_snap> parameter
--
--   
--  Examples:
--
--      @snapper out 1 1 515        
--      (Output one 1-second snapshot of session 515 using dbms_output and exit
--       all statistics are reported)
--
--      @snapper out,gather=w 1 1 515       
--      (Output one 1-second snapshot of session 515 using dbms_output and exit
--       only Wait event statistics are reported)
--
--      @snapper out,gather=st 1 1 515      
--      (Output one 1-second snapshot of session 515 using dbms_output and exit
--       only v$Session and v$sess_Time_model statistics are gathered)
--
--      @snapper trace,gather=stw,pagesize=0 10 90 117,210,313
--      (Write 90 10-second snapshots into tracefile for session IDs 117,210,313
--       all statistics are reported, do not print any headers)
--
--      @snapper trace 900 999999999 "select sid from v$session"
--      (Take a snapshot of ALL sessions every 15 minutes and write the output to trace,
--       loop (almost) forever )
--
--      @snapper out,trace 300 12 "select sid from v$session where username='APPS'"
--      (Take 12 5-minute snapshots of all sessions belonging to APPS user, write
--       output to both dbms_output and tracefile)
--
--  Notes:
--
--      Snapper does not currently detect if a session with given SID has
--      ended and been recreated between snapshots, thus it may report bogus
--      statistics for such sessions. The check and warning for that will be
--      implemented in a future version.
--
--------------------------------------------------------------------------------

set termout off tab off verify off linesize 157


-- Get parameters
define snapper_options="&1"
define   snapper_sleep="&2"
define   snapper_count="&3"
define     snapper_sid="&4"

-- The following code is required for making this script "dynamic" as due 
-- different Oracle versions, script parameters or granted privileges some
-- statements might not compile if not adjusted properly.

define _IF_ORA_10_OR_HIGHER="--"
define _IF_DBMS_SYSTEM_ACCESSIBLE="/* dbms_system is not accessible" /*dummy*/

col snapper_oraversion new_value _IF_ORA10_OR_HIGHER
col dbms_system_accessible new_value _IF_DBMS_SYSTEM_ACCESSIBLE

select decode(substr(banner, instr(banner, 'Release ')+8,1), 1, '', '--') snapper_oraversion 
from v$version where rownum=1;

-- this block determines whether dbms_system.ksdwrt is accessible to us
-- dbms_describe is required as all_procedures/all_objects may show this object
-- even if its not executable by us (thanks to o7_dictionary_accessibility=false)

var v varchar2(100)

declare
 
    o       sys.dbms_describe.number_table;
    p       sys.dbms_describe.number_table;
    l       sys.dbms_describe.number_table;
    a       sys.dbms_describe.varchar2_table;
    dty     sys.dbms_describe.number_table;
    def     sys.dbms_describe.number_table;
    inout   sys.dbms_describe.number_table;
    len     sys.dbms_describe.number_table;
    prec    sys.dbms_describe.number_table;
    scal    sys.dbms_describe.number_table;
    rad     sys.dbms_describe.number_table;
    spa     sys.dbms_describe.number_table;

begin

    sys.dbms_describe.describe_procedure(
        'DBMS_SYSTEM.KSDWRT', null, null, 
        o, p, l, a, dty, def, inout, len, prec, scal, rad, spa
    );

    -- we never get to following statement if dbms_system is not accessible
    -- as sys.dbms_describe will raise an exception
    :v:= '-- dbms_system is accessible';
end;
/


select nvl(:v, '/* dbms_system is not accessible') dbms_system_accessible
from dual; 

set termout on serverout on size 1000000

declare

    -- forward declarations
    procedure output(p_txt in varchar2);
    procedure fout;
    function tptformat( p_num in number, 
                        p_stype in varchar2 default 'STAT',
                        p_precision in number default 2,
                        p_base in number default 10,
                        p_grouplen in number default 3
                   )    
                   return varchar2;
    function getopt( p_parvalues in varchar2, 
                     p_extract in varchar2, 
                     p_delim in varchar2 default ',' 
                   ) 
                   return varchar2;


    -- type, constant, variable declarations

    -- trick for holding 32bit UNSIGNED event and stat_ids in 32bit SIGNED PLS_INTEGER
    pls_adjust constant number(10,0) := power(2,31) - 1;

    type srec is record (stype varchar2(4), sid number, statistic# number, value number );
    type stab is table of srec index by pls_integer;
    s1 stab;
    s2 stab;

    type snrec is record (stype varchar2(4), statistic# number, name varchar2(64));
    type sntab is table of snrec index by pls_integer;
    sn_tmp sntab;
    sn sntab;
    

    i number;
    a number;
    b number;
    
    c number;
    delta number;
    changed_values number;
    pagesize number:=99999999999999;
    missing_values_s1 number := 0;
    missing_values_s2 number := 0;
    d1 date;
    d2 date;
    lv_gather varchar2(100);

  /*---------------------------------------------------
    -- proc for outputting data to trace or dbms_output
    ---------------------------------------------------*/
    procedure output(p_txt in varchar2) is
    begin
        
        if getopt('&snapper_options', 'out') is not null then
            dbms_output.put_line(p_txt);
        end if;
    
        -- The block below is a sqlplus trick for conditionally commenting out PL/SQL code
        &_IF_DBMS_SYSTEM_ACCESSIBLE
        if getopt('&snapper_options', 'trace') is not null then
            sys.dbms_system.ksdwrt(1, p_txt);
            sys.dbms_system.ksdfls;
        end if;
        -- */   
    end; -- output

  /*---------------------------------------------------
    -- proc for outputting data, utilizing global vars
    ---------------------------------------------------*/
    procedure fout is
    begin

--      output( 'DEBUG, Entering fout(), b='||to_char(b)||' sn(s2(b).statistic#='||s2(b).statistic# );
--      output( 'DEBUG, In fout(), a='||to_char(a)||' b='||to_char(b)||' s1.count='||s1.count||' s2.count='||s2.count||' s2.count='||s2.count);
        output( 'DATA, '
                ||to_char(s2(b).sid,'999999')||', '
                ||to_char(d1, 'YYYYMMDD HH24:MI:SS')||', '
            	||to_char(case (d2-d1) when 0 then &snapper_sleep else (d2-d1) * 86400 end, '99999999')||', '
                ||s2(b).stype||', '
                ||rpad(sn(s2(b).statistic#).name, 40, ' ')||', '
                ||to_char(delta, '999999999999')||', '
                ||to_char(delta/(case (d2-d1) when 0 then &snapper_sleep else (d2-d1) * 86400 end),'999999999')||', '
                ||lpad(tptformat(delta, s2(b).stype), 10, ' ')
                ||lpad(tptformat(delta/(case (d2-d1) when 0 then &snapper_sleep else (d2-d1)* 86400 end ), s2(b).stype), 10, ' ')
        );
    end;

  /*---------------------------------------------------
    -- function for converting large numbers to human-readable format
    ---------------------------------------------------*/
    function tptformat( p_num in number, 
                        p_stype in varchar2 default 'STAT',
                        p_precision in number default 2,
                        p_base in number default 10,    -- for KiB/MiB formatting use
                        p_grouplen in number default 3  -- p_base=2 and p_grouplen=10
                      )
                      return varchar2
    is
    begin

        if p_stype in ('WAIT','TIME') then
            
            return 
                round(
                    p_num / power( p_base , trunc(log(p_base,abs(p_num)))-trunc(mod(log(p_base,abs(p_num)),p_grouplen)) ), p_precision  
                )
                || case trunc(log(p_base,abs(p_num)))-trunc(mod(log(p_base,abs(p_num)),p_grouplen))
                       when 0            then 'us'
                       when 1            then 'us'
                       when p_grouplen*1 then 'ms'
                       when p_grouplen*2 then 's'
                       when p_grouplen*3 then '000s'
                       when p_grouplen*4 then '000000s'
                       else '*'||p_base||'^'||to_char( trunc(log(p_base,abs(p_num)))-trunc(mod(log(p_base,abs(p_num)),p_grouplen)) )||' us'
                    end;
        
        else
        
            return 
                round(
                    p_num / power( p_base , trunc(log(p_base,abs(p_num)))-trunc(mod(log(p_base,abs(p_num)),p_grouplen)) ), p_precision  
                )
                || case trunc(log(p_base,abs(p_num)))-trunc(mod(log(p_base,abs(p_num)),p_grouplen))
                       when 0            then ''    
                       when 1            then ''
                       when p_grouplen*1 then 'k'
                       when p_grouplen*2 then 'M'
                       when p_grouplen*3 then 'G'
                       when p_grouplen*4 then 'T'
                       when p_grouplen*5 then 'P'
                       when p_grouplen*6 then 'E'
                       else '*'||p_base||'^'||to_char( trunc(log(p_base,abs(p_num)))-trunc(mod(log(p_base,abs(p_num)),p_grouplen)) )
                    end;
                   
        end if; 

    end; -- tptformat
    
  /*---------------------------------------------------
    -- simple function for parsing arguments from parameter string
    ---------------------------------------------------*/
    function getopt( p_parvalues in varchar2, 
                     p_extract in varchar2, 
                     p_delim in varchar2 default ',' 
                   ) return varchar2
    is
        ret varchar(1000) := NULL;
    begin

--      dbms_output.put('p_parvalues = ['||p_parvalues||'] ' );
--      dbms_output.put('p_extract = ['||p_extract||'] ' );

        if lower(p_parvalues) like lower(p_extract)||'%'
        or lower(p_parvalues) like '%'||p_delim||lower(p_extract)||'%' then
        
            ret :=
                nvl ( 
                    substr(p_parvalues,
                            instr(p_parvalues, p_extract)+length(p_extract), 
                            case 
                                instr(
                                    substr(p_parvalues,
                                            instr(p_parvalues, p_extract)+length(p_extract)
                                    )
                                    , p_delim
                                )
                            when 0 then length(p_parvalues)
                            else
                                instr(
                                    substr(p_parvalues,
                                            instr(p_parvalues, p_extract)+length(p_extract)
                                    )
                                    , p_delim
                                ) - 1
                            end
                    )
                    , chr(0) -- in case parameter was specified but with no value
                );
        
        else
            ret := null; -- no parameter found
        end if;

--      dbms_output.put_line('ret = ['||ret||']');
        
        return ret;

    end; -- getopt
    
begin

    pagesize := nvl( getopt('&snapper_options', 'pagesize=' ), pagesize);
    --output ( 'Pagesize='||pagesize );

    -- determine which statistics to collect
    lv_gather := case nvl( lower(getopt ('&snapper_options', 'gather=')), 'stw')
                    when 'all'  then 'stw'
                    else nvl( lower(getopt ('&snapper_options', 'gather=')), 'stw')
                 end;
    
    --lv_gather:=getopt ('&snapper_options', 'gather=');             
    --output('lv_gather='||lv_gather);
        

    
    if pagesize > 0 then 
        output(' ');
        output(chr(8));
        output('-- Session Snapper v1.03 by Tanel Poder ( http://www.tanelpoder.com )');
--      output('-- Parameters used: snapper.sql '||to_char(snapper_options)||' '||to_char(&snapper_sleep)||' '
--              ||to_char(&snapper_count)||' '||to_char(&snapper_sid));
        output(chr(8));
        output(' ');
    end if;

    -- initialize statistic and event name array
    -- fetch statistic names with their adjusted IDs
    select *
    bulk collect into sn_tmp
    from (  
                                 select 'STAT' stype, statistic# - pls_adjust statistic#, name
                                 from v$statname
                                 where lv_gather like '%s%'
                                 --
                                 union all
                                 select 'WAIT', 
                                        event# + (select count(*) from v$statname) + 1 - pls_adjust, name
                                 from v$event_name
                                 where lv_gather like '%w%'
                                 --
            &_IF_ORA10_OR_HIGHER union all 
            &_IF_ORA10_OR_HIGHER select 'TIME' stype, stat_id - pls_adjust statistic#, stat_name name
            &_IF_ORA10_OR_HIGHER from v$sys_time_model
            &_IF_ORA10_OR_HIGHER where lv_gather like '%t%'
    )
    order by stype, statistic#;

    -- store these into an index_by array organized by statistic# for fast lookup
    --output('sn_tmp.count='||sn_tmp.count);
    --output('lv_gather='||lv_gather);
    for i in 1..sn_tmp.count loop
    --  output('i='||i||' statistic#='||sn_tmp(i).statistic#);
        sn(sn_tmp(i).statistic#) := sn_tmp(i);
    end loop;
    

    -- main sampling loop
    for c in 1..&snapper_count loop

        if pagesize > 0 and mod(c-1, pagesize) = 0 then 
            output(rpad('--',140,'-'));
            output('--        SID, SNAPSHOT START   , SECONDS  , TYPE, '
                    ||rpad('STATISTIC',40,' ')
                    ||',         DELTA,      D/SEC,     HDELTA,   HD/SEC'
            );
            output(rpad('-',140,'-'));
        end if;

                
        d1 := sysdate;
        
        if c = 1 then 
        
            select *
            bulk collect into s1
            from (
                                         select 'STAT' stype, sid, statistic# - pls_adjust statistic#, value 
                                         from v$sesstat
                                         where sid in (&snapper_sid)
                                         and   lv_gather like '%s%'
                                         --
                                         union all
                                         select 
                                                'WAIT', sw.sid, 
                                                en.event# + (select count(*) from v$statname) + 1 - pls_adjust, 
                                                nvl(se.time_waited_micro,0) + ( decode(se.event||sw.state, sw.event||'WAITING', sw.seconds_in_wait, 0) * 1000000 ) value
                                         from v$session_wait sw, v$session_event se, v$event_name en 
                                         where sw.sid = se.sid
                                         and   se.event = en.name
                                         and   se.sid in (&snapper_sid)
                                         and   lv_gather like '%w%'
                                         --
                    &_IF_ORA10_OR_HIGHER union all 
                    &_IF_ORA10_OR_HIGHER select 'TIME' stype, sid, stat_id - pls_adjust statistic#, value
                    &_IF_ORA10_OR_HIGHER from v$sess_time_model
                    &_IF_ORA10_OR_HIGHER where sid in (&snapper_sid)
                    &_IF_ORA10_OR_HIGHER and   lv_gather like '%t%'
            )
            order by sid, stype, statistic#;
            
        else
            
            s1 := s2;
            
        end if; -- c = 1
    
        dbms_lock.sleep( (&snapper_sleep - (sysdate - d1)) );
        -- dbms_lock.sleep( (&snapper_sleep - (sysdate - d1))*1000/1024 );
    
        d2 := sysdate;
    
        select *
        bulk collect into s2
        from (  
                                         select 'STAT' stype, sid, statistic# - pls_adjust statistic#, value 
                                         from v$sesstat
                                         where sid in (&snapper_sid)
                                         and   lv_gather like '%s%'
                                         --
                                         union all
                                         select 
                                                'WAIT', sw.sid, 
                                                en.event# + (select count(*) from v$statname) + 1 - pls_adjust, 
                                                nvl(se.time_waited_micro,0) + ( decode(se.event||sw.state, sw.event||'WAITING', sw.seconds_in_wait, 0) * 1000000 ) value
                                         from v$session_wait sw, v$session_event se, v$event_name en 
                                         where sw.sid = se.sid
                                         and   se.event = en.name
                                         and   se.sid in (&snapper_sid)
                                         and   lv_gather like '%w%'
                                         --
                    &_IF_ORA10_OR_HIGHER union all 
                    &_IF_ORA10_OR_HIGHER select 'TIME' stype, sid, stat_id - pls_adjust statistic#, value
                    &_IF_ORA10_OR_HIGHER from v$sess_time_model
                    &_IF_ORA10_OR_HIGHER where sid in (&snapper_sid)
                    &_IF_ORA10_OR_HIGHER and   lv_gather like '%t%'
        )
        order by sid, stype, statistic#;
    
    
        changed_values := 0;
        missing_values_s1 := 0;
        missing_values_s2 := 0;
    
        i :=1; -- iteration counter (for debugging)
        a :=1; -- s1 array index
        b :=1; -- s2 array index
        
        while ( a <= s1.count and b <= s2.count ) loop
            
            delta := 0; -- don't print
            
            case
                when s1(a).sid = s2(b).sid then
                
                    case
                        when s1(a).statistic# = s2(b).statistic# then
                    
                            delta := s2(b).value - s1(a).value;
                            if delta != 0 then fout(); end if;

                            a := a + 1;
                            b := b + 1;
                        
                        when s1(a).statistic# > s2(b).statistic# then
                            
                            delta := s2(b).value;
                            if delta != 0 then fout(); end if;

                            b := b + 1;
                            
                        when s1(a).statistic# < s2(b).statistic# then
                            
                            output('ERROR, s1(a).statistic# < s2(b).statistic#, a='||to_char(a)||'b='||to_char(b)||' s1.count='||s1.count||'s2.count='||s2.count||' s2.count='||s2.count);
                            a := a + 1;
                            b := b + 1;
                    
                    else
                            output('ERROR, s1(a).statistic# ? s2(b).statistic#, a='||to_char(a)||'b='||to_char(b)||' s1.count='||s1.count||'s2.count='||s2.count||' s2.count='||s2.count);
                            a := a + 1;
                            b := b + 1;
                    
                    end case; -- s1(a).statistic# ... s2(b).statistic#
                    
                when s1(a).sid > s2(b).sid then
                    
                    delta := s2(b).value;
                    if delta != 0 then fout(); end if;

                    b := b + 1;
                    
                when s1(a).sid < s2(b).sid then
                    
                    output('WARN, Session has disappeared during snapshot, ignoring SID='||to_char(s2(b).sid)||' a='||to_char(a)||'b='||to_char(b)||' s1.count='||s1.count||'s2.count='||s2.count||' s2.count='||s2.count);
                    a := a + 1;
                
                else
                    output('ERROR, Should not be here, SID='||to_char(s2(b).sid)||' a='||to_char(a)||'b='||to_char(b)||' s1.count='||s1.count||'s2.count='||s2.count||' s2.count='||s2.count);
                    
            end case; -- s1(a).sid ... s2(b).sid
            
            i:=i+1;
            
            if  delta != 0 then

                changed_values := changed_values + 1;
                
            end if; -- delta != 0
            
        end loop; -- while ( a <= s1.count and b <= s2.count )


    if pagesize > 0 and changed_values > 0 then output('--  End of snap '||to_char(c)); end if;

    end loop; -- for c in 1..snapper_count 

end;
/

undefine snapper_oraversion
undefine snapper_sleep
undefine snapper_count
undefine snapper_sid
undefine _IF_ORA10_OR_HIGHER
undefine _IF_DBMS_SYSTEM_ACCESSIBLE
col snapper_oraversion clear
col dbms_system_accessible clear
