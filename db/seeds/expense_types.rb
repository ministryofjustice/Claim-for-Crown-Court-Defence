require Rails.root.join('db','seed_helper')

old_expense_types =
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

new_expense_types = [
  ['Car travel',                              ['agfs', 'lgfs'], 'A'],
  ['Parking',                                 ['agfs', 'lgfs'], 'A'],
  ['Hotel accommodation',                     ['agfs', 'lgfs'], 'A'],
  ['Train/public transport',                  ['agfs', 'lgfs'], 'A'],
  ['Travel time',                             ['agfs'],         'B'],
  ['Road or tunnel tolls',                    ['agfs', 'lgfs'], 'A'],
  ['Cab fares',                               ['agfs', 'lgfs'], 'A'],
  ['Subsistence',                             ['agfs', 'lgfs'], 'A'],
]

expense_types = Settings.expense_schema_version == 1 ? old_expense_types : new_expense_types

expense_types.each do |fields|
  name, roles, reason_set = fields
  SeedHelper.find_or_create_expense_type!(name, roles, reason_set)
end
