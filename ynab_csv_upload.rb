#!/usr/bin/env ruby

# Imports a YNAB CSV into a YNAB budget's account

puts "If this crashes on Apple Silicon, make sure to use at least Ruby 2.7.5!"

require 'bigdecimal'
require 'csv'
require 'pp'
require 'ynab'

# How to call this program:
access_token, budget_id, account_id, csv_path = ARGV

ynab = YNAB::API.new(access_token)

# Transactions get identified by date+amount, so if you have multiple with
# The same date+amount, unique_count must differ. It is recommended to
# start unique_count at 1 and increment for each additional transaction with
# the same date+amount
def generate_import_id_for(transaction, unique_count)
  "YNAB:#{transaction[:amount]}:#{transaction[:date].to_s}:#{unique_count}"
end

# Pass a complete csv as string and get the transactions back.
# Assumes that the CSV contains a header row.
def csv_to_transactions(account_id, ynab_csv)
  rows = ynab_csv.drop(1)   # drop the column names

  # fill with imperative code to hand duplicate ids more easily
  previous_transactions = []

  rows.each do |row|
    usa_date, payee, memo, stringamount = row
    new_transaction = {
      account_id: account_id,
      amount: ((BigDecimal(stringamount) * 1000).to_i), # milliunits format
      cleared: "Cleared",
      date: Date.strptime(usa_date, "%m/%d/%y"), # random USA order: 12/31/93
      memo: memo[0,200],
      payee_name: payee
    }
    collision_count = previous_transactions.count do |previous_transaction|
      new_transaction[:amount] == previous_transaction[:amount] &&
      new_transaction[:date] == previous_transaction[:date]
    end
    new_transaction[:import_id] = generate_import_id_for(
      new_transaction,
      collision_count + 1
    )
    previous_transactions << new_transaction
  end
  previous_transactions
end

# Load transactions from given CSV file
ynab_csv     = CSV.read(csv_path)
all_transactions = csv_to_transactions(account_id, ynab_csv)
transactions_that_can_be_uploaded = all_transactions.select do |transaction|
  transaction[:date] <= Date.today # Future transactions don't work.
end

# pp transactions
begin
  pp ynab.transactions.create_transaction(
    budget_id,
    { transactions: transactions_that_can_be_uploaded }
  )
rescue YNAB::ApiError => e
  puts "ERROR: id=#{e.id}; name=#{e.name}; detail: #{e.detail}"
end
