require Rails.root.join('db','seed_helper')

expense_types = [
  [11, 'Car travel',              ['agfs', 'lgfs'], 'A', 'CAR'],
  [12, 'Parking',                 ['agfs', 'lgfs'], 'A', 'PARK'],
  [13, 'Hotel accommodation',     ['agfs', 'lgfs'], 'A', 'HOTEL'],
  [14, 'Train/public transport',  ['agfs', 'lgfs'], 'A', 'TRAIN'],
  [15, 'Travel time',             ['agfs'],         'B', 'TRAVL'],
  [16, 'Road or tunnel tolls',    ['agfs', 'lgfs'], 'A', 'ROAD'],
  [17, 'Cab fares',               ['agfs', 'lgfs'], 'A', 'CABF'],
  [18, 'Subsistence',             ['agfs', 'lgfs'], 'A', 'SUBS'],
  [19, 'Bike travel',             ['agfs', 'lgfs'], 'A', 'BIKE']
]

max_id = 0
expense_types.each do |fields|
  record_id, name, roles, reason_set, code = fields
  max_id = [max_id, record_id].max
  SeedHelper.find_or_create_expense_type!(record_id, name, roles, reason_set, code)
end

# This is to ensure API Sandbox and Gamma are in sync regarding the IDs
ExpenseType.connection.execute("ALTER SEQUENCE expense_types_id_seq restart with #{max_id + 1}")
