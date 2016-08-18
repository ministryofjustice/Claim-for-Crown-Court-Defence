class DisbursementPresenter < BasePresenter
  presents :disbursement

  def name
    disbursement.disbursement_type&.name || 'not provided'
  end

  def net_amount
    h.number_to_currency disbursement.net_amount
  end

  def vat_amount
    h.number_to_currency disbursement.vat_amount
  end

  def total
    h.number_to_currency disbursement.total
  end
end
