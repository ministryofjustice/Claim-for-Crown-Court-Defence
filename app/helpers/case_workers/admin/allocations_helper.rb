module CaseWorkers::Admin::AllocationsHelper
  def allocation_filters
    [ 'all',
      'fixed_fee',
      'cracked',
      'trial',
      'guilty_plea',
      'redetermination',
      'awaiting_written_reasons'
    ]
  end

  def allocation_scheme_filters
    [ 'agfs',
      'lgfs'
    ]
  end
end
