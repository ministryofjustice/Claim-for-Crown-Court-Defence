require Rails.root.join('db','seeds', 'schemas', 'add_agfs_fee_scheme_12')

adder = Seeds::Schemas::AddAGFSFeeScheme12.new(pretend: false)
adder.up
