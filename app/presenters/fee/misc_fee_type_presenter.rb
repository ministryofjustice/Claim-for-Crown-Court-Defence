# TODO: no misc fees are case uplifts any longer, remove whole class
class Fee::MiscFeeTypePresenter < BasePresenter
  presents :fee_type

  def data_attributes
    {
      case_numbers: case_numbers_field?,
      evidence_provision_fee: evidence_provision_fee?
    }
  end

  private

  def case_numbers_field?
    case_uplift?
  end

  def evidence_provision_fee?
    unique_code == 'MIEVI'
  end
end
