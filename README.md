# Stuff for YNAB

This repository is for random things related to YNAB. This is not an official YNAB repository.

License is LGPL v3

## ynab_csv_upload.rb

Upload a single CSV file that is already in a YNAB compatible format to a single account in one of your budgets.

### How to use

ruby ynab_csv_upload.rb APITOKEN BUDGETID ACCOUNTID CSVPATH

### Differences to uploading via the web app

* Future transactions will be ignored. (The web app changes their date to today)
* Having two identical transactions on the same day is currently undefined behavior. This can be fixed though, the problem is the ":1" at the end of IDs, which should count up for identical transactions. Feel free to fix it.

