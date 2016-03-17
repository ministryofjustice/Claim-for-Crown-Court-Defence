class RemoveOldExpenseTypes < ActiveRecord::Migration



  def up
    old_expense_types.each do |fields|
      name, roles, reason_set = fields
      et = ExpenseType.where('name ILIKE ?', name).first
      next if et.nil?
      expense_count = et.expenses.size
      raise "Unable to delete Expense Type #{et.id}: #{et.name} - #{expense_count} expenses of this type" unless expense_count == 0
      et.destroy
    end
    execute "DELETE FROM expense_types WHERE name ILIKE 'Costs Judge%'"
  end

  def down
    old_expense_types.each do |fields|
      name, roles, reason_set = fields
      et = ExpenseType.where('name ILIKE ?', name).first
      if et.nil?
        ExpenseType.create!(name: name, roles: roles, reason_set: reason_set)
      end
    end
  end


  def old_expense_types
    [
      ['Conference and view - car',               ['agfs'],         'A'],
      ['Conference and view - hotel stay',        ['agfs'],         'A'],
      ['Conference and view - train',             ['agfs'],         'A'],
      ['Conference and view - travel time',       ['agfs'],         'A'],
      ['Travel and hotel - car',                  ['agfs'],         'A'],
      ['Travel and hotel - conference and view',  ['agfs'],         'A'],
      ['Travel and hotel - hotel stay',           ['agfs'],         'A'],
      ['Travel and hotel - train',                ['agfs'],         'A'],
    ]
  end
end
