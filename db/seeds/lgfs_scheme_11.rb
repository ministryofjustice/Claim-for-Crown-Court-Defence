require Rails.root.join('db','seeds', 'schemas', 'add_lgfs_fee_scheme_11')

adder = Seeds::Schemas::AddLGFSFeeScheme11.new(pretend: false)
adder.up