#!/usr/bin/ruby

# Imports a YNAB CSV into a YNAB budget's account

require 'bigdecimal'
require 'csv'
require 'pp'
require 'ynab'

# How to call this program:
access_token, budget_id, account_id, csv_path = ARGV

ynab = YNAB::API.new(access_token)

def generate_import_id_for(transaction) 
  "YNAB:#{transaction[:amount]}:#{transaction[:date].to_s}:1"
end

# Load transactions from given CSV file
ynab_csv     = CSV.read(csv_path)
rows         = ynab_csv.drop(1)   # drop the column names
transactions = rows.map do |row|
  usa_date, payee, memo, stringamount = row
  transaction = {
    account_id: account_id,
    amount: ((BigDecimal(stringamount) * 1000).to_i), # milliunits format
    cleared: "Cleared",
    date: Date.strptime(usa_date, "%m/%d/%y"), # random USA order: 12/31/93
    memo: memo[0,200],
    payee_name: payee
  }
  transaction[:import_id] = generate_import_id_for(transaction)
  transaction
end.select do |transaction|
  transaction[:date] <= Date.today
end

# pp transactions
begin
  pp ynab.transactions.create_transaction( budget_id, {transactions: transactions})
rescue YNAB::ApiError => e
  puts "ERROR: id=#{e.id}; name=#{e.name}; detail: #{e.detail}"
end
