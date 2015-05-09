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
-- http://www.if-not-true-then-false.com/2009/postgresql-psql-psqlrc-tips-and-tricks/

