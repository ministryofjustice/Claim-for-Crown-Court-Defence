class AddLgfsRolesToExpenseTypes < ActiveRecord::Migration[4.2]
  def up
    expense_types.each do |et|
      et.update(roles: ['agfs', 'lgfs'])
    end
  end

  def down
    expense_types.each do |et|
      et.update(roles: ['agfs'])
    end
  end

private
  def expense_types
    ExpenseType.where('name in (?)', expense_type_names)
  end

  def expense_type_names
    [
      'Car travel',
      'Parking',
      'Hotel accommodation',
      'Train/public transport',
    ]
  end
end
