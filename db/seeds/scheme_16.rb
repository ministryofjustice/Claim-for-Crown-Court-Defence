require Rails.root.join('db','seeds', 'schemas', 'add_agfs_fee_scheme_16')

adder = Seeds::Schemas::AddAGFSFeeScheme16.new(pretend: false)
adder.up
