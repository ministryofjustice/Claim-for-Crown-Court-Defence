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

  def owner_column_header
    params[:scheme].blank? || params[:scheme] == 'agfs' ? I18n.t('common.advocate') : I18n.t('common.litigator')
  end

end
