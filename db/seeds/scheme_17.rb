require Rails.root.join('db','seeds', 'schemas', 'add_agfs_fee_scheme_17')

adder = Seeds::Schemas::AddAGFSFeeScheme17.new(pretend: false)
adder.up
