# Stuff for YNAB

This repository is for random things related to YNAB. This is not an official YNAB repository.

License is LGPL v3

## ynab_csv_upload.rb

Upload a single CSV file that is already in a YNAB compatible format to a single account in one of your budgets.

If this crashes on Apple Silicon, make sure to use at least Ruby 2.7.5.

### How to use

ruby ynab_csv_upload.rb APITOKEN BUDGETID ACCOUNTID CSVPATH

### Differences to uploading via the web app

* Future transactions will be ignored. (The web app changes their date to today)
