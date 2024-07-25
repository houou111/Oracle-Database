--------------------------------------------------------------------------------
--
-- File name:   demo2.sql
--
-- Purpose:     Advanced Oracle Troubleshooting Seminar demo script
--              Makes a single fetch to generate lots of LIOs by
--              nested looping over full table scans.
--              Requires lotslios.sql script from TPT scripts.
--
-- Author:      Tanel Poder ( http://www.tanelpoder.com )
-- Copyright:   (c) Tanel Poder
--
--------------------------------------------------------------------------------

prompt Starting Demo2...

@@lotslios 1000000000000
