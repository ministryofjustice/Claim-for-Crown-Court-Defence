[
  'Conference and View - Car',
  'Conference and View - Hotel stay',
  'Conference and View - Train',
  'Conference and View - Travel time',
  'Costs Judge application fee',
  'Costs Judge Preparation award',
  'Travel and Hotel - Car',
  'Travel and Hotel - Conference and View',
  'Travel and Hotel - Hotel stay',
  'Travel and Hotel - Train',
].each do |expense_type_name|
  ExpenseType.find_or_create_by!(name: expense_type_name)
end
