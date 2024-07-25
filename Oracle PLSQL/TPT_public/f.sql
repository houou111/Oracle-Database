col view_name for a25 wrap
col text for a60 word_wrap

select view_name, view_definition text from v$fixed_View_definition where upper(view_definition) like upper('%&1%');

