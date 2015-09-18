MySQL to PostgreSQL Converter
=============================

Lanyrd's MySQL to PostgreSQL conversion script. Use with care.

This script was designed for our specific database and column requirements -
notably, it doubles the lengths of VARCHARs due to a unicode size problem we
had, places indexes on all foreign keys, and presumes you're using Django
for column typing purposes.

GitLab-specific changes
-----------------------

The `gitlab` branch of this fork contains the following changes made for
GitLab.

- Guard against replacing '0000-00-00 00:00:00' inside SQL text fields.
- Replace all MySQL zero-byte string literals `\0`. This is safe as of GitLab
  6.8 because the GitLab database schema contains no binary columns.
- Never set 'NOT NULL' constraints on datetimes.
- Drop sequences before creating them.
- Preserve default values of boolean (originally `tinyint(1)`) columns.
- Import all indexes.
- Import index names.
- Drop tables before creating.
- Drop indexes before creating.

How to use
----------

First, dump your MySQL database in PostgreSQL-compatible format

    mysqldump --compatible=postgresql --default-character-set=utf8 \
    -r databasename.mysql -u root gitlabhq_production -p

Then, convert it using the dbconverter.py script.

    python db_converter.py databasename.mysql databasename.psql

It'll print progress to the terminal

Now we have a DB dump that can be imported but the dump will be slow due
to existing indexes. We use 'ed' to edit the DB dump file and move the
'DROP INDEX' statements to the start of the import. Ed is not the fastest
tool for this job if your DB dump is multiple gigabytes. (Patches to
the converter are welcome!)

    ed -s databasename.psql < move_drop_indexes.ed

Next, load your new dump into a fresh PostgreSQL database using: 

`psql -f databasename.psql -d gitlabhq_production`

More information
----------------

You can learn more about the move which this powered at http://lanyrd.com/blog/2012/lanyrds-big-move/ and some technical details of it at http://www.aeracode.org/2012/11/13/one-change-not-enough/.
