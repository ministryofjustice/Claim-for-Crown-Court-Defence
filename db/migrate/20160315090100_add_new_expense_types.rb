class AddNewExpenseTypes < ActiveRecord::Migration
  def up
    require File.join(Rails.root, 'db', 'seed_helper.rb')
    load File.join(Rails.root, 'db', 'seeds', 'expense_types.rb')
  end

  def down
    names = [ 'Car travel', 'Parking', 'Hotel accomodation', 'Train/public transport']
    names.each do |name|
      et = ExpenseType.find_by(name: name)
      unless et.nil?
        if et.expenses.size == 0
          et.destroy
        else
          raise "Unable to destroy expense type #{et.name} - there are expnses of this type in the database"
        end
      end
    end
  end
end
