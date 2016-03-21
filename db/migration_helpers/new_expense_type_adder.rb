require Rails.root.join('db','seed_helper')

module MigrationHelpers
  class NewExpenseTypeAdder

    def run
      [
        ['Car travel',                              ['agfs', 'lgfs'], 'A'],
        ['Parking',                                 ['agfs', 'lgfs'], 'A'],
        ['Hotel accommodation',                     ['agfs', 'lgfs'], 'A'],
        ['Train/public transport',                  ['agfs', 'lgfs'], 'A'],
        ['Travel time',                             ['agfs'],         'B'],
      ].each do |fields|
        name, roles, reason_set = fields
        SeedHelper.find_or_create_expense_type!(name, roles, reason_set)
      end
    end
  end
end
