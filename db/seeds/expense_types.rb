require Rails.root.join('db','seed_helper')

[

  ['Conference and view - car',               ['agfs'],         'A'],
  ['Conference and view - hotel stay',        ['agfs'],         'A'],
  ['Conference and view - train',             ['agfs'],         'A'],
  ['Conference and view - travel time',       ['agfs'],         'A'],
  ['Costs judge application fee',             ['agfs'],         'A'],
  ['Costs judge Preparation award',           ['agfs'],         'A'],
  ['Travel and hotel - car',                  ['agfs'],         'A'],
  ['Travel and hotel - conference and view',  ['agfs'],         'A'],
  ['Travel and hotel - hotel stay',           ['agfs'],         'A'],
  ['Travel and hotel - train',                ['agfs'],         'A'],
  ['Car travel',                              ['agfs', 'lgfs'], 'A'],
  ['Parking',                                 ['agfs', 'lgfs'], 'A'],
  ['Hotel accommodation',                     ['agfs', 'lgfs'], 'A'],
  ['Train/public transport',                  ['agfs', 'lgfs'], 'A'],
  ['Travel time',                             ['agfs'],         'B'],
].each do |fields|
  name, roles, reason_set = fields
  SeedHelper.find_or_create_expense_type!(name, roles, reason_set)
end
