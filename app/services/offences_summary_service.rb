class OffencesSummaryService
  def self.call(...) = new(...).call

  def call
    OffencesSummaryService::Collection.new(offences:, fee_schemes:)
  end

  private

  def offences
    @offences ||= Offence.includes(:fee_schemes).unscoped
                         .includes(:fee_schemes, :offence_class, offence_band: :offence_category)
                         .order(:offence_class_id, :offence_band_id, :description, :id)
  end

  def fee_schemes
    @fee_schemes ||= FeeScheme.order(:name, :version)
  end
end
