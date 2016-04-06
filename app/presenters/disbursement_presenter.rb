class DisbursementPresenter < BasePresenter
  presents :disbursement

  # TODO: disbursements don\'t have individual amount fields, only a total in the Claim table.
  def amount
    h.number_to_currency(0)
  end

end
