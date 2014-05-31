system-check
============

Run a list of system commands, and send the output to a list of contacts.

This is intended to be run as a cron job. Something like `0 1 * * * ruby /path/to/system-check/system-check.rb` to run every day at 1 am.

Set Up
------
1. Copy or rename config.yml.example to config.yml.
2. Configure root directory, commands, and contacts, in config.yml.
3. Optionally configure cron job.
