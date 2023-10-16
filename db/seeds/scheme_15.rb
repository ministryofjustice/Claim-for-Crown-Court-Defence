require Rails.root.join('db','seeds', 'schemas', 'add_agfs_fee_scheme_15')

adder = Seeds::Schemas::AddAGFSFeeScheme15.new(pretend: false)
adder.up
