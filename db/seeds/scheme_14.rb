require Rails.root.join('db','seeds', 'schemas', 'add_agfs_fee_scheme_14')

adder = Seeds::Schemas::AddAGFSFeeScheme14.new(pretend: false)
adder.up
