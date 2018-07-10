class DiscEvidenceCoversheetBuilder
  attr_writer :template_path

  def initialize(claim)
    @claim = claim
    fill_out
  end

  def export
    result_pdf = Tempfile.new('disc_evidence', 'tmp/')
    pdftk.fill_form template_path, result_pdf, attributes
    result_pdf
  end

  protected

  def fill_out
    fill :date_day, Date.today.day.to_s
    fill :date_month, Date.today.month.to_s
    fill :date_year, Date.today.year.to_s
    fill :fee_scheme, @claim.agfs? ? 'AGFS' : 'LGFS'
    fill :case_number, @claim.case_number
    fill :court_name, @claim.court&.name
    fill :date_claim_submitted_day, @claim&.last_submitted_at&.day.to_s
    fill :date_claim_submitted_month, @claim&.last_submitted_at&.month.to_s
    fill :date_claim_submitted_year, @claim&.last_submitted_at&.year.to_s
    fill :defendant_name, @claim&.defendants&.first&.name || nil
    fill :maat_reference_number, @claim&.defendants&.first&.representation_orders&.first&.maat_reference || nil
    fill :provider_account_number, @claim.supplier_number
  end

  def fill(key, value)
    attributes[key.to_s] = value
  end

  def attributes
    @attributes ||= {}
  end

  def pdftk
    @pdftk ||= PdfForms.new(ENV['PDFTK_PATH'] || '/usr/local/bin/pdftk')
  end

  def template_path
    @template_path ||= "#{Rails.root}/public/CCD-Electronic-Evidence-coversheet.pdf"
  end
end
