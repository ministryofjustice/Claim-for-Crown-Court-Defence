module CaseWorkers::Admin::AllocationsHelper
  def allocation_scheme_filters
    %w[agfs
       lgfs]
  end

  def owner_column_header
    params[:scheme].blank? || params[:scheme] == 'agfs' ? I18n.t('common.advocate') : I18n.t('common.litigator')
  end
end
