class DisbursementPresenter < BasePresenter
  presents :disbursement

  def name
    disbursement.disbursement_type.name
  end

  def net_amount
    h.number_to_currency disbursement.net_amount
  end

  def vat_amount
    if disbursement.claim.vat_registered?
      h.number_to_currency disbursement.vat_amount
    else
      h.content_tag :div, 'n/a', class: 'form-hint'
    end
  end

  def total
    h.number_to_currency disbursement.total
  end
end
