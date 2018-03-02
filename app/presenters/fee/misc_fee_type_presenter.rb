# TODO: no misc fees are case uplifts any longer, remove whole class
class Fee::MiscFeeTypePresenter < BasePresenter
  presents :fee_type

  def data_attributes
    {
      case_numbers: case_numbers_field?,
      epf: epf?
    }
  end

  private

  def case_numbers_field?
    case_uplift?
  end

  def epf?
    unique_code == 'MIEVI'
  end
end
