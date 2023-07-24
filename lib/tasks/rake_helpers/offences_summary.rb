require Rails.root.join('lib', 'tasks', 'rake_helpers', 'offences_summary', 'row')

class OffencesSummary
  def rows
    @rows ||= offences.map do |offence|
      Row.new(offence, fee_schemes:)
    end
  end

  def fee_scheme_names
    fee_schemes.map { |fs| '%s-%02d' % [fs.name[0], fs.version] }
  end

  private

  def offences
    @offences ||= Offence.unscoped.all
      .includes(:fee_schemes, :offence_class, offence_band: :offence_category)
      .order(:offence_class_id, :offence_band_id, :description, :id)
  end

  def fee_schemes
    @fee_schemes ||= FeeScheme.all.order(:name, :version)
  end
end