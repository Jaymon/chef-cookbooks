\set QUIET
\encoding unicode
\set HISTFILE ~/.psql_history- :DBNAME
\pset null 'NULL'
\timing
\pset pager off
\x
\unset QUIET
-- http://sql-info.de/postgresql/notes/transaction-status-in-the-psql-prompt.html
\set PROMPT1 '%/%R%x%# '
